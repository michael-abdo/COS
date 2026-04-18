# Risk Model: The 6-Factor Decision Gate

**Quick Answer:** Score six factors on every decision to determine ESCALATE (too risky), PROCEED (acceptable), SHRINK (test smaller first), or ADD MONITORING. Consistent gates prevent cascade failures.

## The Six Factors

**Summary:** Before any action, score Blast Radius, Reversibility, Observability, Novelty, Privilege, Time Pressure. Escalate if blast radius is HIGH, reversibility is LOW, or privilege is HIGH. Add monitoring if observability is LOW. Shrink if novelty is HIGH. This prevents individual errors from cascading into system failures. The model is uniform across all domains; the same HIGH blast radius in hiring, trading, or systems triggers the same escalation gate. (61 words)

| Factor | Low | Medium | High | Question |
|--------|-----|--------|------|----------|
| **Blast Radius** | Just me | One system/team | Cascades broadly | If wrong, what breaks? |
| **Reversibility** | Minutes to undo | Hours to undo | Days+ / impossible | Can I undo this? |
| **Observability** | Clear signal immediately | Detectable with monitoring | Hidden / delayed | Will I notice failure? |
| **Novelty** | Routine, done 100x | Similar, done 10x | Never done before | Have I done this? |
| **Privilege** | Read-only | My data/systems | Affects others | Who's impacted? |
| **Time Pressure** | Days available | Hours available | Minutes available | How urgent? |

## Decision Gates

**Escalate if ANY:**
- Blast Radius = HIGH
- Reversibility = LOW
- Privilege = HIGH

Requires human approval, documented decision, logged reasoning.

**Shrink if:**
- Novelty = HIGH

Test in isolation first (smaller scope, sandbox, low-stakes). Don't attempt full scope immediately.

**Add Monitoring if:**
- Observability = LOW

Set alerts before acting. Define: what signal indicates success vs. failure?

**Proceed if:**
- No escalation factors triggered
- All factors Low/Medium (after shrinking if needed)
- Monitoring configured for LOW-observability factors

## Examples Across Domains

### Hiring: Send Cold Email to Recruiter

| Factor | Score | Reasoning |
|--------|-------|-----------|
| **Blast Radius** | MEDIUM | Lost opportunity if rejected; possible reputation impact |
| **Reversibility** | MEDIUM | Can't unsend; can exit role if hired |
| **Observability** | HIGH | Clear signal (response or rejection) |
| **Novelty** | LOW | Done hundreds of times |
| **Privilege** | MEDIUM | Takes recruiter's time |
| **Time Pressure** | LOW | Deadline 1 week away |

**Decision:** PROCEED. Most factors Low/Medium; no escalation triggers.

### Trading: Deploy New Hedging Strategy

| Factor | Score | Reasoning |
|--------|-------|-----------|
| **Blast Radius** | HIGH | Hedge failure = unprotected portfolio blowup |
| **Reversibility** | MEDIUM | Can unwind positions but takes time if market moves |
| **Observability** | HIGH | Position P&L monitored in real-time |
| **Novelty** | HIGH | Never backtested this regime combination |
| **Privilege** | HIGH | Affects all capital in portfolio |
| **Time Pressure** | MEDIUM | Market opportunity expires in 2 days |

**Decision:** ESCALATE (HIGH blast + HIGH privilege). Requires: (1) backtesting on out-of-sample data, (2) position size cap, (3) stop-loss rule, (4) human approval.

### Systems: Deploy Database Migration to Production

| Factor | Score | Reasoning |
|--------|-------|-----------|
| **Blast Radius** | HIGH | If migration fails, app downtime affects all users |
| **Reversibility** | LOW | Rollback requires manual intervention; partial data state risk |
| **Observability** | HIGH | Failures surface in error logs within seconds |
| **Novelty** | MEDIUM | Similar migrations done before; schema is unique |
| **Privilege** | HIGH | Changes production data for all customers |
| **Time Pressure** | MEDIUM | Maintenance window is 2 hours tonight |

**Decision:** ESCALATE (HIGH blast + LOW reversibility + HIGH privilege). Requires: (1) DBA review + approval, (2) rollback plan tested, (3) staging validation, (4) monitoring alerts configured, (5) documented approval logged.

### Consulting: Propose Aggressive Cost-Cutting to Client

| Factor | Score | Reasoning |
|--------|-------|-----------|
| **Blast Radius** | HIGH | Wrong cuts = client loses revenue streams or capability |
| **Reversibility** | LOW | Layoffs, canceled contracts not easily reversed |
| **Observability** | MEDIUM | Results take 3+ months to surface; lag in signal |
| **Novelty** | MEDIUM | Similar restructures done, but client context unique |
| **Privilege** | HIGH | Affects client's revenue, staff, market position |
| **Time Pressure** | HIGH | Client needs answer by end of week |

**Decision:** ESCALATE (HIGH blast + LOW reversibility + HIGH privilege). Requires: (1) detailed financial modeling reviewed by second analyst, (2) client steering committee approval, (3) phased rollout plan, (4) quarterly metrics to track results, (5) contingency triggers documented.

## Audit Rule

**Weekly:** Sample 5 recent decisions. Verify:
1. All HIGH/LOW factors have escalation gates logged
2. All LOW-observability factors have monitoring alerts configured
3. All HIGH-novelty factors had isolation/shrink phase before full deployment

If <80% pass, investigate: Are gates being skipped? Is risk model understood?

## FAQ

**Q: Can I override the gates?**
A: Gates exist to prevent cascade failures. Overriding requires explicit documented approval (not just "I thought about it"). Log: decision, reasoning, who approved, contingencies.

**Q: What if two factors conflict (e.g., HIGH urgency but HIGH novelty)?**
A: HIGH novelty forces shrink; HIGH urgency can't override. Solution: expand time, reduce scope, or escalate for decision.

**Q: How often should I re-score decisions?**
A: At decision point (before execution). Re-score if context changes: scope grows, timeline accelerates, or privilege increases.
