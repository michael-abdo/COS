# Risk & Uncertainty Management

## Part 1: The 6-Factor Risk Model

### The Problem

You're right to use Claude to help—but don't delegate the final risk judgment to it.

Instead, use Claude to construct and populate a simple, fixed risk model that you apply every time.

**You don't need experience to invent risk judgment. You need a conservative, explicit rubric that you apply consistently.**

### The Core Move

Instead of asking: *"Is this safe?"*

Ask: *"How does this score on a few fixed risk dimensions?"*

That removes intuition from the equation.

---

## The 6-Factor Risk Model

For every action, score each of these on a scale: **Low / Medium / High**

1. **Blast radius** — What breaks if wrong?
2. **Reversibility** — Can I undo it quickly?
3. **Observability** — Will I notice failure fast?
4. **Novelty** — Have we done this before?
5. **Privilege** — What level of access is involved?
6. **Time pressure** — Do I need to act now?

---

## Decision Rules

Apply these mechanically. No exceptions.

**If ANY of these are HIGH:**
- Blast radius
- Reversibility (if LOW, triggers escalation)
- Privilege

→ Do not act autonomously  
→ Require review or reduce scope

**If novelty is HIGH:**
→ Shrink the action  
→ Test first  
→ Gather evidence

**If observability is LOW:**
→ Add monitoring BEFORE acting

---

## Where Claude Helps

Claude should NOT decide risk for you.

Claude should help you:

### 1. Classify the Action

You ask Claude:
> "Given this change, what could go wrong? What systems does it touch?"

Claude outputs:
- Potential failure modes
- Dependencies
- Hidden effects

### 2. Fill the Risk Table

Claude can suggest:
- Blast radius: likely medium (affects X service)
- Reversibility: high (config change, easy rollback)
- Observability: medium (metrics exist but no alert)
- Novelty: high (no similar prior change)
- Privilege: medium (service-level access)

### 3. Suggest Safer Alternatives

Claude can answer:
> "What is a smaller or safer version of this action?"

Examples:
- Test in staging
- Limit to one host
- Run read-only check first
- Simulate change
- Add monitoring first

---

## Your Responsibility

**You do NOT need experience to:**
- Apply a rubric
- Enforce thresholds
- Refuse unsafe autonomy

**You DO need discipline to:**
- Follow the rules even when it's tempting not to
- Escalate when the model says "don't act"
- Never skip the scoring process

---

## Making It Systematic

Add this to your Claude workflow. **Every task must output:**

```
RISK ASSESSMENT

Blast radius:        [Low/Medium/High]
Reversibility:       [Low/Medium/High]
Observability:       [Low/Medium/High]
Novelty:             [Low/Medium/High]
Privilege:           [Low/Medium/High]
Time pressure:       [Low/Medium/High]

Decision:
- Proceed / Reduce scope / Escalate

Safe next action:    [what to do]
Rollback plan:       [how to undo]
Verification:        [how to confirm success]
```

**No exceptions.**

---

## The Limits of Decomposition

You might think: *"I can reduce risk by breaking tasks into smaller pieces."*

**Decomposition helps a lot, but it does not eliminate risk.**

Some risks do not shrink linearly when you break tasks down.

### Where Decomposition Works

You can reduce risk effectively for:
- Read-only inspection
- Local testing
- Config drafting
- Staging changes
- Small-scope rollouts (1 host, canary, etc.)

### Where Decomposition Breaks

There are three classes of work where you cannot decompose to zero risk:

#### 1. Irreversible / Coupled Actions

Some actions are inherently risky even in small form.

Examples:
- Touching storage cluster behavior
- Changing network routing rules
- Rotating credentials
- Modifying replication/quorum

Even a "small" change can:
- Affect shared state
- Trigger cascading effects
- Be hard to undo cleanly

#### 2. Observability Gaps

If you can't see failure clearly, small steps don't guarantee safety.

Examples:
- Silent data corruption
- Partial packet loss
- Degraded performance that appears normal
- Metrics that don't reflect user reality

You might act safely, verify incorrectly, and believe everything is fine.

#### 3. Unknown Unknown Interactions

You can decompose tasks, but you cannot fully decompose interactions.

Example:
- Change A is safe
- Change B is safe
- A + B together break the system

These show up in:
- Distributed systems
- High-throughput pipelines
- Complex dependency graphs

---

## The Real Constraint

You said: *"The only problem becomes speed."*

Close, but incomplete.

**The real constraint is:**

```
risk = uncertainty × impact × detection delay × irreversibility
```

Speed helps with:
- Reducing detection delay
- Increasing iteration rate

But it does NOT fix:
- Impact (blast radius)
- Irreversibility
- Hidden system coupling

### The Correct Model

Instead of: *"Decompose until no risk"*

Use: *"Decompose until risk is acceptable under our constraints"*

Where "acceptable" means:
- Low blast radius
- Fast detection
- Clear rollback
- Known evaluator

---

## Part 2: Managing Uncertainty

### The Core Challenge

Unknown unknowns remain the hardest area.

Live incidents involve:
- Incomplete information
- Time pressure
- Hidden second-order effects
- Judgment about whether to mitigate or wait
- Knowing what not to touch

Your cognitive OS can reduce chaos.

It cannot fully replace real operational experience.

---

## Three Principles for Safe Operation Under Uncertainty

### 1. Make Uncertainty First-Class

Every object should carry:
- confidence
- evidence quality
- model coverage
- ambiguity
- escalation threshold

That prevents false certainty.

### 2. Detect Model-Boundary Conditions

The system should ask:
- Does this case fit a known transformation class?
- Does this symptom match known patterns?
- Are evaluator signals contradictory?
- Is the proposed action outside known-safe operations?
- Are we extrapolating beyond prior examples?

