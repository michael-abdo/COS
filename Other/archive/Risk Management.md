# Risk Management

## The Problem

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
- Irreversibility  
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

### For Every Task

1. Try to decompose
2. If still risky, ask:
   - Can I reduce blast radius?
   - Can I improve observability?
   - Can I improve rollback?
3. If not:
   - Escalate
   - Delay
   - Gather more evidence

### The Key Invariant

**Never take an action whose failure you cannot detect or undo.**

That's the line that actually keeps you safe.

---

## Hidden Advantage You Have

Experienced engineers do risk assessment implicitly.

You're doing it explicitly and consistently.

That can actually make you **safer** than many experienced people who:
- Rely on gut feeling
- Skip checks
- Over-trust familiarity

---

## When You're Unsure

**Reduce scope until it becomes obviously safe.**

Examples:
- Instead of changing all hosts → change one
- Instead of deploying → simulate
- Instead of writing → read-only inspect
- Instead of fixing → gather more evidence

That's how you learn cheaply.

---

## Application: Databento Risk Mapping

Now apply your risk model to their real environment.

### System Architecture

Think of Databento like this:

```
[ Capture (firehose) ]
        ↓
[ Processing / normalization ]
        ↓
[ Storage (Ceph, 30+ PB) ]
        ↓
[ Delivery (APIs, bulk export) ]
        ↓
[ Monitoring / automation ]
```

### Risk by Layer

#### 1. Capture (Network Ingest) → EXTREME RISK

This is:
- 100 Gbps capture
- No packet loss allowed
- Real-time feeds

**Risk profile:**
- Blast radius: VERY HIGH
- Reversibility: LOW
- Observability: PARTIAL (loss may be subtle)
- Novelty: HIGH
- Privilege: HIGH

**Translation:** If you mess this up, data is gone forever. Customers lose trust.

**Your rule:** DO NOT TOUCH directly without supervision

#### 2. Storage (Ceph, 30+ PB) → EXTREME RISK

This is:
- Massive distributed storage
- Historical + real-time dependency

**Risk profile:**
- Blast radius: VERY HIGH
- Reversibility: VERY LOW
- Observability: DELAYED
- Novelty: MEDIUM–HIGH
- Privilege: VERY HIGH

**Translation:** Mistake = data loss, corruption, long recovery windows

**Your rule:** No autonomous changes. Only observe, diagnose, assist.

#### 3. Networking (Internal + DC) → HIGH RISK

This includes:
- Routing
- Interfaces
- Load balancing
- Inter-node traffic

**Risk profile:**
- Blast radius: HIGH
- Reversibility: MEDIUM
- Observability: MIXED
- Novelty: HIGH
- Privilege: HIGH

**Translation:** Mistake = partial outages, weird intermittent failures

**Your rule:** Only act in very small, well-understood scopes. Prefer diagnosis + recommendation.

#### 4. Processing / Services → MEDIUM RISK

This includes:
- Feed handlers
- Processing pipelines
- Service configs

**Risk profile:**
- Blast radius: MEDIUM
- Reversibility: MEDIUM–HIGH
- Observability: GOOD
- Novelty: MEDIUM
- Privilege: MEDIUM

**Translation:** Mistake = degraded performance, incorrect output, recoverable issues

**Your rule:** Safe for controlled changes with rollback.

#### 5. Delivery / APIs / Data Export → MEDIUM RISK

This includes:
- Customer-facing systems
- Bulk delivery
- API behavior

**Risk profile:**
- Blast radius: MEDIUM
- Reversibility: HIGH
- Observability: HIGH
- Novelty: LOW–MEDIUM
- Privilege: MEDIUM

**Translation:** Mistake = customer-facing bugs, but usually fixable quickly

**Your rule:** Good place to start contributing.

#### 6. Monitoring / Alerts / Automation → LOW–MEDIUM RISK

This includes:
- Prometheus
- Grafana
- Alert rules
- Runbooks
- Automation scripts

**Risk profile:**
- Blast radius: LOW–MEDIUM
- Reversibility: HIGH
- Observability: HIGH
- Novelty: LOW
- Privilege: LOW–MEDIUM

**Translation:** Mistake = noisy alerts, missed signals, not catastrophic

**Your rule:** PRIMARY SAFE ZONE. Start here.

---

## Apply the Model: Examples

**Example: "Improve alert"**
- Blast radius: LOW
- Reversibility: HIGH
- Observability: HIGH
- Novelty: LOW
- Privilege: LOW

→ **Act freely**

**Example: "Change Ansible provisioning"**
- Blast radius: MEDIUM
- Reversibility: HIGH
- Observability: HIGH
- Novelty: MEDIUM
- Privilege: MEDIUM

→ **Act with review + test first**

**Example: "Restart Ceph service"**
- Blast radius: VERY HIGH
- Reversibility: LOW
- Observability: DELAYED
- Novelty: HIGH
- Privilege: HIGH

→ **Do NOT act autonomously**

**Example: "Investigate packet loss"**
- Blast radius: NONE (read-only)
- Reversibility: HIGH
- Observability: VARIABLE
- Novelty: HIGH
- Privilege: LOW

→ **Safe to explore, not to fix blindly**

---

## Your Personal Operating Map

**WHERE am I in the system?**

Because: System layer → determines risk automatically

### SAFE ZONE (start here)
- Alerts
- Dashboards
- Logs
- Automation
- Documentation
- Delivery systems

### CONTROLLED ZONE
- Provisioning
- Deployment
- Service configs

### DANGER ZONE
- Storage (Ceph)
- Networking core
- Capture pipeline
- Secrets

---

## Your Real Advantage

Most junior engineers struggle because they treat all problems equally.

You won't.

You'll think:
1. What layer is this?
2. What is the inherent risk?
3. What is the smallest safe action?

**That's senior thinking.**

---

## Final Compression

**Databento risk map:**
- Capture + Storage = DO NOT TOUCH
- Networking = TOUCH CAREFULLY
- Services = CONTROLLED
- Delivery = SAFE
- Monitoring = SAFEST

**Key insight:** You don't need to know everything. You need to know WHERE you are in the system, because system layer determines risk automatically.

**The invariant:** Take the fastest action that keeps risk within acceptable bounds.

**Weekly reflection:** Did I make something:
- Faster?
- Safer?
- Easier?
- More repeatable?

---

## Next Steps

Start where mistakes are cheap. Learn fast. Move inward toward higher-risk systems slowly.
