#!/usr/bin/env bash
# .claude/hooks/review-diff.sh
#
# Layer 2 of the security stack: LLM-based semantic review of Write/Edit diffs.
# Default OFF. Set CLAUDE_LLM_REVIEW_ENABLED=1 to enable.
#
# Policy: all failure modes are non-blocking EXCEPT a confirmed finding with
# score >= 2, which exits 2 and surfaces the finding on stderr.
#
# See .claude/docs/llm-review-setup.md for setup and cost notes.

set -uo pipefail

# ---- tempfile hygiene -------------------------------------------------------
TMPDIR_SELF="$(mktemp -d -t claude-llm-review.XXXXXX)" || exit 0
trap 'rm -rf "$TMPDIR_SELF"' EXIT

REQ_FILE="$TMPDIR_SELF/req.json"
RESP_FILE="$TMPDIR_SELF/resp.json"
CONTENT_FILE="$TMPDIR_SELF/content.txt"

# ---- 0. feature flag --------------------------------------------------------
if [[ -z "${CLAUDE_LLM_REVIEW_ENABLED:-}" ]]; then
  exit 0
fi

# ---- 1. read hook stdin -----------------------------------------------------
INPUT="$(cat)"
if [[ -z "$INPUT" ]]; then
  exit 0
fi

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"

case "$TOOL_NAME" in
  Write)
    printf '%s' "$INPUT" | jq -r '.tool_input.content // empty' > "$CONTENT_FILE"
    ;;
  Edit)
    printf '%s' "$INPUT" | jq -r '.tool_input.new_string // empty' > "$CONTENT_FILE"
    ;;
  *)
    exit 0
    ;;
esac

if [[ ! -s "$CONTENT_FILE" || -z "$FILE_PATH" ]]; then
  exit 0
fi

# ---- 2. scope filter --------------------------------------------------------
in_scope=0

shopt -s nocasematch
case "$FILE_PATH" in
  *.py|*.js|*.jsx|*.ts|*.tsx|*.go|*.rb|*.java|*.rs|*.php|\
  *.scala|*.kt|*.swift|*.m|*.cs|*.c|*.cpp|*.h|*.hpp|*.tf)
    in_scope=1
    ;;
esac

base="$(basename -- "$FILE_PATH")"
case "$base" in
  Dockerfile|docker-compose.yml|docker-compose.yaml)
    in_scope=1
    ;;
esac

