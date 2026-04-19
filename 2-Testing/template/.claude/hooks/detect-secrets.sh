#!/usr/bin/env bash
# PreToolUse hook: block Write / Edit / Bash tool calls whose content or
# command contains secret-shaped data (API keys, tokens, private keys,
# .env contents), or which would exfiltrate data to an un-allowlisted
# destination.
#
# Protocol:
#   - Reads JSON on stdin.
#     Write: {"tool_name":"Write","tool_input":{"file_path":"...","content":"..."}}
#     Edit:  {"tool_name":"Edit","tool_input":{"file_path":"...","old_string":"...","new_string":"...","replace_all":false}}
#     Bash:  {"tool_name":"Bash","tool_input":{"command":"...","description":"..."}}
#   - Exit 0: allow.
#   - Exit 2: block; stderr is surfaced to Claude as feedback.
#   - Exit 1: non-blocking tooling error (e.g. jq missing).
#
# Override: the literal substring "# CLAUDE_APPROVED_DESTRUCTIVE" anywhere
# in the content/command bypasses this gate. (Same marker as the destructive
# bash hook, for consistency.)

# NOTE: intentionally NOT using `-e`. We must never abort before writing
# feedback to stderr when we block.
set -uo pipefail

# --- dependency check -------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
    echo "detect-secrets.sh: 'jq' is required but not found in PATH." >&2
    exit 1
fi

# --- parse input ------------------------------------------------------------
payload="$(cat)"

tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"

# If this script is invoked for a tool we don't handle, allow silently.
case "$tool_name" in
    Write|Edit|Bash) ;;
    *) exit 0 ;;
esac

file_path=""
scan_text=""
command_str=""

case "$tool_name" in
    Write)
        file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
        scan_text="$(printf '%s' "$payload" | jq -r '.tool_input.content // empty')"
        ;;
    Edit)
        file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
        # Only scan new_string; we don't care what was already there.
        scan_text="$(printf '%s' "$payload" | jq -r '.tool_input.new_string // empty')"
        ;;
    Bash)
        command_str="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')"
        scan_text="$command_str"
        ;;
esac

# Nothing to scan -> allow.
if [[ -z "$scan_text" && -z "$command_str" ]]; then
    exit 0
fi

# --- explicit override ------------------------------------------------------
# Same marker as block-destructive-bash.sh for consistency. The user must
# deliberately type this literal substring to bypass scanning.
if [[ "$scan_text" == *"# CLAUDE_APPROVED_DESTRUCTIVE"* ]]; then
    exit 0
fi
if [[ -n "$command_str" && "$command_str" == *"# CLAUDE_APPROVED_DESTRUCTIVE"* ]]; then
    exit 0
fi

