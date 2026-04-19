# Execution: Acting on Your Knowledge Base

## Quick Answer

**Execution is where your Knowledge Base becomes action.** You consult what you know, take the smallest move that teaches you something, measure the outcome immediately, and let evidence flow back to refine your Knowledge Base. The loop closes: Knowledge → Action → Evidence → Better Knowledge → Faster Learning.

**The core principle:** Act small, measure fast, trust slowly. One successful task teaches more than a month of planning.

---

## The Loop

**Summary:** The execution loop has four nodes: Knowledge Base informs what you do, action produces outcomes, outcomes become evidence, evidence updates the Knowledge Base. This loop is the operating mechanism behind every part of this document — not a metaphor, but the literal sequence of events in any learning system.

```
Knowledge Base (what you know)
    ↓ informs
Execution (what you do)
    ↓ produces
Evidence (outcomes and surprises)
    ↓ updates
Knowledge Base (loop repeats, stronger)
```

Execution is where knowledge meets reality. You use your Knowledge Base to decide what to do, then you act. The outcome becomes evidence that flows back to improve the Knowledge Base.

---

## Feedback Types and Protocol Selection

**Summary:** All environment feedback falls into two categories: prescriptive (how things should be) triggers decomposition protocol, descriptive (how things actually are) feeds knowledge tiers. Both paths require risk management gating. Prescriptive uses L1-L5 to break concerns into verifiable artifacts. Descriptive uses evidence tiers to classify confidence. Risk assessment applies universally before any action regardless of feedback type.

Environment feedback comes in two forms. Know which protocol applies:

### Prescriptive Feedback ("How it should be")

**When:** Decomposing concerns, defining intent, testing whether a fix works  
**Protocol:** L1-L5 Decomposition (Concern → Intent → Failure → Test → Artifact)  
**Output:** Verifiable artifact that proves concern resolved

**Example:** A stakeholder says "applications must have zero silent failures." That's prescriptive. Use L1-L5 to decompose it: what counts as "silent," what's the test, what artifact proves it.

### Descriptive Feedback ("How it actually is")

**When:** Observing metrics, traces, logs, launch outcomes  
**Protocol:** Evidence collection and tier assignment (GUESSED/SUSPECTED/KNOWN/PROVEN)  
**Output:** Confidence tier that feeds back to Knowledge Base

**Example:** Your logs show "retry storms happening every 3 days." That's descriptive. Tier it: is this confirmed (KNOWN) or suspected? Does it repeat under variation? Only promote to KNOWN after pattern holds under conditions.

### Risk Management: Universal Gate

**Applies to:** Both prescriptive AND descriptive paths, always  
**When:** Before any action, decision, or change — regardless of feedback type  
**Assessment:**

| Factor | Question |
|--------|----------|
| **Blast Radius** | If I'm wrong, what breaks? |
| **Reversibility** | Can I undo this quickly? |
| **Observability** | Will I notice failure fast? |
| **Novelty** | Have I done this before? |
| **Privilege** | Who does this affect? |
| **Time Pressure** | How urgent is this? |

**Decision:** If blast radius is HIGH, reversibility is LOW, or privilege is HIGH — escalate before proceeding. Otherwise, proceed with monitoring proportional to remaining risk.

---

## Part 1: From Goal to Actionable Spec

**Summary:** Before executing, define what "success" actually looks like by specifying the transformation: what enters the system, what should exit, what test confirms it's correct, and what can go wrong. This transforms vague goals ("succeed") into specific acceptance criteria ("pass screening with zero errors + 3 of 5 signals").

The core question is not "What do I want?" but "When I hand the system [current state], what should it return as [desired state]?"

### **Four Required Components**

Every actionable spec needs these four elements:

