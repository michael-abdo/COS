# Epistemology: How Do We Know What We Know?

**Quick Answer:** Epistemology defines confidence tiers for patterns based on evidence count and variation. Four tiers prevent false confidence: GUESSED (1-2 instances) → SUSPECTED (3-5) → KNOWN (10+) → PROVEN (100+). Never deploy a pattern until its tier is SUSPECTED minimum.

## Evidence Tiers

**Summary:** Confidence tiers prevent scaling untested patterns. GUESSED means "seen once, don't repeat"; SUSPECTED means "pattern holds across variations, proceed cautiously"; KNOWN means "safe to repeat consistently"; PROVEN means "automate with confidence." The key: instances must span different contexts (not identical repeats). "Email worked 3 times to the same person" is GUESSED. "Email worked to 3 different recruiters" is SUSPECTED. Variation matters. (59 words)

| Tier | Instance Count | Variation | Action | Risk |
|------|---|---|---|---|
| **GUESSED** | 1-2 | None required | Test in isolation only. Never deploy | Highest |
| **SUSPECTED** | 3-5 | Across ≥2 contexts | Proceed with caution. Monitor closely. Add guards. | High |
| **KNOWN** | 10+ | Across ≥4 contexts | Safe to repeat. Expect consistency. No constant monitoring. | Medium |
| **PROVEN** | 100+ | Across ≥10 contexts | Automate. Confidence justified. Make it default. | Low |

## Examples Across Domains

**Recruiting:** Cold email response rate

1. **Observation 1:** Sent 3 emails, 0 responses → GUESSED. Don't conclude anything.
2. **Observation 2-3:** Sent 25 more to different recruiters, 2 responses (8%) → SUSPECTED. Pattern emerges but sample small.
3. **Observation 10:** 100 emails across 20 companies, 7 responses (7% ± 2%) → KNOWN. Safe to scale with consistent targeting.
4. **Observation 500:** 500 emails over 6 months, 35 responses (7%), response time distribution stable → PROVEN. Automate response tracking.

**Systems:** Database recovery after crash

1. **Observation 1:** One recovery succeeded → GUESSED.
2. **Observation 2-3:** Two more recoveries (different DB sizes, schemas) succeeded → SUSPECTED. Proceed with caution on untested schema.
3. **Observation 10:** 10 recoveries across all schema types succeed → KNOWN. Safe to use as standard recovery procedure.
4. **Observation 100:** 100 recoveries, all successful, data integrity verified → PROVEN. Automate with confidence.

**Trading:** Short squeeze signal reliability

1. **Observation 1:** One stock short-squeezed after seeing signal → GUESSED.
2. **Observation 2-5:** Three more stocks showed signal before squeeze → SUSPECTED. Pattern holds but sample small.
3. **Observation 10:** 10 stocks, 8 squeezed within expected timeframe → KNOWN. Safe to trade this signal with stops.
4. **Observation 100:** 100 signals across market regimes, 85% accuracy → PROVEN. Automate signal generation with confidence.

## Critical Rule: Variation Matters

"It worked 3 times" is NOT SUSPECTED if it's the same person/condition/market. You need:

- **Different people/actors:** 3 different recruiters (not 3 emails to same recruiter)
- **Different timing:** Across different weeks/markets (not all in same bull market)
- **Different contexts:** Across different role types, industries, or scenarios

**Counter-example:** "Email worked at 9am, 9:15am, 9:30am on the same day to same company" = GUESSED (all identical context).

## Tier Promotion Rules

Document when each tier will advance:

- GUESSED → SUSPECTED when: "We see pattern in 3 distinct contexts"
- SUSPECTED → KNOWN when: "We see pattern 10 times across 4+ distinct contexts"
- KNOWN → PROVEN when: "We see pattern 100 times with <20% variance"

Update Knowledge Base when tiers change. Include: what data triggered promotion, date of promotion, new confidence level.

## FAQ

**Q: What if a pattern breaks after reaching KNOWN?**
A: Demote tier. Record: what changed, when, why. Mark as SUSPECTED pending investigation.

**Q: Can instance count be from different agents?**
A: Yes. If Agent A sees pattern 5 times and Agent B sees it 6 times across different contexts, that's 11 instances toward KNOWN.

**Q: What if I don't have 100 instances?**
A: You likely can only reach SUSPECTED or KNOWN. That's fine. Document ceiling: "KNOWN based on 47 instances; PROVEN requires X more data."