# --- test / fixture carve-out detection -------------------------------------
# For Write/Edit: if the file_path is under tests/, fixtures/, __mocks__/ or
# ends in .example/.sample, we still scan but allow matches whose captured
# value is a recognized canonical fake.
is_fixture_path=0
case "$file_path" in
    */tests/*|*/test/*|*/fixtures/*|*/__mocks__/*|*.example|*.sample|*.example.*|*.sample.*)
        is_fixture_path=1
        ;;
esac

# A matched value is considered "fake" if it matches any of these.
# Used only when is_fixture_path=1.
#
# We inspect both the full match AND, for labelled assignments
# (`FOO=bar`, `FOO: bar`), the value portion after the separator, since
# placeholder prefixes like `fake_` / `dummy_` land on the right-hand side.
is_canonical_fake() {
    local v="$1"

    # Explicit "DO_NOT_USE" / "EXAMPLE" / "FAKE" / "DUMMY" sentinels
    # anywhere (case-insensitive) in the full match.
    local upper
    upper="$(printf '%s' "$v" | tr '[:lower:]' '[:upper:]')"
    if [[ "$upper" == *EXAMPLE* || "$upper" == *DO_NOT_USE* \
       || "$upper" == *FAKE* || "$upper" == *DUMMY* \
       || "$upper" == *PLACEHOLDER* || "$upper" == *XXXXXXXX* ]]; then
        return 0
    fi

    # AWS canonical example key.
    if [[ "$v" == "AKIAIOSFODNN7EXAMPLE" ]]; then return 0; fi

    # Extract the right-hand side of an assignment if present, and test
    # its prefix against the common placeholder prefixes.
    local rhs="$v"
    # Strip leading "KEY=" or "KEY:" (with optional whitespace/quotes).
    rhs="${rhs#*[=:]}"
    rhs="${rhs# }"
    rhs="${rhs#\"}"
    rhs="${rhs#\'}"
    local lower
    lower="$(printf '%s' "$rhs" | tr '[:upper:]' '[:lower:]')"
    case "$lower" in
        dummy_*|dummy-*|fake_*|fake-*|test_*|test-*|example_*|example-*|xxxxxxxx*|placeholder*)
            return 0
            ;;
    esac

    return 1
}

# --- secret pattern scanning ------------------------------------------------
# Each pattern: a human label and an ERE. We scan `scan_text` with grep -Eo
# to extract the actual matched value, so we can redact it in the message.

matched_label=""
matched_value=""
matched_via_fixture_carveout=0

# redact: show first 6 + "..." + last 4 of the matched secret.
redact() {
    local v="$1"
    local n=${#v}
    if (( n <= 12 )); then
        printf '<REDACTED:len=%d>' "$n"
        return
    fi
    printf '%s...%s' "${v:0:6}" "${v: -4}"
}

# scan_pattern <label> <grep-flags> <regex>
# On hit, sets matched_label and matched_value (first hit wins).
scan_pattern() {
    local label="$1" flags="$2" regex="$3"
    [[ -n "$matched_label" ]] && return 0
    local hit
    hit="$(printf '%s' "$scan_text" | grep -Eo $flags -- "$regex" 2>/dev/null | head -n1 || true)"
    if [[ -n "$hit" ]]; then
        if (( is_fixture_path == 1 )) && is_canonical_fake "$hit"; then
            matched_via_fixture_carveout=1
            return 0
        fi
        matched_label="$label"
        matched_value="$hit"
    fi
}

# ---- precise high-signal patterns -----------------------------------------

# AWS access key ID (long-term and temporary).
scan_pattern "AWS access key ID" "" '(AKIA|ASIA)[0-9A-Z]{16}'

# GitHub personal access token (and friends: oauth, user, server, refresh).
scan_pattern "GitHub PAT / OAuth token" "" 'gh[pousr]_[A-Za-z0-9]{36,}'

# Google API key.
scan_pattern "Google API key" "" 'AIza[0-9A-Za-z_\-]{35}'

# Slack token: xoxb / xoxp / xoxa / xoxr (bot/user/app/refresh).
scan_pattern "Slack token" "" 'xox[abpr]-[0-9A-Za-z-]{10,}'

# Stripe live keys.
scan_pattern "Stripe live secret key" "" 'sk_live_[0-9a-zA-Z]{24,}'
scan_pattern "Stripe live publishable key" "" 'pk_live_[0-9a-zA-Z]{24,}'

# JWT: three base64url segments separated by dots, starting with eyJ...
scan_pattern "JWT-shaped token" "" 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'

# PEM private key header.
scan_pattern "RSA/EC/DSA/OpenSSH/PGP private key (PEM block)" "" '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP |ENCRYPTED |)PRIVATE KEY-----'

# AWS secret access key by label (the value is 40 chars of base64-ish).
scan_pattern "AWS secret access key (labelled)" "-i" 'aws(_|-)?secret(_|-)?access(_|-)?key[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+=]{40}["'"'"']?'

# Generic .env-style secret assignment with a long-enough opaque value.
# Matches: KEY=value, KEY: value, optional surrounding quotes.
# The "secret-shaped" value is >=16 chars of [A-Za-z0-9+/=_-].
scan_pattern ".env-style assignment with secret-looking value" "-i" \
    '(password|passwd|secret|token|api[_-]?key|access[_-]?key|private[_-]?key|auth[_-]?token|bearer[_-]?token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9+/=_\-]{16,}["'"'"']?'

# --- Bash-specific exfiltration gating --------------------------------------
# For Bash only: if the command *looks* like an outbound transfer to an
# un-allowlisted destination, treat it as suspicious.

exfil_reason=""

if [[ "$tool_name" == "Bash" ]]; then
    # git push destination check.
    if printf '%s' "$command_str" | grep -Eq -- '(^|[[:space:]])git[[:space:]]+push([[:space:]]|$)'; then
        # Extract the remote name (first non-flag token after `git push`).
        # Default remote is "origin" if none specified.
        remote_name="$(printf '%s' "$command_str" \
            | grep -Eo -- 'git[[:space:]]+push[[:space:]]+[^[:space:];&|]+' \
            | head -n1 \
            | awk '{print $3}')"
        # Strip leading flags like "-u" / "--set-upstream".
        case "$remote_name" in
            -*|"") remote_name="origin" ;;
        esac

        # Resolve the remote URL if possible (bounded time).
        remote_url=""
        if command -v git >/dev/null 2>&1; then
            remote_url="$(timeout 2 git -C "${CLAUDE_PROJECT_DIR:-.}" remote get-url "$remote_name" 2>/dev/null || true)"
        fi

        allow_file="${CLAUDE_PROJECT_DIR:-.}/.claude/allowed-remotes.txt"
        allowed=0
        if [[ -n "$remote_url" ]]; then
            if [[ -f "$allow_file" ]]; then
                # A line matches if the remote URL starts with it (prefix match),
                # ignoring blank lines and comments.
                while IFS= read -r line || [[ -n "$line" ]]; do
                    line="${line%%$'\r'}"
                    [[ -z "$line" || "$line" == \#* ]] && continue
                    if [[ "$remote_url" == "$line"* ]]; then
                        allowed=1
                        break
                    fi
                done < "$allow_file"
            else
                # Safe default: allow only `origin`, and only if the host
                # resolves (we already have origin's URL, so trust it).
                if [[ "$remote_name" == "origin" ]]; then
                    allowed=1
                fi
            fi
        else
            # Couldn't resolve the URL: unknown remote, don't auto-allow.
            allowed=0
        fi

        if (( allowed == 0 )); then
            exfil_reason="git push to non-allowlisted remote '${remote_name}'${remote_url:+ ($remote_url)}"
        fi
    fi

    # Outbound transfer tools that *could* ship secrets. We don't block them
    # outright unless they match the classic base64-pipe-to-network exfil
    # idiom. Secret-pattern matches above are the main gate for curl/wget/gh.
    if [[ -z "$exfil_reason" ]]; then
        if printf '%s' "$command_str" \
            | grep -Eq -- '(base64|openssl[[:space:]]+enc)[^|]*\|[[:space:]]*(curl|wget|nc)[[:space:]]+[^|]*https?://'; then
            exfil_reason="base64-pipe-to-network idiom (classic exfiltration shape)"
        fi
    fi
fi

# --- decide -----------------------------------------------------------------
# Priority: if we matched a secret pattern, block regardless of destination.
# Otherwise, if we flagged an exfil destination, block.

if [[ -n "$matched_label" ]]; then
    redacted="$(redact "$matched_value")"
    context_label=""
    excerpt=""
    case "$tool_name" in
        Write|Edit)
            context_label="file"
            excerpt="${file_path:-<unknown>}"
            ;;
        Bash)
            context_label="command"
            # Show the command with the secret redacted.
            cmd_redacted="${command_str//"$matched_value"/"$redacted"}"
            excerpt="${cmd_redacted}"
            ;;
    esac

    {
        echo "BLOCKED: secret-shaped data detected: ${matched_label}"
        echo ""
        echo "Where: ${context_label}: ${excerpt}"
        echo "Matched value (redacted): ${redacted}"
        if [[ -n "$exfil_reason" ]]; then
            echo "Exfiltration vector: ${exfil_reason}"
        fi
        echo ""
        echo "What to do:"
        echo "  - Move the value to an environment variable or a secret store"
        echo "    (e.g. read from \$ENV_VAR, 1Password CLI, AWS Secrets Manager,"
        echo "    Vault, etc.) and reference it indirectly."
        echo "  - Do NOT commit the literal value. If it was ever present in git"
        echo "    history, consider it compromised and rotate it."
        echo "  - If this is test/fixture data, place it under tests/, fixtures/,"
        echo "    or __mocks__/, and use a canonical fake value such as"
        echo "    'AKIAIOSFODNN7EXAMPLE', 'dummy_...', 'fake_...', 'test_...',"
        echo "    or a name containing 'EXAMPLE' / 'DO_NOT_USE'."
        echo "  - If the user has explicitly authorized THIS EXACT value, you may"
        echo "    re-issue the call with the literal substring"
        echo "    '# CLAUDE_APPROVED_DESTRUCTIVE' in the content/command to bypass"
        echo "    this gate. (Reused marker from the destructive-bash hook.)"
    } >&2
    exit 2
fi

if [[ -n "$exfil_reason" ]]; then
    {
        echo "BLOCKED: outbound transfer to non-allowlisted destination: ${exfil_reason}"
        echo ""
        echo "Command was:"
        echo "  ${command_str}"
        echo ""
        echo "What to do:"
        echo "  - If the destination is legitimate, add its URL (or URL prefix) to"
        echo "    \$CLAUDE_PROJECT_DIR/.claude/allowed-remotes.txt (one per line)."
        echo "  - If this is a new remote, ask the user to confirm the exact"
        echo "    destination before pushing."
        echo "  - If the user has explicitly approved this push, re-issue with"
        echo "    '# CLAUDE_APPROVED_DESTRUCTIVE' appended to bypass."
    } >&2
    exit 2
fi

# If we suppressed a match because of the fixture carve-out, note it on
# stderr but allow. Claude sees this as informational only.
if (( matched_via_fixture_carveout == 1 )); then
    echo "detect-secrets.sh: allowed -- matched value was a canonical fake in a test/fixture path (${file_path})." >&2
fi

exit 0