| Component | What it answers | Example |
|-----------|-----------------|---------|
| **Input State** | What enters the system right now? | Job posting for role I'm 20% qualified for |
| **Desired Output State** | What should come out when done? | Application that passes screening (right tone, signals fit) |
| **Acceptance Criteria** | What makes you say "yes, correct"? | Zero spelling errors + 3 of 5 requirement signals |
| **Edge Cases** | What can go wrong? Failure modes? | Wrong company, candidate ghosts, solution cascades worse problems |

### **Input State**

What enters the system right now?
- A job posting (title, description, requirements, company)
- A candidate in your pipeline (skills, experience, goals)
- A technical problem (symptoms, constraints, past attempts)

Be specific. "A job posting" is vague. "A job posting for a role I have 20% expertise in" is actionable.

### **Desired Output State**

What should come out when you're done?
- An application that passes screening (right tone, right fit signals)
- A candidate who says yes to the offer (confident, committed)
- A problem solved with known tradeoffs (speed vs correctness, cost vs robustness)

Again, specific. Not "succeed at the job" but "pass the first screening" or "get to the technical interview."

### **Acceptance Criteria**

What makes you say "yes, that output is correct"?
- Application has zero spelling errors AND hits 3 of 5 key requirement signals
- Candidate confirms availability within 48 hours
- Problem solved with documented tradeoffs and no silent failures

This is the test. If your output passes this test, you're done.

### **Edge Cases and Failure Modes**

What can go wrong? What does failure look like?
- Application sent to wrong company
- Candidate accepts but then ghosts
- Solution creates worse problems downstream

---

## Part 2: The Execution Principle

**Summary:** The core principle is "Act small, measure fast, trust slowly." You will never know everything before you execute. Take the smallest action that creates useful information, measure results in days not weeks, and only promote patterns to your Knowledge Base after three repetitions. This maximizes learning speed while minimizing downside.

You will not know everything before you execute. Your Knowledge Base will have gaps. That's fine. Three principles guide you:

### **1. Small Actions**

Take the smallest action that creates useful information.

**Not:** "How do I solve this entire problem?"  
**But:** "What single move reduces the most uncertainty with the least downside?"

**Examples:**
- Not: "How do I become qualified for this role?" → But: "Can I demonstrate one core skill in a short project to see if I can learn the others on the job?"
- Not: "Complete the job and see how it goes" → But: "Send one application, see the response, refine approach"
- Not (Sales): "How do I close this enterprise deal?" → But: "Get a 15-minute call with the right buyer, understand their biggest constraint, propose one small pilot"
- Not (Product): "How do I launch this feature to millions?" → But: "Ship to 5% of users, measure adoption, collect feedback, decide next step"

Small actions are reversible. They teach cheaply.

### **2. Fast Feedback**

Get results immediately so you can adjust. Build feedback loops that close in hours or days, not weeks.

**Examples:**
- Delayed feedback (bad): "Complete the job and see how it goes" (months of data before you can adjust)
- Fast feedback (good): "Send one application, observe response, refine approach, send next batch" (days of data per cycle)

The speed of learning depends on feedback velocity.

### **3. Trust Slowly**

Only promote lessons to your Knowledge Base after repetition. One success ≠ pattern. Three successes under variation = pattern worth learning.

**Examples:**
- First cold email gets no response → don't conclude "cold email doesn't work" (one data point)
- Fifth cold email (same approach, different person) gets no response → now investigate what's wrong (pattern emerging)

---

## Part 3: The 6-Factor Risk Model

**Summary:** Before any action, score six factors to determine whether to execute autonomously, shrink scope, add monitoring, or escalate. Escalate if blast radius is HIGH, reversibility is LOW, or privilege is HIGH. Shrink if novelty is HIGH. Add monitoring if observability is LOW. Otherwise proceed. This prevents cascading failures and keeps you safe.

Before any action, score these six factors. This determines whether to execute autonomously, reduce scope, or escalate to a human.

### **The Six Factors**

