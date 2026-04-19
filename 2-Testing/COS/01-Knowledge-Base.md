# The Knowledge Base: What You Know About This Domain

## Quick Answer

**Your Knowledge Base is structured information about a domain that guides your decisions.** It answers: what exists (ontology), how things break (dynamics), how you observe breaks (epistemology), why breaks matter (teleology), and how to fix them (control). You build it as you operate, not before. It gets stronger after each action because evidence refines it.

**The five layers apply everywhere:** systems engineering, recruiting, trading, hiring, consulting. Learn the pattern once; apply it to any domain.

---

## The Five Pillars at a Glance

Every domain reduces to five layers:

| Pillar | Question | Answer |
|--------|----------|--------|
| **Ontology** | What patterns persist? | Named, coherent objects (primitives) |
| **Dynamics** | How do patterns change? | Allowed state transitions; what fails |
| **Epistemology** | How do changes appear? | Observable symptoms (signatures) |
| **Teleology** | Why do some changes matter more? | Goal-relative importance (impact) |
| **Control** | What inputs alter trajectory? | Mitigations; interventions that redirect outcomes |

**Why this matters:** These five layers apply everywhere. Once you understand the pattern, you can build a Knowledge Base in any domain—without years of upfront expertise.

---

## The Loop

```
Knowledge Base (what you know)
    ↓ informs
Execution (what you do)
    ↓ produces
Evidence (task → outcome)
    ↓ updates
Knowledge Base (loop repeats, stronger)
```

Your Knowledge Base is the first side of the loop. It's what you know about a domain — structured so it guides decisions.

---

## Part 1: Deep Dive — The Five Pillars

Every domain has exactly five layers of knowledge. These five apply everywhere—from systems engineering to recruiting to trading. Learning this pattern once lets you build a Knowledge Base in any domain. You don't need domain expertise first; you need to understand these five layers.

### **Ontology: What Patterns Persist?**

**Summary:** Ontology defines the named objects in your domain—the primitives you choose to track. These are the patterns coherent enough to name, boundary-defined enough to track across state changes. Without naming, you can't measure failure.

**Answer:** The named, coherent objects in your domain. You choose which patterns are "real" enough to name. These are your primitives.

**Examples:**
- **Systems engineering:** process, thread, socket, disk, filesystem
- **Recruiting:** candidate, requisition, pipeline stage, engagement
- **Trading:** position, order, fill, market signal

**Why this matters:** If you don't name it, you can't track it. If you can't track it, you can't know when it fails.

---

### **Dynamics: How Can Patterns Change?**

**Summary:** Dynamics describes how your primitives evolve over time—the allowed state transitions and failure modes. Critical distinction: change is any state transition; failure is undesired change relative to an expectation. A disk aging is change. A disk missing writes is failure.

**Answer:** The allowed state transitions. What can go wrong. Critically: failure ≠ change. Failure = undesired change relative to an expectation.

**Examples:**
- A disk aging = change. A disk no longer performing = failure.
- A candidate becoming unavailable = change. A candidate ghosting (violating expectation) = failure.
- A position moving = change. A position exceeding risk limits = failure.

**Key distinction:** Failure requires three things: (1) an object, (2) an expected function, (3) a deviation from that function.

---

### **Epistemology: How Do Changes Appear?**

**Summary:** Epistemology maps how failures manifest at observational layers. The same root cause (disk failure) looks different from different layers: high I/O wait at system level, latency cliffs at application level, timeouts at client level. One failure, many observable surfaces.

**Answer:** The observable symptoms when things go wrong. The signatures. One root cause, many observational surfaces.

**Examples:**
- **Disk failure shows as:** high I/O wait, stalled writes, stuck processes
- **Candidate ghosting shows as:** silence after interest signal, missed responses
- **Position blowup shows as:** sudden P&L swing, margin call

**Why this matters:** You usually see the symptom before you know the root cause. This layer teaches you to recognize patterns by what you actually observe.

