# Skill: Evidence Tiering

## When to use
After observing any pattern, before claiming confidence. Before deploying something repeatedly. When deciding if a pattern is "proven" or still "guessed."

## What it does
Classifies confidence level (GUESSED → SUSPECTED → KNOWN → PROVEN). Prevents false confidence and over-deployment.

## Steps

1. **Count instances** of the pattern across variations (different contexts, timing, actors).

2. **Map to tier threshold:**
   - **GUESSED (1-2 instances):** Never deploy. Test in isolation first.
   - **SUSPECTED (3-5 instances):** Proceed with caution. Monitor closely.
   - **KNOWN (10+ instances):** Safe to repeat. Expect consistency.
   - **PROVEN (100+ instances):** Automate. Confidence justified.

3. **Check for variation:** Instances must span different contexts, not identical repeats. "Email worked 3 times to recruiter A" ≠ SUSPECTED (same person). "Email worked 3 times to different recruiters" = SUSPECTED.

4. **Plan promotion:** When will this tier advance? (e.g., "SUSPECTED→KNOWN when we see pattern 10 times across 4+ companies")

5. **Document:** record tier + reasoning in Knowledge Base.

## Example

**Pattern:** "Cold email to recruiters gets 5-10% response rate"

**Observation 1:** Sent 12 emails, 0 responses after 1 week
- Tier: GUESSED (1 data point, anomaly?)
- Action: Don't conclude anything. Run more emails.

**Observation 2-3:** Sent 25 more emails over 2 weeks, 2 responses
- Tier: SUSPECTED (27 total, 2 responses ≈ 7%, within expected range but still low sample)
- Action: Continue sending. Monitor if response rate stays 5-10% or drops further.

**Observation 10:** Sent 100 emails over 8 weeks, 6 responses (6% rate)
- Tier: KNOWN (100 instances, consistent rate, pattern holds across different recruiters/companies)
- Action: Safe to scale. Expect 6-10% response rate. No need for constant monitoring.

**Observation 500:** Sent 500 emails over 6 months, 30 responses (6% rate, P95 response time 48h)
- Tier: PROVEN (500 instances, sub-tier: response time distribution also stable)
- Action: Automate response handling. Scale confidently.

**Key:** "It worked 3 times" doesn't mean KNOWN. You need repetition across variation, not identical repeats.