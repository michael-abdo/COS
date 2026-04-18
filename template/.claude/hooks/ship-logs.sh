#!/usr/bin/env bash
# SessionEnd hook: ships the current session's JSONL audit log to an off-box destination.
# Never fails the session — all errors go to .claude/logs/.ship-failures/<session>.log.
# Destinations via CLAUDE_LOG_SHIP_TARGET: s3://, gs://, https://, file://.
set -uo pipefail

payload="$(cat 2>/dev/null || true)"

if ! command -v jq >/dev/null 2>&1; then
  echo "ship-logs: jq not found; cannot parse payload" >&2
  exit 0
fi

raw_session="$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null || true)"
session_id="$(printf '%s' "$raw_session" | tr -cd '[:alnum:]._-')"

if [ -z "$session_id" ]; then
  echo "ship-logs: no session_id in payload; nothing to ship" >&2
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd || echo "$PWD")}"
log_file="$project_dir/.claude/logs/session-${session_id}.jsonl"

if [ ! -f "$log_file" ]; then
  exit 0
fi

target="${CLAUDE_LOG_SHIP_TARGET:-}"
if [ -z "$target" ]; then
  echo "ship-logs: CLAUDE_LOG_SHIP_TARGET not set; local log retained at $log_file" >&2
  exit 0
fi

ts_human="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
ts_unix="$(date -u +%s)"
upload_name="${session_id}.${ts_unix}.jsonl"
failure_dir="$project_dir/.claude/logs/.ship-failures"
receipt="$project_dir/.claude/logs/.shipped.log"
err_tmp="$(mktemp 2>/dev/null || echo "/tmp/ship-logs-err.$$")"
body_tmp="$(mktemp 2>/dev/null || echo "/tmp/ship-logs-body.$$")"
trap 'rm -f "$err_tmp" "$body_tmp"' EXIT

# Belt-and-braces redaction pass — same pattern classes the detect-secrets hook blocks.
sed -E \
  -e 's/(AKIA|ASIA)[A-Z0-9]{16}/<REDACTED-AWS-KEY>/g' \
  -e 's/gh[pousr]_[A-Za-z0-9]{36,}/<REDACTED-GITHUB-PAT>/g' \
  -e 's/AIza[0-9A-Za-z_-]{35}/<REDACTED-GOOGLE-API-KEY>/g' \
  -e 's/xox[abpr]-[0-9A-Za-z-]{10,}/<REDACTED-SLACK-TOKEN>/g' \
  -e 's/sk_live_[0-9A-Za-z]{24,}/<REDACTED-STRIPE>/g' \
  -e 's/pk_live_[0-9A-Za-z]{24,}/<REDACTED-STRIPE>/g' \
  -e 's/eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/<REDACTED-JWT>/g' \
  -e 's/-----BEGIN [A-Z ]*PRIVATE KEY-----/<REDACTED-PRIVATE-KEY>/g' \
  -e 's/([Bb]earer )[A-Za-z0-9._-]{20,}/\1<REDACTED>/g' \
  "$log_file" > "$body_tmp" 2>/dev/null || cp "$log_file" "$body_tmp"

bytes="$(wc -c < "$body_tmp" | tr -d ' ')"

ship_ok=0
error_msg=""

case "$target" in
  s3://*)
    if ! command -v aws >/dev/null 2>&1; then
      error_msg="aws CLI not found on PATH"
    elif timeout 30 aws s3 cp "$body_tmp" "${target%/}/$upload_name" --quiet 2>"$err_tmp"; then
      ship_ok=1
    else
      error_msg="aws s3 cp failed: $(tr '\n' ' ' < "$err_tmp" 2>/dev/null | head -c 400)"
    fi
    ;;
  gs://*)
    if command -v gcloud >/dev/null 2>&1; then
      if timeout 30 gcloud storage cp "$body_tmp" "${target%/}/$upload_name" --quiet 2>"$err_tmp"; then
        ship_ok=1
      else
        error_msg="gcloud storage cp failed: $(tr '\n' ' ' < "$err_tmp" 2>/dev/null | head -c 400)"
      fi
    elif command -v gsutil >/dev/null 2>&1; then
      if timeout 30 gsutil -q cp "$body_tmp" "${target%/}/$upload_name" 2>"$err_tmp"; then
        ship_ok=1
      else
        error_msg="gsutil cp failed: $(tr '\n' ' ' < "$err_tmp" 2>/dev/null | head -c 400)"
      fi
    else
      error_msg="neither gcloud nor gsutil found on PATH"
    fi
    ;;
  https://*|http://*)
    auth_args=()
    if [ -n "${CLAUDE_LOG_SHIP_AUTH:-}" ]; then
      auth_args=(-H "Authorization: ${CLAUDE_LOG_SHIP_AUTH}")
    fi
    if timeout 30 curl -sS --fail \
        "${auth_args[@]}" \
        -H "Content-Type: application/x-ndjson" \
        -H "X-Claude-Session: $session_id" \
        --data-binary @"$body_tmp" \
        "$target" >/dev/null 2>"$err_tmp"; then
      ship_ok=1
    else
      error_msg="curl POST failed: $(tr '\n' ' ' < "$err_tmp" 2>/dev/null | head -c 400)"
    fi
    ;;
  file://*)
    dest_dir="${target#file://}"
    if mkdir -p "$dest_dir" 2>"$err_tmp" && cp "$body_tmp" "$dest_dir/$upload_name" 2>>"$err_tmp"; then
      ship_ok=1
    else
      error_msg="file copy failed: $(tr '\n' ' ' < "$err_tmp" 2>/dev/null | head -c 400)"
    fi
    ;;
  *)
    error_msg="unknown target scheme: $target (expected s3://, gs://, https://, http://, or file://)"
    ;;
esac

if [ "$ship_ok" -eq 1 ]; then
  printf '[%s] session=%s target=%s bytes=%s\n' "$ts_human" "$session_id" "$target" "$bytes" >> "$receipt"
else
  mkdir -p "$failure_dir" 2>/dev/null || true
  printf '[%s] target=%s error=%s\n' "$ts_human" "$target" "$error_msg" >> "$failure_dir/${session_id}.log"
  echo "ship-logs: upload failed — see $failure_dir/${session_id}.log" >&2
fi

exit 0