---

### **Teleology: Why Do Some Changes Matter More?**

**Summary:** Teleology ranks failures by impact relative to your goals. Not all failures are equal. Storage failure (data loss possible) matters more than CPU failure (restart the process). Your Knowledge Base must mark which failures justify escalation and which you can handle autonomously.

**Answer:** Goal-relative importance. Impact. Not all failures are equal. Your knowledge base must mark which ones matter.

**Examples:**
- **CPU failure:** low impact (restart the process)
- **Storage failure:** high impact (data loss possible)
- **Quorum loss in distributed system:** critical impact (system halts)

**Why this matters:** You make tradeoff decisions based on impact. Understanding which failures matter most lets you prioritize what to learn first.

---

### **Control: What Inputs Alter the Trajectory?**

**Summary:** Control describes interventions that redirect outcomes. Not all fixes are equal: some address root cause, others mitigate symptoms, others prevent cascades. Good mitigations understand second-order effects. Increasing retries prevents timeout, but creates retry storms. Adding cache prevents latency, but creates staleness.

**Answer:** Mitigations. The interventions that change the outcome. Good mitigations understand second-order effects.

**Examples:**
- **Disk failure:** switch to replica, buy time to recover
- **Candidate ghosting:** escalate with call, validate interest, adjust timeline
- **Position blowup:** reduce size, hedge, or exit

**Critical insight:** Increasing retries can create retry storms. Adding cache can create staleness. Fixing one problem can create another. Your Control layer must track this.

---

## Part 2: How to Structure Your Knowledge Base

**Summary:** Three structural properties determine whether your Knowledge Base compounds or stagnates: controlled vocabulary (stable names), relationships that trace root cause to action, and evidence tiers that separate what you know from what you guess. Without structure, each observation feels new.

**What makes a Knowledge Base useful:**

### **1. Controlled Vocabulary**

**What it is:** Every primitive, failure mode, symptom, and impact has a stable name. Use a naming convention so "runaway-fork" always means the same thing—never "runaway" one week and "fork-bomb" the next.

**Naming pattern:**
- `primitive:process` — named, tracked object
- `failure:runaway-fork` — undesired state transition
- `symptom:high-load` — observable projection of failure
- `impact:system-halt` — goal-relative consequence
- `mitigation:kill-process` — intervention to redirect outcome

**Why it matters:** Without stable names, each observation looks new. Your Knowledge Base can't compound. Stable names force consolidation.

---

### **2. Relationships That Matter**

**What it is:** Connect the five layers explicitly. Trace from symptom → root cause → action without thinking.

**Example chain:**
- `primitive:process` fails as
- `failure:runaway-fork` appears as
- `symptom:high-load` causes
- `impact:cpu-starvation` mitigated by
- `mitigation:kill-process`

**Why it matters:** When you observe high load, you trace back to "runaway-fork" and forward to "kill the process" instantly. Relationships automate reasoning.

---

### **3. Evidence Tiers**

**What it is:** Mark confidence level for every claim. Never blur the tiers—separate what you know, infer, guess, and lack.

| Tier | Meaning | Example | How to Act |
|------|---------|---------|-----------|
| **Known** | Observed repeatedly, predictive | "When disk fills, writes stall" | Act on it autonomously |
| **Inferred** | Derived from evidence, not directly observed | "This cascaded through 3 services" | Use it, but escalate if high stakes |
| **Guessed** | Educated guess, low confidence | "Maybe this was a network blip" | Test it, don't bet on it |
| **Unknown** | No evidence either way | "How does this behave at >10k QPS?" | Mark as gap, investigate later |

**Critical rule:** If you mark something "known" when it's really "guessed," the feedback loop breaks. You'll repeat mistakes thinking you've learned them.

---

## Part 3: Building Your Knowledge Base in a Domain

**Summary:** Don't build a complete Knowledge Base before operating. Build it as you execute in three phases: establish baseline primitives, gather evidence through execution, promote patterns only after repetition. Each cycle strengthens the Knowledge Base.