| Factor | Question | Scoring |
|--------|----------|---------|
| **Blast Radius** | What breaks if I'm wrong? | Low: affects just me / Medium: one system / High: cascades |
| **Reversibility** | Can I undo it quickly? | High: minutes / Medium: hours / Low: days or impossible |
| **Observability** | Will I notice failure fast? | High: clear signal / Medium: detectable / Low: hidden |
| **Novelty** | Have I done this before? | Low: routine / Medium: similar / High: never seen |
| **Privilege** | What access/authority level? | Low: read-only / Medium: modify mine / High: affects others |
| **Time Pressure** | Do I need to act now? | Low: days / Medium: hours / High: minutes |

### **Decision Rules**

**ESCALATE immediately if ANY of these are true:**
- Blast radius = HIGH
- Reversibility = LOW
- Privilege = HIGH

**SHRINK ACTION if Novelty = HIGH:**
- Don't try the full thing
- Start with a test case
- Gather evidence first

**ADD MONITORING if Observability = LOW:**
- Before acting, add ways to detect failure
- Set up alerts
- Then execute

**PROCEED with light review if:**
- All factors are Low or Medium
- Reversibility is not LOW
- Privilege is not HIGH

### **Example: Applying for a Job You're Underqualified For**

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Blast Radius | MEDIUM | If rejected: lost opportunity. If hired and fail: reputational |
| Reversibility | MEDIUM | Can't un-send, but can exit the role |
| Observability | HIGH | Clear signal: accepted or rejected |
| Novelty | LOW | Done this hundreds of times |
| Privilege | MEDIUM | Affects hiring team's time |
| Time Pressure | LOW | Application deadline 1 week away |

**Decision: PROCEED**  
Reason: Most factors are Low/Medium, reversibility is acceptable.

### **Example: Taking on a Role You're Significantly Underqualified For**

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Blast Radius | HIGH | If I fail, company loses productivity, team suffers |
| Reversibility | LOW | Quitting damages reputation, takes weeks to transition |
| Observability | MEDIUM | Might not know I'm failing until 90 days in |
| Novelty | HIGH | Never done this exact job before |
| Privilege | HIGH | I make decisions affecting team and product |
| Time Pressure | MEDIUM | Need to decide in 3 days |

**Decision: ESCALATE**  
Reason: HIGH blast radius, LOW reversibility, HIGH novelty, HIGH privilege.

**What to do instead:**
- Don't accept immediately
- Build a Knowledge Base first (deep dive on job requirements)
- Propose a trial period (reduces irreversibility)
- Design a ramp-up plan with escalation checkpoints
- Get explicit support from hiring manager (reduces observability blind spots)

### **Example: Deploy Database Migration to Prod (Software Deployment)**

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Blast Radius | HIGH | If migration fails, app downtime affects all users |
| Reversibility | LOW | Rollback requires manual intervention, data might be partially migrated |
| Observability | INSTANT | Failures appear immediately in error logs and user reports |
| Novelty | MEDIUM | Similar migrations done before, but this schema is unique |
| Privilege | HIGH | Changes affect production data and all teams |
| Time Pressure | MEDIUM | Maintenance window is 2 hours tonight |

**Decision: ESCALATE**  
Reason: HIGH blast radius, LOW reversibility, HIGH privilege. Requires DBA review and explicit approval before deployment.

---

## Part 4: Learning While You Execute

**Summary:** Execution produces evidence. Capture it in three parts: what you expected (based on your Knowledge Base), what actually happened, and what surprised you. Evidence tiers determine how you interpret outcomes: if expected equals actual, pattern confirmed; if not, pattern broken and needs investigation. Let evidence flow back to refine your Knowledge Base instead of guessing why something failed.

Execution produces evidence. Capture it properly so it flows back to your Knowledge Base.

### **The Evidence Capture Template**

For every task, record:

| Element | What to capture |
|---------|-----------------|
| **Action** | What you did |
| **Expected outcome** | Based on Knowledge Base (if any) |
| **Actual outcome** | What happened |
| **Surprise** | Anything unexpected? |
| **Evidence tier** | If expected = actual: CONFIRMED / If not: BROKEN / If surprise: NEW |
| **Knowledge update** | Change tier? Refine mitigation? Discover new failure mode? |

