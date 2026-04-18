# Skill: Concern-to-Intent (L1-L5 Decomposition)

## When to use
Before creative work, building features, or writing code. When a request is fuzzy, vague, or you're unsure what "done" looks like.

## What it does
Transforms a fuzzy concern into a binary test. Removes ambiguity by decomposing from L2 (threat) → L5 (verifiable artifact).

## Steps

1. **State L2 Concern** — restate request as "what could go wrong?" (e.g., "What if wrong candidates advance and waste time?")

2. **Derive L3 Intent** — what invariant prevents the threat? Must be universal: "Every/All/Always X has Y" (e.g., "All applications must hit 3+ of 5 required signals")

3. **Derive L4 Failure** — logical NOT of Intent. Mechanical, not creative: "There exists [X] where NOT([intent])" (e.g., "Some applications miss 3+ signals and still advance")

4. **Propose L5 Test** — binary criterion: "If THIS is true, concern resolved." One sentence. (e.g., "Application hits 3+ of 5 signals OR feedback explains misalignment")

5. **Name the Artifact** — what will human see to verify? Concrete: screenshot, PDF, query result, test output. Not: code, status report, "I updated X"

6. **Apply 10-Second Rule** — can human glance and verify in 10 seconds? If no, reframe the test.

7. **Get Validation** — present L2/L3/L5 + artifact. Wait for approval before executing.

## Example

**Request:** "Improve the resume to pass more screenings"

**L2 Concern:** "What if resume gets rejected due to missing signals that matter to hiring teams?"

**L3 Intent:** "Every resume must hit ≥3 of 5 critical hiring signals for the target role"

**L4 Failure:** "Resumes hit <3 signals OR hiring team says 'missing what matters'"

**L5 Test:** "New resume sent to 5 hiring managers. Feedback: ≥3 say 'strong on [signal X]' for same role tier"

**Artifact:** Email responses from 5 hiring managers (screenshot or PDF showing feedback)

**10-second rule:** ✅ Yes. Human reads 5 feedback lines, sees "4/5 mention 'systems architecture'" → concern resolved.