case "$FILE_PATH" in
  *.yaml|*.yml)
    case "$FILE_PATH" in
      */k8s/*|*/kubernetes/*|*/deploy/*|*/manifests/*)
        in_scope=1
        ;;
      *values*|*deployment*|*role*)
        in_scope=1
        ;;
    esac
    ;;
esac
shopt -u nocasematch

if [[ $in_scope -eq 0 ]]; then
  exit 0
fi

# ---- 3. approval-marker short-circuit --------------------------------------
if grep -qF '# CLAUDE_APPROVED_DESTRUCTIVE' "$CONTENT_FILE"; then
  exit 0
fi

# ---- 4. auth ----------------------------------------------------------------
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "llm-review: ANTHROPIC_API_KEY not set; skipping (set CLAUDE_LLM_REVIEW_ENABLED=0 to silence)." >&2
  exit 0
fi

# ---- 5. size cap ------------------------------------------------------------
MAX_CHARS=20000
CONTENT_BYTES="$(wc -c < "$CONTENT_FILE")"
if [[ "$CONTENT_BYTES" -gt "$MAX_CHARS" ]]; then
  head -c "$MAX_CHARS" "$CONTENT_FILE" > "$CONTENT_FILE.trunc"
  printf '\n\n[truncated at %d chars]\n' "$MAX_CHARS" >> "$CONTENT_FILE.trunc"
  mv "$CONTENT_FILE.trunc" "$CONTENT_FILE"
fi

# ---- 6. load static prompt --------------------------------------------------
PROMPT_FILE="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/hooks/review-diff-prompt.md"
if [[ ! -r "$PROMPT_FILE" ]]; then
  echo "llm-review: prompt file missing at $PROMPT_FILE; skipping." >&2
  exit 0
fi

# ---- 7. build request via jq (never string-concat user content) ------------
jq -n \
  --rawfile static_prompt "$PROMPT_FILE" \
  --rawfile code "$CONTENT_FILE" \
  --arg file_path "$FILE_PATH" \
  --arg tool_name "$TOOL_NAME" \
  '{
    model: "claude-haiku-4-5-20251001",
    max_tokens: 1024,
    system: [
      {
        type: "text",
        text: $static_prompt,
        cache_control: { type: "ephemeral" }
      },
      {
        type: "text",
        text: ("File under review: " + $file_path + "\nTool: " + $tool_name)
      }
    ],
    messages: [
      {
        role: "user",
        content: ("```\n" + $code + "\n```")
      }
    ]
  }' > "$REQ_FILE" || { echo "llm-review: failed to build request JSON; skipping." >&2; exit 0; }

# ---- 8. debug logging (optional) -------------------------------------------
DEBUG_LOG=""
if [[ -n "${CLAUDE_LLM_REVIEW_DEBUG:-}" ]]; then
  LOG_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/logs"
  mkdir -p "$LOG_DIR" 2>/dev/null || true
  DEBUG_LOG="$LOG_DIR/llm-review-debug.log"
  {
    printf '=== %s === tool=%s file=%s ===\n' "$(date -u +%FT%TZ)" "$TOOL_NAME" "$FILE_PATH"
    echo '--- request (key redacted) ---'
    cat "$REQ_FILE"
    echo
  } >> "$DEBUG_LOG" 2>/dev/null || true
fi

# ---- 9. call API (30s hard cap; override via stub for tests) ---------------
CURL_CMD="${CLAUDE_LLM_REVIEW_CURL:-curl}"

HTTP_STATUS=0
if [[ "$CURL_CMD" == "curl" ]]; then
  timeout 30 curl -sS --fail \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -X POST "https://api.anthropic.com/v1/messages" \
    --data-binary "@$REQ_FILE" \
    -o "$RESP_FILE"
  HTTP_STATUS=$?
else
  "$CURL_CMD" "$REQ_FILE" "$RESP_FILE"
  HTTP_STATUS=$?
fi

if [[ $HTTP_STATUS -ne 0 ]]; then
  case $HTTP_STATUS in
    124) echo "llm-review: API call timed out after 30s; skipping." >&2 ;;
    *)   echo "llm-review: API call failed (status $HTTP_STATUS); skipping." >&2 ;;
  esac
  exit 0
fi

if [[ -n "$DEBUG_LOG" ]]; then
  { echo '--- response ---'; cat "$RESP_FILE"; echo; } >> "$DEBUG_LOG" 2>/dev/null || true
fi

# ---- 10. parse response ----------------------------------------------------
TEXT_OUT="$(jq -r '.content[0].text // empty' "$RESP_FILE" 2>/dev/null)"
if [[ -z "$TEXT_OUT" ]]; then
  echo "llm-review: empty or malformed API response; skipping." >&2
  exit 0
fi

if ! printf '%s' "$TEXT_OUT" | jq -e '.findings and .summary' >/dev/null 2>&1; then
  echo "llm-review: model returned non-JSON or wrong shape; skipping." >&2
  exit 0
fi

# ---- 11. evaluate findings --------------------------------------------------
HIGH_FINDINGS="$(printf '%s' "$TEXT_OUT" | jq -c '[.findings[] | select((.score // 0) >= 2)]')"
HIGH_COUNT="$(printf '%s' "$HIGH_FINDINGS" | jq 'length')"

PRINCIPLE_NAMES=(
  "[placeholder]"
  "Untrusted input -> shell/subprocess"
  "Upload/temp file -> executable path"
  "Root / broad privilege where least-privilege applies"
  "Secret exposure in code, logs, config, or CI"
  "Low-trust path -> admin/control-plane surface"
)

if [[ "${HIGH_COUNT:-0}" -gt 0 ]]; then
  echo "llm-review: BLOCKED $FILE_PATH" >&2
  SUMMARY="$(printf '%s' "$TEXT_OUT" | jq -r '.summary // ""')"
  [[ -n "$SUMMARY" ]] && echo "  summary: $SUMMARY" >&2

  while IFS= read -r row; do
    p="$(jq -r '.principle // 0' <<<"$row")"
    s="$(jq -r '.score // 0' <<<"$row")"
    ln="$(jq -r '.line // "?"' <<<"$row")"
    note="$(jq -r '.note // ""' <<<"$row")"
    name="${PRINCIPLE_NAMES[$p]:-unknown}"
    printf '  principle %s [%s] score=%s line=%s: %s\n' \
      "$p" "$name" "$s" "$ln" "$note" >&2
  done < <(printf '%s' "$HIGH_FINDINGS" | jq -c '.[]')

  echo "To override for this specific write, append \`# CLAUDE_APPROVED_DESTRUCTIVE\` to the content." >&2
  exit 2
fi

# ---- 12. clean pass ---------------------------------------------------------
SUMMARY="$(printf '%s' "$TEXT_OUT" | jq -r '.summary // empty')"
if [[ -n "$SUMMARY" ]]; then
  echo "llm-review: info: $SUMMARY" >&2
fi
exit 0