### **Example: Cold Outreach (Single Email)**

| Element | Detail |
|---------|--------|
| Action | Send cold email to recruiter about role |
| Expected | Knowledge Base says: 5-10% response rate |
| Actual | No response after 3 days |
| Surprise | None — within expected range |
| Evidence | Data point 1 of X for this recruiter; too early to conclude pattern |
| Update | Wait for 3 more outreaches before changing anything |

### **Example: Cold Outreach (Batch, Failed)**

| Element | Detail |
|---------|--------|
| Action | Send 12 cold emails with same template, staggered |
| Expected | Knowledge Base says: 5-10% response ≈ ~1 response |
| Actual | 0 responses after 1 week |
| Surprise | Yes — significantly lower than expected |
| Evidence | Pattern broken. Possible causes: template ineffective, timing wrong, recruiter list mismatch, approach fundamentally flawed |

**Possible changes to test:**
- Call instead of email (reversible approach)
- Personalize more (test variant)
- Different recruiter list (different segment)

**Knowledge Base update:**
- Mark "cold email to recruiters" confidence as lower (was 5-10%, now 0%)
- Add mitigation: personalize template more
- Add signature: if no response in 3 days, escalate to call

### **Example: Sales Outreach (Batch, Failed)**

| Element | Detail |
|---------|--------|
| Action | Send 8 cold emails to company CTOs about your product, spaced 2 days apart |
| Expected | Knowledge Base says: 3-5% response rate ≈ ~1 response |
| Actual | 0 responses after 2 weeks |
| Surprise | Yes — significantly lower than expected |
| Evidence | Pattern broken. Possible causes: wrong title tier, bad timing, message tone off, company list mismatched with product fit, CTO role not decision maker |

**Possible changes to test:**
- Call instead of email (verify interest before formal pitch)
- Different target (VP Engineering instead of CTO)
- Different timing (early morning vs. afternoon send)

**Knowledge Base update:**
- Mark "cold email to CTOs" confidence lower (was 3-5%, now likely 0-1%)
- Add condition: "CTO title may not be decision maker; try VPE instead"
- Add signature: if no response in 5 days, escalate to call

### **Example: Product Feature (Successful Rollout)**

| Element | Detail |
|---------|--------|
| Action | Ship new dashboard to 10% of users as canary release, monitor for 3 days |
| Expected | Knowledge Base says: feature adoption >30% of users in cohort, no error rate spike |
| Actual | 38% adoption, error rate unchanged |
| Surprise | No — results match expectation |
| Evidence | Pattern confirmed for small cohort; safe to expand |

**Knowledge Base update:**
- Promote "dashboard adoption rate >30%" to KNOWN confidence (was SUSPECTED after 1 small launch)
- Next step: gradual rollout to 50%, then 100%
- Monitor for churn impact at each stage

---

## Part 5: Escalation — When to Ask for Help

**Summary:** Escalate in two cases: (1) the Risk Model flags the action as outside your safe zone (blast radius HIGH, reversibility LOW, or privilege HIGH), or (2) your Knowledge Base fails to predict something and you hit an unexpected constraint. Escalation is not failure; it's how you close Knowledge Base gaps efficiently instead of learning through cascading failures.

### **Case 1: The Action is Outside Your Safe Boundary**

The Risk Model says ESCALATE because blast radius is high, reversibility is low, or novelty is high.

**Example:**
- You're about to accept a role, but reversibility is low and blast radius is high
- Don't decide alone
- Get explicit backing from mentor or trusted advisor

### **Case 2: Your Knowledge Base Has a Gap**

You're executing and something breaks that your Knowledge Base didn't predict.

**Example:**
- **Action:** Present work to stakeholder
- **Expected:** positive feedback
- **Actual:** they reject the approach entirely
- **Surprise:** you missed a key constraint they didn't mention

