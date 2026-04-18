#!/usr/bin/env bash
# PreToolUse hook: block destructive Bash commands unless explicitly approved.
#
# Protocol:
#   - Reads JSON on stdin: {"tool_name": "Bash", "tool_input": {"command": "...", ...}, ...}
#   - Exit 0: allow the tool call.
#   - Exit 2: block the tool call; stderr is returned to Claude as feedback.
#
# Override: append the literal trailing comment "# CLAUDE_APPROVED_DESTRUCTIVE"
# to a command to bypass this gate after the user has explicitly authorized it.

set -euo pipefail

# --- dependency check -------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
    echo "block-destructive-bash.sh: 'jq' is required but not found in PATH." >&2
    # Non-blocking error (not exit 2) so Claude still sees a signal but the
    # session isn't hard-stopped on a tooling gap.
    exit 1
fi

# --- parse input ------------------------------------------------------------
payload="$(cat)"

# Only gate Bash tool calls. If this script is invoked for anything else,
# allow it through silently.
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"
if [[ -n "$tool_name" && "$tool_name" != "Bash" ]]; then
    exit 0
fi

command_str="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')"

# Empty command -> nothing to check.
if [[ -z "$command_str" ]]; then
    exit 0
fi

# --- explicit override ------------------------------------------------------
# The marker must be present as a trailing comment (common cases: end of line
# or end of command). We accept it anywhere in the string to be forgiving,
# since the user has to deliberately type it.
if [[ "$command_str" == *"# CLAUDE_APPROVED_DESTRUCTIVE"* ]]; then
    exit 0
fi

# --- pattern matching -------------------------------------------------------
# We shell-out to grep -E for portable ERE. Case-insensitive where noted.
# For each pattern we store: a label, a grep flag set, and the regex.
#
# Prefer false negatives over false positives: patterns are tight and keyed
# on the destructive token plus the dangerous flag/argument shape.

matched_label=""
matched_reason=""
matched_suggestion=""

# Helper: test command against an ERE; sets matched_* and returns 0 on hit.
match() {
    local label="$1" reason="$2" suggestion="$3" flags="$4" regex="$5"
    if printf '%s' "$command_str" | grep -E $flags -- "$regex" >/dev/null 2>&1; then
        matched_label="$label"
        matched_reason="$reason"
        matched_suggestion="$suggestion"
        return 0
    fi
    return 1
}

# 1. rm -rf and variants (rm -fr, rm -r -f, rm --recursive --force, etc.)
#    Catches: rm -rf, rm -fr, rm -Rf, rm -r ... -f, rm --recursive --force
match "rm -rf (recursive force delete)" \
      "Recursively force-deletes files with no undo. Shared-state impact if path resolves outside the expected tree." \
      "Use 'rm -rI' for interactive confirmation, 'trash'/'gio trash' if available, or narrow the path and drop -f. If you really need it, ask the user to confirm the exact command." \
      "" \
      '(^|[[:space:]])rm([[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*|[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*|([[:space:]]+--(recursive|force))+)' \
    && true

# Also catch the explicit long-form in either order.
if [[ -z "$matched_label" ]]; then
    match "rm --recursive --force" \
          "Recursively force-deletes files with no undo." \
          "Drop --force, use -I for interactive confirmation, or ask the user to confirm the exact command." \
          "" \
          '(^|[[:space:]])rm[[:space:]]+.*--recursive.*--force|(^|[[:space:]])rm[[:space:]]+.*--force.*--recursive' \
        && true
fi

