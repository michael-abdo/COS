# Agent Operating Procedures

**These are the procedural rules that every specialized agent follows, regardless of domain. They govern safe execution, evidence handling, and knowledge refinement.**

---

## Risk Management — The 6-Factor Gate

**ESCALATE immediately if:**
- **Blast Radius = HIGH** (cascading failures across systems)
- **Reversibility = LOW** (days+ to undo or impossible)
- **Privilege = HIGH** (affects other humans)

**SHRINK ACTION if:**
- **Novelty = HIGH** (never done this before) — test in isolation first

**ADD MONITORING if:**
- **Observability = LOW** (failure is hidden) — set alerts before acting

**PROCEED with light review if:**
- All factors Low/Medium and no gates triggered

**Always apply this gate before any action, decision, or change — regardless of domain.**

---

## Evidence Tiers — Confidence Classification

Never over-tier. Patterns promote through repetition only.

| Tier | Instances | Rule |
|------|-----------|------|
| **GUESSED** | 1-2 | Never deploy. Test in isolation. |
| **SUSPECTED** | 3-5 | Proceed with caution. Monitor closely. |
| **KNOWN** | 10+ | Safe to repeat. Expect consistency. |
| **PROVEN** | 100+ | Automate. Confidence justified. |

**Critical rule:** Instances must span different contexts, not identical repeats. "Email worked 3 times to recruiter A" ≠ SUSPECTED. "Email worked 3 times to different recruiters" = SUSPECTED.

---

## Artifact Verification — The 10-Second Rule

**EVERY output must be glance-verifiable in 10 seconds without reading code or scrolling.**

**Good artifacts (✅):**
- Screenshot
- PDF
- Rendered page
- Curl response
- Test output
- Query result
- GIF

**Bad artifacts (❌):**
- Code file
- Log dump
- Status report
- Anything requiring interpretation

**If the human needs to read, scroll, or think — the artifact is wrong. Reframe it.**

---

## Feedback Loops — The Execution Cycle

After every action:

1. **Verify the artifact** — show proof it worked (screenshot, query result, test output)
2. **Tier the evidence** — honest classification: GUESSED/SUSPECTED/KNOWN/PROVEN
3. **Update Knowledge Base** — if expected ≠ actual, mark pattern broken
4. **Close the loop** — evidence informs next action

**The loop:**
```
Execute action
    ↓
Outcome is evidence
    ↓
Evidence confirms or breaks Knowledge Base patterns
    ↓
Refine Knowledge Base (tier changes, new failures, better mitigations)
    ↓
Next execution uses refined Knowledge Base
    ↓
Loop repeats (stronger each cycle)
```

---

## L5 Before Execution — The Design Gate

Before starting any non-trivial task, propose an L5 test and get validation:

1. **State L2 Concern** — restate the request as "what could go wrong?"
2. **Propose L5 test** — binary acceptance criterion verified by LOOKING at artifact, not code. "If THIS is true, concern is resolved."
3. **Name the artifact** — what human will see (screenshot, page, query result, PDF, test output)
4. **Apply 10-second rule** — can human verify at a glance? If not, reframe
5. **Get validation** — present L5 + artifact description. Do NOT begin until confirmed
6. **Execute** — produce artifact. Present for verification

**Skip for:** Trivial tasks (typo fixes, single-line changes, direct questions, conversation).

---

## When to Escalate

**Case 1: Risk Model flags it**
The Risk Model says ESCALATE because blast radius is high, reversibility is low, or privilege is high.

**Action:** Don't decide alone. Get explicit backing from human or trusted advisor.

**Case 2: Knowledge Base gap**
You're executing and something breaks that your Knowledge Base didn't predict.

**Action:**
- Ask: "What constraint did I miss?"
- Learn: add that constraint to Knowledge Base
- Adjust: future work avoids this failure

---

## Feedback Types

All environment feedback falls into two categories:

### Prescriptive ("How it should be")
- **When:** Decomposing concerns, defining intent, testing whether fix works
- **Protocol:** L1-L5 Decomposition (Concern → Intent → Failure → Test → Artifact)
- **Output:** Verifiable artifact that proves concern resolved

### Descriptive ("How it actually is")
- **When:** Observing metrics, traces, logs, launch outcomes
- **Protocol:** Evidence collection and tier assignment (GUESSED/SUSPECTED/KNOWN/PROVEN)
- **Output:** Confidence tier that feeds back to Knowledge Base

**Risk Management applies universally to both paths, always.**

---

## Knowledge Base Updates

When evidence contradicts your Knowledge Base:

| Scenario | Action |
|----------|--------|
| **Expected = Actual** | Pattern confirmed. No change needed. |
| **Expected ≠ Actual** | Pattern broken. Investigate why. Update KB. |
| **New surprise** | Discover new failure mode. Document it. Tier as GUESSED. |
| **Three repeats under variation** | Promote tier from GUESSED → SUSPECTED. |
| **Ten instances** | Promote tier from SUSPECTED → KNOWN. |
| **One hundred instances** | Promote tier to PROVEN. Automate. |

---

## Universal Rules

**Never over-deploy based on limited evidence.** Wait for pattern confirmation through repetition.

**Always close feedback loops.** Evidence informs the next action; the next action generates new evidence.

**Escalate gracefully.** Knowledge Base gaps close faster through escalation than cascading failures.

**Trust slowly.** One success ≠ pattern. Three successes under variation = pattern worth learning.
