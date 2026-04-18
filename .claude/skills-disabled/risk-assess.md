# Skill: Risk Assessment (6-Factor Model)

## When to use
Before ANY decision, action, or change. Applies to code commits, infrastructure changes, outreach campaigns, data migrations—everything.

## What it does
Scores six factors to determine: ESCALATE (too risky), PROCEED (acceptable), SHRINK (test smaller), or ADD MONITORING.

## Steps

1. **Score each factor** (Low/Medium/High):
   - **Blast Radius:** If wrong, what breaks? (Low=just me, Medium=one system, High=cascades)
   - **Reversibility:** Can I undo? (High=minutes, Medium=hours, Low=days+/impossible)
   - **Observability:** Will I notice failure? (High=clear signal, Medium=detectable, Low=hidden)
   - **Novelty:** Have I done this? (Low=routine, Medium=similar, High=never)
   - **Privilege:** Who affected? (Low=read-only, Medium=my stuff, High=affects others)
   - **Time Pressure:** How urgent? (Low=days, Medium=hours, High=minutes)

2. **Apply decision gates:**
   - **ESCALATE if:** Blast Radius=HIGH OR Reversibility=LOW OR Privilege=HIGH
   - **SHRINK if:** Novelty=HIGH (test in isolation first, don't attempt full scope)
   - **ADD MONITORING if:** Observability=LOW (set alerts before acting)
   - **PROCEED if:** all factors Low/Medium and no gates triggered

3. **Document the decision** — record scores and reasoning before acting.

## Example

**Action:** Deploy database migration to production

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Blast Radius | HIGH | If migration fails, app downtime affects all users |
| Reversibility | LOW | Rollback requires manual intervention, partial data state |
| Observability | HIGH | Failures surface immediately in error logs |
| Novelty | MEDIUM | Similar migrations done before, but schema is unique |
| Privilege | HIGH | Changes affect production data for all customers |
| Time Pressure | MEDIUM | Maintenance window is 2 hours tonight |

**Decision:** ESCALATE. HIGH blast + LOW reversibility + HIGH privilege = requires DBA approval + test plan.

**Action:** Send cold email to recruiter

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Blast Radius | MEDIUM | Lost opportunity if rejected; possible reputation impact |
| Reversibility | MEDIUM | Can't unsend; can exit role if hired |
| Observability | HIGH | Clear signal (response or rejection) |
| Novelty | LOW | Done hundreds of times |
| Privilege | MEDIUM | Takes recruiter's time |
| Time Pressure | LOW | Deadline 1 week away |

**Decision:** PROCEED. Most factors Low/Medium, reversibility acceptable.