# 2. git push --force / -f  (but allow --force-with-lease)
if [[ -z "$matched_label" ]]; then
    if printf '%s' "$command_str" | grep -E -- '(^|[[:space:]])git[[:space:]]+push([[:space:]]+[^#]*)?[[:space:]](--force([[:space:]]|$)|-f([[:space:]]|$))' >/dev/null 2>&1; then
        # But exempt --force-with-lease (safer variant).
        if ! printf '%s' "$command_str" | grep -E -- '--force-with-lease' >/dev/null 2>&1 \
           || printf '%s' "$command_str" | grep -E -- '(^|[[:space:]])--force([[:space:]]|$)' >/dev/null 2>&1; then
            matched_label="git push --force / -f"
            matched_reason="Overwrites remote history for other collaborators with no safety check. Irreversible for anyone who had the old tip."
            matched_suggestion="Use 'git push --force-with-lease' (refuses if the remote moved) or, better, rebase locally and push to a new branch. Ask the user to confirm if --force is truly required."
        fi
    fi
fi

# 3. git reset --hard
if [[ -z "$matched_label" ]]; then
    match "git reset --hard" \
          "Discards all uncommitted changes in the working tree and index with no recovery outside the reflog." \
          "Consider 'git stash' first, 'git reset --keep', or a soft/mixed reset. If intentional, ask the user to confirm." \
          "" \
          '(^|[[:space:]])git[[:space:]]+reset([[:space:]]+[^#]*)?[[:space:]]--hard([[:space:]]|$)' \
        && true
fi

# 4. git clean -f / -fd / -fdx
if [[ -z "$matched_label" ]]; then
    match "git clean -f" \
          "Deletes untracked files (and with -d, directories). No recycle bin; gone instantly." \
          "Run 'git clean -n' (dry-run) first to preview. Ask the user to confirm before removing." \
          "" \
          '(^|[[:space:]])git[[:space:]]+clean([[:space:]]+[^#]*)?[[:space:]]-[a-zA-Z]*f' \
        && true
fi

# 5. git branch -D (force-delete branch)
if [[ -z "$matched_label" ]]; then
    match "git branch -D" \
          "Force-deletes a local branch even if it has unmerged commits. Recovery requires the reflog and is error-prone." \
          "Use 'git branch -d' (lowercase) which refuses if unmerged, or confirm with the user that the branch is truly abandoned." \
          "" \
          '(^|[[:space:]])git[[:space:]]+branch([[:space:]]+[^#]*)?[[:space:]]-D([[:space:]]|$)' \
        && true
fi

# 6. git checkout . / git restore .  (bulk discard of working tree)
if [[ -z "$matched_label" ]]; then
    match "git checkout . / git restore . (bulk discard)" \
          "Discards every uncommitted change in the working tree. No reflog for uncommitted work." \
          "Narrow to specific paths, or 'git stash' first. Ask the user before wiping the whole tree." \
          "" \
          '(^|[[:space:]])git[[:space:]]+(checkout|restore)[[:space:]]+\.([[:space:]]|$|;|&)' \
        && true
fi

# 7. SQL DROP TABLE / DROP DATABASE / TRUNCATE  (case-insensitive)
if [[ -z "$matched_label" ]]; then
    match "SQL DROP / TRUNCATE" \
          "Drops or truncates a table/database. Affects shared persistent state and is not reversible without a backup." \
          "Run against a staging DB first, wrap in a transaction you can ROLLBACK, or confirm with the user that you're targeting the right environment." \
          "-i" \
          '(^|[^a-zA-Z_])(drop[[:space:]]+(table|database|schema)|truncate([[:space:]]+table)?)[[:space:]]' \
        && true
fi

