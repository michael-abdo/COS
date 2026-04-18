---
name: fix-and-challenge
description: >
  Alternating fix/break loop for the disambiguate plugin. FIX phase: reads challenger findings,
  updates the /disambiguate SKILL.md to prevent those patterns, re-runs the plugin on trading,
  checks 3 gates. BREAK phase: challenges the output, writes findings. Converges when BREAK
  finds 0 issues. Use with /loop 25m /fix-and-challenge.
---

# Fix-and-Challenge Loop

Alternating phases that improve the /disambiguate plugin until its output can't be broken.

## State File

Read `/tmp/fix-and-challenge-state.json` to determine phase:

```json
{"iteration": 0, "phase": "fix", "findings_count": -1, "converged": false}
```

- If `phase == "fix"` → run FIX phase, then set phase to "break"
- If `phase == "break"` → run BREAK phase, then set phase to "fix"
- If `findings_count == 0` after a BREAK → set `converged: true`, STOP

## FIX Phase

1. **Read findings** from `/tmp/challenger-findings.md` (written by last BREAK phase)

2. **Identify patterns** in the findings — common failure types:
   - Sequential elif that skips downstream checks
   - Caller-controlled thresholds/params
   - Self-reported flags with no external validation
   - Empty input lists that silently pass
   - Single-trust-domain signals (all signals from same actor)
   - Missing category coverage (e.g., INFRASTRUCTURE)
   - Guards that report first-match instead of all violations

3. **Update the plugin SKILL.md** at:
   `/Users/Mike/2025-2030/Systems/cognitive-operating-system/cos-marketplace/plugins/disambiguate/skills/disambiguate/SKILL.md`

   Add rules to the appropriate phase that PREVENT the pattern from recurring:
   - Phase 3 (CLAIM): add rules about predicate structure
   - Phase 3.5 (COMPILE+FIDELITY): add rules about proxy quality
   - Phase 5 (DERIVE): add rules about guard code patterns

   Example rules to add:
   ```
   GUARD CODE RULES (added by fix-and-challenge loop):
   - NEVER use sequential elif for multi-signal checks. Use parallel evaluation
     that reports ALL violations, not first-match.
   - NEVER accept caller-controlled thresholds. All thresholds must be guard-internal
     constants or loaded from a read-only config the caller cannot modify.
   - NEVER use a single self-reported boolean as a proxy. Require at least one signal
     that the code PATH verifies (e.g., URL fetchable, hash matches file content).
   - ALWAYS check for empty input lists and reject as suspicious.
   - ALWAYS report ALL violations found, not just the first one.
   ```

4. **Re-run the plugin on trading** — specifically, regenerate the guards that had findings.
   For each guard with findings:
   - Read the updated SKILL.md rules
   - Read the L4 predicate
   - Regenerate the guard following the new rules
   - Regenerate the test
   - Run the test

5. **Check 3 gates:**
   - Gate 1: `cd /Users/Mike/2025-2030/Trading/refine4trading && export PATH="$HOME/.elan/bin:$PATH" && lake build 2>&1 | tail -3`
   - Gate 2: `.venv/bin/python -m pytest tests/ -q --tb=line 2>&1 | tail -3` (run in background, check later)
   - Gate 3: Verify no sequential elif, no caller-controlled params in the regenerated guards

6. **Update state:**
   ```json
   {"iteration": N+1, "phase": "break", "findings_count": -1, "converged": false}
   ```

7. **Report:** What findings were addressed, what rules were added to plugin, which guards regenerated, gate status.

## BREAK Phase

1. **Read the guards** that were regenerated in the last FIX phase.
   Guards dir: `/Users/Mike/2025-2030/Trading/refine4trading/guards/`

2. **For each guard, try to break it:**
   - Construct a CONCRETE input that satisfies all conditions while violating the L4 intent
   - Check for: elif bypasses, caller-controlled params, self-reported flags, empty lists, single-trust-domain
   - Check Lean predicate alignment
   - Check if the guard reports ALL violations or just first-match

3. **Write findings** to `/tmp/challenger-findings.md`:
   ```markdown
   # Challenger Findings — Iteration N

   ## Findings: X

   ### Finding 1: [guard name]
   - Pattern: [what's wrong]
   - Gaming input: [concrete input that passes guard but violates intent]
   - Severity: CRITICAL/HIGH/MEDIUM/LOW
   - Plugin rule needed: [what rule would prevent this]
   ```

4. **Count findings** and update state:
   ```json
   {"iteration": N, "phase": "fix", "findings_count": X, "converged": X == 0}
   ```

5. **If findings_count == 0:**
   Report: "✅ CONVERGED — no findings. Plugin produces sound guards. Stop the loop."

6. **If findings_count > 0:**
   Report: "Found X issues. Next FIX cycle will address them."

## Convergence

The loop converges when BREAK finds 0 issues. This means:
- Every guard reports ALL violations (no elif bypass)
- No guard accepts caller-controlled thresholds
- No guard relies solely on self-reported flags
- No guard silently passes on empty inputs
- Every guard matches its Lean predicate
- No concrete gaming input can be constructed

Maximum iterations: 10. If not converged after 10, flag for human review.
