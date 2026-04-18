#!/usr/bin/env bash
# PostToolUse hook: append a structured audit-log record for each
# Bash / Edit / Write tool call.
#
# Protocol:
#   - Reads JSON on stdin (session_id, tool_name, tool_input, tool_response).
#   - Appends one JSON object per invocation (JSON Lines) to:
#       $CLAUDE_PROJECT_DIR/.claude/logs/session-<session_id>.jsonl
#   - Exit code is advisory; PostToolUse cannot block. We always exit 0 so a
#     logging failure never disrupts Claude's workflow.
#
# Design notes:
#   - We intentionally do NOT log edit bodies or write contents. Diffs live in
#     git; logging content risks leaking secrets.
#   - stdout/stderr are truncated to the last 2000 chars each.
#   - Append-only, JSON Lines, no rotation. Grep/jq-friendly.

set -uo pipefail

# --- resolve project dir / log path ----------------------------------------
# Fall back to the script's grandparent if CLAUDE_PROJECT_DIR isn't set.
project_dir="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$project_dir" ]]; then
    project_dir="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)" || project_dir=""
fi

log_dir="${project_dir}/.claude/logs"

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Best-effort mkdir. If it fails there's nothing useful to do; we still exit 0.
mkdir -p "$log_dir" 2>/dev/null || true

# --- helper: write a minimal error record and exit 0 -----------------------
write_error_record() {
    local err_msg="$1"
    local fallback_path="${log_dir}/session-unknown.jsonl"
    # Use a here-string with jq if available; otherwise hand-craft a safe line.
    if command -v jq >/dev/null 2>&1; then
        jq -cn --arg ts "$ts" --arg error "$err_msg" \
            '{ts:$ts, error:$error}' \
            >> "$fallback_path" 2>/dev/null || true
    else
        # Escape backslashes and double-quotes in the error message.
        local safe
        safe="${err_msg//\\/\\\\}"
        safe="${safe//\"/\\\"}"
        printf '{"ts":"%s","error":"%s"}\n' "$ts" "$safe" \
            >> "$fallback_path" 2>/dev/null || true
    fi
    exit 0
}

# --- dependency check ------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
    write_error_record "jq not found in PATH; cannot parse hook payload"
fi

# --- read + parse payload --------------------------------------------------
payload="$(cat)"

if [[ -z "$payload" ]]; then
    write_error_record "empty stdin payload"
fi

# Validate JSON. `jq -e .` returns non-zero on parse failure.
if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
    write_error_record "malformed JSON on stdin"
fi

session_id="$(printf '%s' "$payload" | jq -r '.session_id // "unknown"')"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"

# Sanitize session_id for use as a filename (only allow [A-Za-z0-9._-]).
safe_session="$(printf '%s' "$session_id" | tr -c 'A-Za-z0-9._-' '_')"
if [[ -z "$safe_session" ]]; then
    safe_session="unknown"
fi

log_file="${log_dir}/session-${safe_session}.jsonl"

# Only the three wired tools are logged. If this hook ever gets called for
# something else, drop silently.
case "$tool_name" in
    Bash|Edit|Write) ;;
    *) exit 0 ;;
esac

# --- build the record per tool ---------------------------------------------
cwd="$(pwd 2>/dev/null || echo "")"
record=""

case "$tool_name" in
    Bash)
        record="$(printf '%s' "$payload" | jq -c \
            --arg ts "$ts" \
            --arg session_id "$session_id" \
            --arg cwd "$cwd" \
            '
            def truncate_cmd:
                if (. | length) > 500
                then (.[0:500] + "...")
                else .
                end;
            def tail_n(n):
                if . == null or . == "" then ""
                elif (. | length) > n then (.[-n:])
                else .
                end;
            {
                ts: $ts,
                session_id: $session_id,
                tool: "Bash",
                cmd:         ((.tool_input.command // "") | truncate_cmd),
                exit:        (.tool_response.exit_code // null),
                interrupted: (.tool_response.interrupted // false),
                stdout_tail: ((.tool_response.stdout // "") | tail_n(2000)),
                stderr_tail: ((.tool_response.stderr // "") | tail_n(2000)),
                cwd: $cwd
            }
            ' 2>/dev/null)"
        ;;
    Edit)
        record="$(printf '%s' "$payload" | jq -c \
            --arg ts "$ts" \
            --arg session_id "$session_id" \
            '
            {
                ts: $ts,
                session_id: $session_id,
                tool: "Edit",
                file:        (.tool_input.file_path // ""),
                replace_all: (.tool_input.replace_all // false),
                old_len:     ((.tool_input.old_string // "") | length),
                new_len:     ((.tool_input.new_string // "") | length),
                delta:       (((.tool_input.new_string // "") | length)
                              - ((.tool_input.old_string // "") | length))
            }
            ' 2>/dev/null)"
        ;;
    Write)
        record="$(printf '%s' "$payload" | jq -c \
            --arg ts "$ts" \
            --arg session_id "$session_id" \
            '
            {
                ts: $ts,
                session_id: $session_id,
                tool: "Write",
                file:  (.tool_input.file_path // ""),
                bytes: ((.tool_input.content // "") | length)
            }
            ' 2>/dev/null)"
        ;;
esac

# --- append ----------------------------------------------------------------
if [[ -n "$record" ]]; then
    printf '%s\n' "$record" >> "$log_file" 2>/dev/null || true
else
    # jq failed somewhere; still leave a trail.
    jq -cn --arg ts "$ts" --arg session_id "$session_id" --arg tool "$tool_name" \
        '{ts:$ts, session_id:$session_id, tool:$tool, error:"jq record build failed"}' \
        >> "$log_file" 2>/dev/null || true
fi

exit 0