# 8. DELETE FROM ... without a WHERE clause (case-insensitive, single statement)
if [[ -z "$matched_label" ]]; then
    # Match "DELETE FROM <something>" that does NOT contain "WHERE" before a
    # statement terminator (;, end-of-string, or closing quote).
    if printf '%s' "$command_str" | grep -Ei -- '(^|[^a-zA-Z_])delete[[:space:]]+from[[:space:]]+[^;"'\'']+' >/dev/null 2>&1; then
        # Extract each DELETE FROM segment and check for WHERE.
        if ! printf '%s' "$command_str" | grep -Ei -- '(^|[^a-zA-Z_])delete[[:space:]]+from[[:space:]]+[^;"'\'']*[[:space:]]where([[:space:]]|\()' >/dev/null 2>&1; then
            matched_label="DELETE FROM without WHERE"
            matched_reason="Unqualified DELETE wipes every row in the table. Shared-state damage and not reversible without a backup."
            matched_suggestion="Add a WHERE clause, wrap the statement in a transaction you can ROLLBACK, or confirm with the user that a full-table delete is intended."
        fi
    fi
fi

# 9. Redirect to raw disk device:   > /dev/sdX   or  of=/dev/sdX / of=/dev/nvme / of=/dev/disk
if [[ -z "$matched_label" ]]; then
    match "write to raw disk device" \
          "Writing directly to a disk device destroys the filesystem and all data on it. Irreversible." \
          "Double-check the device path (lsblk), target a file/image instead, and ask the user to confirm the exact device." \
          "" \
          '(>[[:space:]]*/dev/(sd|nvme|hd|disk|mmcblk|vd)|(^|[[:space:]])dd[[:space:]]+[^#]*of=/dev/)' \
        && true
fi

# 10. mkfs (filesystem format)
if [[ -z "$matched_label" ]]; then
    match "mkfs (filesystem format)" \
          "Formats a partition/device, erasing all data on it. Irreversible." \
          "Confirm the target device with 'lsblk', and ask the user to re-issue the exact command after verification." \
          "" \
          '(^|[[:space:]])mkfs(\.[a-z0-9]+)?([[:space:]]|$)' \
        && true
fi

# 11. chmod -R 777 on broad paths (/, /etc, /usr, /var, /home, $HOME, ~, .)
if [[ -z "$matched_label" ]]; then
    match "chmod -R 777 on a broad path" \
          "Recursively opens permissions for every user on a sensitive or wide path. Hard to unwind cleanly; breaks security invariants." \
          "Target the minimal subpath, use a narrower mode (e.g. 755/644), or fix ownership instead. Ask the user to confirm." \
          "" \
          '(^|[[:space:]])chmod([[:space:]]+[^#]*)?[[:space:]]-R[[:space:]]+[0-7]*777[0-7]*[[:space:]]+(/|/etc|/usr|/var|/home|/opt|/srv|~|\$HOME|\.|\./)([[:space:]]|$|;|&)' \
        && true
fi

# 12. Classic fork bomb:  :(){ :|:& };:
if [[ -z "$matched_label" ]]; then
    if printf '%s' "$command_str" | grep -F -- ':(){ :|:& };:' >/dev/null 2>&1 \
       || printf '%s' "$command_str" | grep -E -- ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:[[:space:]]*&[[:space:]]*\}[[:space:]]*;[[:space:]]*:' >/dev/null 2>&1; then
        matched_label="fork bomb"
        matched_reason="Classic ':(){ :|:& };:' fork bomb. Will exhaust process table and hang the machine."
        matched_suggestion="There is no legitimate reason to run this. If you're testing resource limits, use a controlled sandbox/VM and ask the user first."
    fi
fi

# --- decide -----------------------------------------------------------------
if [[ -n "$matched_label" ]]; then
    {
        echo "BLOCKED: destructive command pattern detected: ${matched_label}"
        echo ""
        echo "Why: ${matched_reason}"
        echo ""
        echo "What to do:"
        echo "  - ${matched_suggestion}"
        echo "  - OR ask the user for explicit confirmation, quoting the exact command."
        echo "  - OR propose a reversible alternative (dry-run, staged, --force-with-lease, transactional, etc.)."
        echo ""
        echo "If the user has explicitly approved this exact command, you may re-issue it"
        echo "with the trailing comment '# CLAUDE_APPROVED_DESTRUCTIVE' to bypass this gate."
        echo ""
        echo "Blocked command was:"
        echo "  ${command_str}"
    } >&2
    exit 2
fi

exit 0