**What to do:**
- Ask: "What constraint did I miss?"
- Learn: add that constraint to Knowledge Base
- Adjust: future work avoids this failure

---

## Part 6: The Execution-to-Learning Bridge

**Summary:** Every action generates evidence that refines your Knowledge Base, which improves your next action. Execute → Outcome is evidence → Evidence confirms/breaks patterns → Refine Knowledge Base → Next execution uses refined Knowledge Base → Loop repeats, stronger. Scale not by knowing more upfront, but by learning faster than you can fail.

Execution is not separate from learning. Every action generates evidence that feeds back.

```
Execute task A
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

Why this scales: You're not just executing tasks. Every task teaches you something. Your Knowledge Base compounds with each cycle.

---

## Summary: The Execution Half of the Loop

**Summary:** Six steps compress the full execution framework into a repeatable checklist: define success by transformation spec, run the Risk Model before acting, take the smallest reversible action, capture expected vs. actual evidence, escalate at boundaries, and close the loop back to the Knowledge Base. Repeat. This is the complete cycle.

**Execution translates Knowledge into action** by following a structured cycle:

| Step | What to do | Why |
|------|-----------|-----|
| **1. Define success** | Transformation spec: input → output → test | Vague goals fail; specificity is actionable |
| **2. Use Risk Model** | Before acting: is this safe alone? | Prevents cascading failures, reduces escalation later |
| **3. Act small** | Take the move that teaches most with least downside | Reversible actions produce feedback quickly |
| **4. Capture evidence** | Record expected vs actual vs surprise | Honest evidence identifies patterns vs noise |
| **5. Escalate gracefully** | Hit boundary? Ask for help, don't guess | Knowledge Base gaps close faster than failures cascade |
| **6. Close the loop** | Let evidence refine Knowledge Base | Compounds learning exponentially |

### **The Speed of Learning**

The speed depends on three factors:

- **Feedback velocity:** How fast you get results (days, not weeks)
- **Evidence honesty:** You mark surprise, not just success (contradictions reveal patterns)
- **Promotion discipline:** Only promote to "known" after 3+ repetitions under variation

**Why this scales:** Not by knowing more upfront, but by learning faster than you can fail.

---

<!-- FAQ Schema: This section contains structured Q&A about execution. Each Q/A pair addresses common questions about applying the execution framework. -->

## FAQ: Execution Questions

**Summary:** Six questions and answers on common execution confusion: when to act small despite full understanding, how much Knowledge Base suffices to start, when to promote patterns to 'known,' what to do when Risk Model says escalate but mentors don't exist, balancing speed with evidence accuracy, and handling failed escalation advice.

**Q: Should I always act small, even when I understand the whole problem?**  
A: Yes. Small actions are reversible and produce feedback faster. If you truly understand the whole problem, a small action confirms it cheaply. If you don't, you learn the gap immediately.

**Q: How do I know if I have enough Knowledge Base to execute?**  
A: When you can answer: (1) What are the 3-5 main failure modes? (2) What does each look like? (3) What makes each important? If you have these, you're ready to execute.

**Q: When do I promote something from "guessed" to "known"?**  
A: Never on first success. Three successes under variation = pattern. Success with different contexts, timing, or actors. One person saying yes doesn't mean "cold email works."

**Q: The Risk Model says ESCALATE, but I don't have a mentor. What do I do?**  
A: Shrink the action scope until it's low blast radius and high reversibility. A smaller test reduces risk enough to proceed. Or wait for the right context to make the full decision.

**Q: How do I balance speed with accuracy in evidence capture?**  
A: Capture immediately (within hours). Tier accurately (honest about confidence). Don't wait for perfect information. "Candidate ghosted, escalated with call" is enough. Refine later as patterns emerge.

**Q: What if I escalate, get advice, but the advice doesn't work?**  
A: That's evidence too. Record: "Followed advice X, expected Y, got Z." That tells you the advice giver's Knowledge Base might not fit your context. Adjust and try again.