You don't start with a complete picture. You build it as you execute.

### **Phase 1: Start with Baseline Primitives**

**What to identify before entering the domain:**
- What are the named entities? (objects)
- What do they do? (basic function)
- How do they relate? (relationships)

**Example (recruiting):**
- `Candidate` — person applying
- `Requisition` — open job
- `Pipeline` — candidate → stages → offer/reject
- `Engagement` — customer conversation

**Note:** Baseline is rough and incomplete. That's fine. You'll refine it immediately.

---

### **Phase 2: Execute and Gather Evidence**

**Every action produces evidence. Capture it as you go.**

**Example:**
- **Action:** Send outreach to candidate
- **Result:** No response for 7 days
- **Evidence:** 
  - symptom: `candidate-silence`
  - possible failure: `candidate-ghosting` OR `inbox-filter`
  - impact: `pipeline-stall`
  - what-worked: escalate with follow-up (got response)

**Practice:** Don't wait for perfection. "Candidate ghosted" is enough. Refine later.

---

### **Phase 3: Promote Patterns (Slowly)**

**Only promote knowledge when it recurs. Never promote on first success.**

**Example:**
- First time: candidate went silent → Evidence tier: `GUESSED` (one data point)
- Fourth time: candidate goes silent, respond to escalation → Evidence tier: `KNOWN` (pattern recurs, action works)

**Promotion rules — promote to "KNOWN" only after:**
- **Repetition:** ≥3 occurrences
- **Consistent outcome:** same action produces same result each time
- **Survival under variation:** works with different candidates, timing, messaging

---

## Part 4: Complete Knowledge Record Template

**Summary:** Every failure mode gets one record. Use the Five Pillars as the template structure. This record connects what breaks (Dynamic) to how you observe it (Epistemology) to why it matters (Teleology) to what you do about it (Control). One template handles every failure mode across every domain.

**Structure every failure mode like this:**

### **Template: Complete Knowledge Record**

For any primitive failure mode:

```
Failure Mode: candidate-ghosting

Primitive: candidate
Dynamic: unresponsiveness after interest signal
  - What happens: candidate shows interest, then stops responding

Epistemology: How to detect
  - Symptom: silence >3 days after interest signal
  - Observable: no email response, no availability confirmation
  - False positive risk: candidate busy (common)

Teleology: Why it matters
  - Impact: pipeline stall, timeline slip
  - Blast radius: medium (affects one hire, not company)
  - Reversibility: high (can re-engage after weeks)
  - Cost: lost time, opportunity cost

Control: How to intervene
  - Escalate: switch communication channel (call instead of email)
  - Learn: follow up 48h after initial contact (proven effective)
  - Validate: ask directly about availability before continuing

Evidence Tier: KNOWN (observed 8 times, escalation works 6/8)
```

**What this record lets you do:**
- Understand the failure (why it happens)
- Recognize it (what to look for)
- Know why it matters (impact)
- Know what to do (mitigation)
- Know your confidence (evidence tier)

---

## Part 5: Validators — How Knowledge Stays Coherent

**Summary:** As your Knowledge Base grows, contradictions appear. Validators catch them before they break your logic. Example: you record "Candidates ghost when we wait >5 days to respond," then find a counterexample where they responded after 8 days. Validators refine boundaries until contradictions disappear.

**When contradictions appear, ask: Do both things happen, or is one wrong?**

**Use validators to resolve:**

```
Validator: candidate-ghosting-pattern
  IF: candidate-silence > 3 days
  THEN: classify as candidate-ghosting
  EXCEPT: if-we-havent-responded-yet (silence is mutual)
  
Evidence: Seen 8 times, 6 confirmed ghosting, 2 false positives (mutual silence)
```

