#!/usr/bin/env bash
# PreToolUse hook: blocks Bash commands whose strings look like they target production,
# unless the session has been explicitly authorized via CLAUDE_PROD_AUTHORIZED env var
# or the # CLAUDE_APPROVED_DESTRUCTIVE in-line marker.
set -uo pipefail

payload="$(cat 2>/dev/null || true)"

if ! command -v jq >/dev/null 2>&1; then
  echo "detect-prod: jq not found; cannot parse payload" >&2
  exit 1
fi

tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || true)"
if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
if [ -z "$cmd" ]; then
  exit 0
fi

# Override 1: in-line marker
case "$cmd" in
  *"# CLAUDE_APPROVED_DESTRUCTIVE"*)
    echo "info: detect-prod override via # CLAUDE_APPROVED_DESTRUCTIVE marker" >&2
    exit 0
    ;;
esac

# Override 2: environment authorization
if [ -n "${CLAUDE_PROD_AUTHORIZED:-}" ]; then
  echo "info: detect-prod override via CLAUDE_PROD_AUTHORIZED=${CLAUDE_PROD_AUTHORIZED}" >&2
  # Still scan so we log what it caught — but exit 0 regardless.
  exit 0
fi

# Patterns. Each is a regex (ERE) tested against $cmd. First match wins.
# The key guard: "prod" must appear as a distinct segment, not inside a longer word
# like /productivity. We look for prod bounded by non-alphanumeric chars or specific
# prefixes/suffixes known to indicate production.
#
# Pattern format: "<label>|<regex>"
patterns=(
  # Hostnames / URLs with prod in a recognizable segment
  "hostname segment 'prod'|(^|[^a-zA-Z0-9])((api|app|db|auth|cache|queue|web|internal|admin)[.-])?prod(uction)?[.-][a-zA-Z0-9.-]+"
  "hostname segment 'live'|(^|[^a-zA-Z0-9])(api|app|db|auth|cache|queue|web|internal|admin)[.-]live[.-][a-zA-Z0-9.-]+"
  "subdomain *.prod.*|[a-zA-Z0-9-]+\.prod\.[a-zA-Z0-9.-]+"
  "prefix prod-*|(^|[^a-zA-Z0-9_])prod-[a-zA-Z0-9_-]+"
  "prefix production-*|(^|[^a-zA-Z0-9_])production-[a-zA-Z0-9_-]+"

  # DB connection strings
  "database URL containing prod|(postgres|postgresql|mysql|mongodb|redis|clickhouse|mssql)://[^[:space:]]*prod[^[:space:]]*"

  # kubectl / helm with prod contexts
  "kubectl --context prod*|kubectl[[:space:]]+([^[:space:]]+[[:space:]]+)*--context[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"
  "kubectl config use-context prod*|kubectl[[:space:]]+config[[:space:]]+use-context[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"
  "helm --kube-context prod*|helm[[:space:]]+([^[:space:]]+[[:space:]]+)*--kube-context[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"

  # Cloud CLIs with prod profiles / projects
  "aws --profile prod*|aws[[:space:]]+([^[:space:]]+[[:space:]]+)*--profile[[:space:]]+[\"']?(prod|production)[a-zA-Z0-9._-]*"
  "gcloud --project *-prod*|gcloud[[:space:]]+([^[:space:]]+[[:space:]]+)*--project[[:space:]]+[\"']?[a-zA-Z0-9-]+-prod([a-zA-Z0-9-]*)"
  "gcloud config set project *-prod*|gcloud[[:space:]]+config[[:space:]]+set[[:space:]]+project[[:space:]]+[\"']?[a-zA-Z0-9-]+-prod"
  "az --subscription *prod*|az[[:space:]]+([^[:space:]]+[[:space:]]+)*--subscription[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"

  # AWS ARN with prod
  "ARN with prod|arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]*:[^[:space:]]*prod[^[:space:]]*"

  # Terraform / Pulumi workspace switches
  "terraform workspace select prod*|terraform[[:space:]]+workspace[[:space:]]+(select|new)[[:space:]]+[\"']?prod[a-zA-Z0-9._-]*"
  "pulumi stack select prod*|pulumi[[:space:]]+stack[[:space:]]+(select|init)[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"

  # SSH / SCP / rsync targeting prod
  "ssh to prod host|ssh[[:space:]]+([^[:space:]]+[[:space:]]+)*[\"']?([a-zA-Z0-9_-]+@)?prod-[a-zA-Z0-9.-]+"
  "ssh to *.prod.* host|ssh[[:space:]]+([^[:space:]]+[[:space:]]+)*[\"']?([a-zA-Z0-9_-]+@)?[a-zA-Z0-9.-]+\.prod\.[a-zA-Z0-9.-]+"
  "scp to prod host|scp[[:space:]]+([^[:space:]]+[[:space:]]+)*[^[:space:]]+[[:space:]]+([a-zA-Z0-9_-]+@)?prod-[a-zA-Z0-9.-]+:"
  "rsync to prod host|rsync[[:space:]]+([^[:space:]]+[[:space:]]+)*[^[:space:]]+[[:space:]]+([a-zA-Z0-9_-]+@)?prod-[a-zA-Z0-9.-]+:"

  # DB dump/restore at prod DSN
  "pg_dump at prod|pg_dump[[:space:]]+[^[:space:]]*prod[^[:space:]]*"
  "mysqldump at prod|mysqldump[[:space:]]+([^[:space:]]+[[:space:]]+)*[^[:space:]]*prod[^[:space:]]*"
  "mongodump --uri prod|mongodump[[:space:]]+([^[:space:]]+[[:space:]]+)*--uri[[:space:]]+[\"']?[^\"' ]*prod[^\"' ]*"
)

matched_label=""
matched_snippet=""

for entry in "${patterns[@]}"; do
  label="${entry%%|*}"
  regex="${entry#*|}"
  if [[ "$cmd" =~ $regex ]]; then
    matched_label="$label"
    # Extract the matched substring for the error message.
    matched_snippet="${BASH_REMATCH[0]}"
    # Redact common embedded secrets defensively.
    matched_snippet="$(printf '%s' "$matched_snippet" | sed -E 's/(AKIA|ASIA)[A-Z0-9]{16}/<REDACTED>/g; s/gh[pousr]_[A-Za-z0-9]{36,}/<REDACTED>/g; s/([Bb]earer )[A-Za-z0-9._-]{20,}/\1<REDACTED>/g')"
    break
  fi
done

if [ -z "$matched_label" ]; then
  exit 0
fi

cat >&2 <<EOF
[BLOCK] detect-prod hook: command looks like it targets production.

Matched pattern: $matched_label
Matched segment: $matched_snippet

Production-looking commands are blocked by default because the #2 category of
engineering-terminating incidents is "ran against prod thinking it was staging."

To proceed, one of:

  1. Propose a staging-shaped alternative (substitute the hostname/context/profile).
  2. Have the user authorize this session for prod work by setting in their shell
     BEFORE starting Claude Code:

        export CLAUDE_PROD_AUTHORIZED="<ticket-or-reason>"

     Then \`unset CLAUDE_PROD_AUTHORIZED\` when the prod work is done.

  3. For a one-off, append the in-line marker to the command (single command only,
     not session-wide):

        <command> # CLAUDE_APPROVED_DESTRUCTIVE

     Use sparingly — this bypasses BOTH the destructive-bash and prod-detection
     gates for this one invocation.

When authorized, the command is still logged with the authorization reason, so
there is a receipt showing who opened the session to prod and why.
EOF

exit 2
