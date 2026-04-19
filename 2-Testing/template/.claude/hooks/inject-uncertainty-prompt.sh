#!/usr/bin/env bash
set -euo pipefail

# Consume stdin (JSON payload) so the upstream pipe closes cleanly.
# We don't need to parse it; the preamble is static.
_payload=$(cat)
: "${_payload:=}"

# Emit the calibration lens. Claude Code prepends this to the user's
# prompt before the model sees the turn.
cat <<'EOF'
<calibration-lens>
Before acting on non-trivial work, run the user's request through this lens (internally; don't recite):
1. What do we know well enough?
2. What remains uncertain?
3. What cheap test reduces the most risk?
4. Is the next action reversible?
5. What would count as failure?
6. When do we escalate?
Trivial turns (greetings, one-line questions) can skip this and answer directly.
</calibration-lens>
EOF

exit 0
