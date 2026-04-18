#!/usr/bin/env bash
# PreToolUse hook: run Semgrep on the NEW content of a Write/Edit tool call
# (not the whole file) and block on ERROR-severity findings.
#
# Layer 1 of the principle-based security review stack. Targets:
#   1. Untrusted input -> shell/subprocess       (p/command-injection, p/security-audit)
#   2. Upload/temp file -> executable path       (p/security-audit, p/owasp-top-ten)
#   3. Root / broad privilege                    (p/security-audit, Dockerfile rules)
#   4. Secret exposure                           (handled by detect-secrets.sh; we DO NOT duplicate)
#   5. Low-trust path -> admin surface           (p/owasp-top-ten, p/insecure-transport)
#
# Protocol:
#   - Reads JSON on stdin.
#     Write: {"tool_name":"Write","tool_input":{"file_path":"...","content":"..."}}
#     Edit:  {"tool_name":"Edit","tool_input":{"file_path":"...","old_string":"...","new_string":"..."}}
#   - Exit 0: allow (clean, out-of-scope, tool missing, or timed out).
#   - Exit 2: block; stderr surfaced to Claude as feedback.
#   - Exit 1: non-blocking tooling error (e.g. jq missing).
#
# Override: literal substring "# CLAUDE_APPROVED_DESTRUCTIVE" bypasses this gate.

set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
    echo "semgrep-review.sh: 'jq' is required but not found in PATH." >&2
    exit 1
fi

payload="$(cat)"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"

case "$tool_name" in
    Write|Edit) ;;
    *) exit 0 ;;
esac

file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"

case "$tool_name" in
    Write)
        scan_text="$(printf '%s' "$payload" | jq -r '.tool_input.content // empty')"
        ;;
    Edit)
        scan_text="$(printf '%s' "$payload" | jq -r '.tool_input.new_string // empty')"
        ;;
esac

if [[ -z "$scan_text" ]]; then
    exit 0
fi

if [[ "$scan_text" == *"# CLAUDE_APPROVED_DESTRUCTIVE"* ]]; then
    exit 0
fi

basename_lc="$(basename "$file_path" | tr '[:upper:]' '[:lower:]')"
ext="${file_path##*.}"
ext_lc="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

tmp_ext=""
case "$basename_lc" in
    dockerfile)                 tmp_ext="Dockerfile" ;;
    docker-compose.yml|docker-compose.yaml) tmp_ext="yml" ;;
esac

if [[ -z "$tmp_ext" ]]; then
    case ".$ext_lc" in
        .py|.js|.jsx|.ts|.tsx|.go|.rb|.java|.rs|.php|.scala|.kt|.swift|.m|.cs|.c|.cpp|.h|.hpp)
            tmp_ext="$ext_lc"
            ;;
        *)
            exit 0
            ;;
    esac
fi

if ! command -v semgrep >/dev/null 2>&1; then
    echo "semgrep-review.sh: 'semgrep' not found in PATH; skipping security scan. Install with: pip install semgrep" >&2
    exit 0
fi

tmpdir="$(mktemp -d -t semgrep-review.XXXXXX)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT INT TERM

if [[ "$tmp_ext" == "Dockerfile" ]]; then
    tmpfile="$tmpdir/Dockerfile"
else
    tmpfile="$tmpdir/snippet.$tmp_ext"
fi

printf '%s' "$scan_text" > "$tmpfile"

semgrep_output="$(
    timeout 20 semgrep \
        --config=p/owasp-top-ten \
        --config=p/security-audit \
        --config=p/command-injection \
        --config=p/insecure-transport \
        --json \
        --severity ERROR \
        --timeout 15 \
        --no-git-ignore \
        --quiet \
        --disable-version-check \
        --metrics=off \
        -- "$tmpfile" 2>/dev/null
)"
rc=$?

if [[ $rc -eq 124 ]]; then
    echo "semgrep-review.sh: semgrep timed out after 20s on $file_path; skipping (not blocking)." >&2
    exit 0
fi

if [[ -z "$semgrep_output" ]]; then
    echo "semgrep-review.sh: semgrep produced no output on $file_path (rc=$rc); skipping." >&2
    exit 0
fi

if ! printf '%s' "$semgrep_output" | jq -e . >/dev/null 2>&1; then
    echo "semgrep-review.sh: semgrep output not valid JSON (rc=$rc); skipping." >&2
    exit 0
fi

result_count="$(printf '%s' "$semgrep_output" | jq -r '.results | length')"

if [[ "$result_count" == "0" ]]; then
    exit 0
fi

{
    echo "semgrep-review.sh: BLOCKED — Semgrep found $result_count ERROR-severity finding(s) in the proposed change to $file_path."
    echo ""
    printf '%s' "$semgrep_output" | jq -r '
        .results[]
        | "  - rule_id: \(.check_id)\n    line:    \(.start.line)\n    message: \(.extra.message | gsub("\n"; " ") | .[:240])"
    '
    echo ""
    echo "Line numbers are relative to the proposed new content."
    echo ""
    echo "Revise the code to address each finding before retrying the Write/Edit."
    echo "Typical fixes:"
    echo "  - Pass untrusted input as argv list, never as a shell string (subprocess.run([...], shell=False))."
    echo "  - Validate/allowlist filenames before exec; never execute upload paths directly."
    echo "  - Drop privileges before running user-influenced work; don't USER root in Dockerfiles."
    echo "  - Use HTTPS and verify certs; never disable TLS verification."
    echo ""
    echo "If this is a deliberate, reviewed exception, add the literal comment"
    echo "  # CLAUDE_APPROVED_DESTRUCTIVE"
    echo "to the content and retry. That marker requires fresh user consent per CLAUDE.md."
} >&2

exit 2