If yes, mark: boundary breach or low model coverage.

### 3. Escalate Gracefully

When outside the boundary, the system should shift modes:
- Stop optimizing aggressively
- Gather more evidence
- Narrow action space
- Prefer reversible actions
- Request human clarification
- Avoid production-risky interventions

---

## Five Dimensions of Operational Risk

**A. Coverage**

How much of this task maps to known ontology and prior cases?

**B. Confidence**

How strongly do evidence and patterns support the current path?

**C. Reversibility**

If wrong, how costly is the action?

**D. Novelty**

How different is this from prior examples?

**E. Observability**

If this goes wrong, will we notice quickly?

Those five dimensions tell you how dangerous the unknowns are.

---

## Five Levers for Managing Risk

### 1. Bound the Action Space

Never let the system do everything.

Create action classes:
- Safe and reversible
- Safe but costly
- Risky
- Forbidden without human approval

Example:
- Read logs → safe
- Run tests → safe
- Change config in dev → safe
- Restart prod service → risky
- Alter storage cluster topology → human approval only

### 2. Force Confidence to Travel with Every Action

Every recommendation should carry:
- confidence
- evidence count
- novelty
- reversibility
- expected blast radius

Then use a rule like:

**low confidence + low reversibility + high blast radius = no autonomous action**

That keeps ignorance from masquerading as competence.

### 3. Prefer Fast Feedback Over Perfect Knowledge

You cannot know everything beforehand.

Design loops that produce quick evidence:
- Small test first
- Limited rollout
- Canary
- Shadow mode
- Dry run
- Diff check
- Rollback path

Do not ask, "Do we know enough to guarantee success?"

Ask, "What small action gives the most information with the least downside?"

### 4. Promote Only Repeated Knowledge

Do not let every observation become canon.

Promote knowledge only when it:
- Recurs
- Predicts outcomes
- Changes decisions
- Survives review

Everything else should stay provisional.

That slows nonsense accumulation.

### 5. Track Gaps Explicitly

Keep a live list of:
- Known gaps
- Assumptions
- Fragile areas
- Unclear evaluators
- Unsafe unknowns

Then review those often.

If a gap lacks consequence, leave it alone.

If a gap touches high-risk action, move it to the front.

---

## The Operating Principle

Build the system so it asks, every cycle:

1. **What do we know well enough?**
2. **What remains uncertain?**
3. **What cheap test reduces the most risk?**
4. **Is the next action reversible?**
5. **What would count as failure?**
6. **When do we escalate?**

That becomes cheap learning.

---

## Six Mechanisms for Cheap Learning

### 1. Explicit Uncertainty

The system should always mark:
- What it knows
- What it infers
- What it guesses
- What it lacks

If those blur together, learning gets expensive.

### 2. Small Actions

Take the smallest action that creates the most information.

Not: "How do we solve everything?"

But: "What cheap move reduces uncertainty fastest?"

### 3. Fast Feedback

Cheap learning needs short loops:
- Test
- Observe
- Compare
- Update

Long delays make ignorance expensive.

### 4. Reversibility

A reversible mistake teaches.
An irreversible mistake punishes.

So the system should prefer:
- Dry runs
- Canaries
- Staged rollouts
- Shadow mode
- Local simulation
- Read-only inspection first

### 5. Clear Model Boundaries

The system should say:
- This fits a known class
- This partially fits
- This does not fit
- This exceeds safe autonomy

That is where real confidence comes from.

### 6. Slow Trust Promotion

One success should not create trust.
Repeated success under variation should.

So confidence should come from:
- Repeated exposure
- Diverse cases
- Consistent evaluator results
- Survival under edge cases

Not from one elegant explanation.

---

## The Deeper Shift

Confidence should not mean:
- "I understand everything."

Confidence should mean:
- "I know the safe next move."
- "I know what evidence would change my mind."
- "I know when to stop."

That's much stronger.

---

## Master Policy for Safe Operation

Act automatically only when:
- The task fits a known class
- The evaluator looks valid
- The action stays reversible
- The blast radius stays low
- Observability looks strong

Otherwise:
- Narrow the action
- Gather evidence
- Ask for review
- Or stop

---

## The Real Metric

You can measure your system with something like:

- Average blast radius per mistake ↓
- Time to detect mistake ↓
- Time to correct mistake ↓
- Repeated mistakes ↓
- Successful patterns reused ↑

If those improve, your system works.

---

## Final Compression

**Learn cheaply by acting small, measuring fast, and trusting slowly.**

Not just operating at the edge of knowledge, but:

**Operating at the edge of knowledge while controlling the risk of being wrong, and ensuring that each step expands the boundary safely.**

That means two coupled loops:

### Edge Operation Loop

How you act when you don't fully know:
- Define what you think is true
- Define what you're unsure about
- Take the smallest safe action
- Verify quickly
- Adjust

This is about behavior under uncertainty.

### Knowledge Expansion Loop

How the system improves over time:
- Capture what happened
- Classify it (pattern / failure / edge case)
- Decide if it's reusable
- Promote or discard
- Refine evaluator

This is about turning experience into usable structure.

---

## The Key Insight

Most people separate:
- Acting
- Learning

Your system merges them:

**Every action becomes a learning event, and every learning event constrains future action.**

That's what makes it powerful.

---

## What Actually Matters

Not: how much you know

But:
- How safely you operate when you don't know
- How fast you convert uncertainty into knowledge
- How well you avoid repeating mistakes

The cleanest sentence:

**Confidence comes not from total knowledge, but from calibrated action under explicit uncertainty.**