**What validators do:**
- Spot contradictions ("wait, this shouldn't be classified as ghosting")
- Refine boundaries ("ghosting only counts if we've already engaged")
- Improve accuracy ("false positives drop from 2/8 to 0/8")

---

## Part 6: How This Informs Execution

**Summary:** Your Knowledge Base doesn't sit idle. Before each action, consult it to decide what to do. After each action, update it with what you learned. The loop closes: Knowledge → Execution → Evidence → Updated Knowledge → Better Execution.

**Before an action: "What does my knowledge base say?"**

**Example scenario:** New candidate, showed interest, no response for 2 days
- **Knowledge Base says:** symptom: potential `candidate-ghosting` (early), evidence tier: `KNOWN` pattern, mitigation: escalate to call (effective 6/8 times)
- **Impact:** if true, we lose 1 hire slot
- **Decision:** Call candidate instead of waiting (based on knowledge)

**After an action: "What does this outcome tell me?"**

**Example:** Called candidate
- **Result:** Candidate was in interview prep, didn't see emails, very interested
- **New evidence:** 
  - Ghosting pattern has a variant (not inbox silence, but attention shift)
  - Escalation to call is more effective than previously thought
  - Timing matters (2 days is right threshold to intervene)
- **Update:** Refine the mitigation rule

**The loop closes:** Knowledge → Execution → Evidence → Updated Knowledge → Better Execution

---

## Summary: Why This Matters

**The core principle:** Your Knowledge Base is not a passive library. It's active, cyclic, honest, and actionable. It constrains what you'll try and gets better after each execution.

**Your Knowledge Base is:**
- **Active** — constrains what you'll try (only escalate when pattern is known)
- **Cyclic** — gets better after each execution (evidence refines it)
- **Honest** — marks confidence so you don't confuse guesses with facts
- **Actionable** — every record connects to what you should actually do

**When entering a new domain, start with:**
1. **Baseline primitives** — what are the things?
2. **Initial failure modes** — what breaks?
3. **Observable symptoms** — what does broken look like?
4. **A learning discipline** — promote patterns slowly, mark confidence honestly

**Then execute.** The domain teaches you the rest through the feedback loop.

---

<!-- FAQ Schema: This section contains structured Q&A about Knowledge Base implementation. Each Q/A pair represents a common question during Knowledge Base building. -->

## FAQ: Knowledge Base Questions

**Q: Should I document knowledge before I execute, or after?**
A: Both. Start with baseline primitives (10% knowledge, 90% gaps). Then execute and let evidence fill the gaps. Never wait for complete knowledge before starting.

**Q: How many failure modes should my Knowledge Base have?**
A: Start with 5-10 major ones. Add more as you execute and discover new patterns. If you have >50, compress—you probably have duplicates with different names.

**Q: What if my evidence tier is always "guessed"?**
A: You're not executing frequently enough, or you're not repeating the same actions. To promote to "known," you need the same scenario 3+ times. If scenarios are always different, focus on primitives instead of failure modes.

**Q: My Knowledge Base contradicts itself. What do I do?**
A: This is normal. Use validators to resolve. The contradiction usually means your boundaries are fuzzy. Refine them until the contradiction disappears.

**Q: How do I know when my Knowledge Base is "good enough" to execute on?**
A: When you can answer: (1) What are the 3-5 main failure modes? (2) What does each look like? (3) What makes each one important? If you have these, you're ready.

**Q: Should I use a database, wiki, or document for my Knowledge Base?**
A: Start with a document with clear structure (primitives, failures, symptoms, impacts, mitigations). Scale to a database only when you have >100 records and need cross-linking.

**Q: Can I copy someone else's Knowledge Base for my domain?**
A: Yes, as a starting point. But validate every single thing. Their context is different. Mark everything as "inferred" until you confirm it in your specific domain.

**Q: How often should I review and update my Knowledge Base?**
A: After every significant execution (weekly). Look for new patterns, contradictions, and gaps. Promotion from "guessed" to "known" should happen regularly if you're executing frequently.
