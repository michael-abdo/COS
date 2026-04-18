---
name: dispatch
description: Dispatch workstreams to isolated worktrees with tmux windows and Claude sessions
user-invocable: true
---

# /dispatch — Spin up isolated workstreams

Parse the user's input into discrete workstreams. Before dispatching, confirm each workstream's COS L5 test with the user. Then execute.

## Phase 1: Parse & Confirm L5 Tests (BLOCKING — do not dispatch until confirmed)

Parse each distinct concern/project/feature into:

- **name**: short kebab-case identifier (e.g., `phantom-volume`, `deploy-pipeline`)
- **branch**: git branch name (e.g., `phantom-volume-backtest`, `feature/deploy-pipeline`)
- **L2 Concern**: what could go wrong / what needs to change (one sentence)
- **L5 Test**: binary acceptance criterion — how do we know this workstream is DONE? (one sentence)
- **Artifact**: what the human will look at to verify (screenshot, test output, curl response, etc.)
- **prompt**: the full context description INCLUDING the L5 test, so the dispatched agent knows its exit condition

Present the worktree root and ALL workstreams in a table:

```
📁 Worktree root: {WORKTREE_ROOT}/
```

| # | Name | Branch | L2 Concern | L5 Test | Artifact |
|---|------|--------|-----------|---------|----------|
| 1 | ... | ... | ... | ... | ... |

**Wait for the user to confirm or adjust.** Do NOT proceed to Phase 2 until the user says yes.

The L5 test MUST be included in each agent's prompt so the dispatched Claude session knows exactly what "done" looks like and can self-verify.

## Phase 2: Dispatch (after L5 confirmation)

For each workstream:

### Step 0: Determine worktree root

All worktrees for a dispatch MUST live in the same parent directory. Derive the root from the current repo:

```
# Use the current repo's parent directory + repo name as prefix
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
REPO_PARENT=$(dirname "$(git rev-parse --show-toplevel)")
WORKTREE_ROOT="${REPO_PARENT}/${REPO_NAME}-worktrees"
```

For example, if dispatching from `/Users/Mike/2025-2030/Systems/vm-claude`:
- `WORKTREE_ROOT=/Users/Mike/2025-2030/Systems/vm-claude-worktrees`
- Worktrees: `vm-claude-worktrees/phantom-volume/`, `vm-claude-worktrees/deploy-pipeline/`, etc.

Include the worktree root in the Phase 1 confirmation so the user can see where everything will land.

### Step 1: Branch

```
# Check if branch exists
git branch --list "{branch}" | grep -q . || git branch "{branch}" main
```

### Step 2: Worktree

```
WORKTREE_PATH="${WORKTREE_ROOT}/{name}"
if [ ! -d "$WORKTREE_PATH" ]; then
    git worktree add "$WORKTREE_PATH" "{branch}"
fi
```

### Step 3: Tmux Window

```
# Create window in current session, cd to worktree
tmux new-window -n "{name}" -c "$WORKTREE_PATH"
```

### Step 4: Launch Claude

```
# Send the claude launch command to the new tmux window
tmux send-keys -t "{name}" "claude --dangerously-skip-permissions \"{prompt}\"" Enter
```

### Step 5: Start monitoring loop

After ALL workstreams are dispatched, start a `/loop` that periodically checks each tmux window for progress. The loop should:

1. Capture the last ~20 lines of each tmux pane (`tmux capture-pane -t "{name}" -p | tail -20`)
2. Classify each workstream's status: 🔄 in-progress, ✅ done (L5 met), ❌ blocked, 💤 idle
3. Present a summary table to the user
4. If any workstream is blocked or idle, flag it for attention
5. If all workstreams show ✅, stop the loop

Default interval: 5 minutes. Use `/loop 5m` with a prompt that checks all dispatched windows.

```
# Example loop prompt
/loop 5m "Check all dispatched workstreams by running: tmux capture-pane -t {name} -p | tail -20 for each window ({name1}, {name2}, ...). Summarize status in a table with columns: Name, Status, Last Activity. Flag any that are blocked or idle."
```

## Important Notes

- Always check if worktree/branch already exists before creating
- Use the current tmux session (don't create a new one)
- The prompt sent to each Claude session should include ALL context the user provided for that workstream — not just a summary
- Include relevant memory references (e.g., "See memory/trading_phantom_volume.md")
- Rename the current window to match its workstream if the user is already working on one
- After dispatching, list all windows with their branches and paths
- If `--chrome` flag is needed, include it in the claude command

## Example

User says:

> I want to work on three things:
>
> 1. Phantom volume — run the backtest without phantom volume, compare metrics
> 2. Deploy pipeline — generalize the live pipeline for any strategy
> 3. Live monitoring — fix the alert spam issue

**Phase 1 output (present to user for confirmation):**

| # | Name | L2 Concern | L5 Test | Artifact |
|---|------|-----------|---------|----------|
| 1 | phantom-volume | Phantom volume may inflate backtest metrics, hiding real performance | Backtest runs with and without phantom volume produce comparison table; Sharpe/drawdown delta is visible | Terminal output showing side-by-side metrics |
| 2 | deploy-pipeline | Pipeline is hardcoded to one strategy, blocking multi-strategy deployment | `./deploy.sh <any-strategy>` succeeds for 2+ different strategies | Terminal output of two successful deploys |
| 3 | live-monitoring | Alert spam drowns real signals, causing alert fatigue | Run for 1hr with production data; alert count drops >50% while no real signals are missed | Before/after alert count comparison |

User confirms → **Phase 2: dispatch** creates worktrees, tmux windows, and Claude sessions. Each agent's prompt includes its L5 test as the exit condition.
