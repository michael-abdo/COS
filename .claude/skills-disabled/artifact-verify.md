# Skill: Artifact Verification (10-Second Rule)

## When to use
Before presenting output. Before claiming a task is done. Before showing human a result.

## What it does
Validates that the output is glance-verifiable in 10 seconds without reading code or scrolling. Prevents "I updated X" claims that require trust.

## Steps

1. **Name the artifact** — what EXACTLY will human see? (e.g., "Grafana dashboard", "curl response", "PDF", "GIF", "test output")

2. **Ask the glance test:** Can human look at it for 10 seconds and say "yes" or "no" WITHOUT reading code, scrolling, interpreting, or thinking?
   - ✅ Yes → proceed to step 3
   - ❌ No → reframe artifact

3. **Produce the artifact** using tools:
   - Screenshot (for UI changes)
   - Rendered page (for web content)
   - Curl response (for API changes)
   - PDF (for document changes)
   - Test output (for code changes)
   - Query result (for data changes)
   - GIF (for interactions)

4. **Verify yourself** — use tools to capture proof (screenshot, read output, run query). Don't say "I updated X"—show X.

5. **Present to human** — "Here's the artifact: [short description]. Does this match your expectation?"

## Example

**Bad artifact claim:** "I updated the resume to improve signal strength"
- Human needs to read the resume, understand what signals matter, compare before/after
- Requires interpretation = BAD

**Good artifact claim:** "Resume now hits 5/5 hiring signals. Here's feedback from 3 hiring managers confirming it."
- Human reads 3 feedback lines = 10 seconds
- Clear yes/no = confirms concern resolved

**Bad artifact claim:** "The storage cluster latency improved"
- Human doesn't know what normal latency is, can't verify

**Good artifact claim:** "Here's the Grafana dashboard. P99 latency was 800ms (red), now 120ms (green). SLA miss rate dropped from 3.2% to 0.1%."
- Human glances at dashboard = 10 seconds
- Visual confirmation = verified

**Bad artifact claim:** "I deployed the code"
- No artifact, just a claim

**Good artifact claim:** "Deployment complete. Test output shows: 342 passed, 0 failed. Production metrics confirm new feature live (flag toggle shows >50% traffic)"
- Human sees test output + metrics = verified