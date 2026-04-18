# The Ideal Employee Agent Tool

## Core Concept

Build autonomous agents that operate like $150k+ professionals: make decisions independently, escalate only when necessary, produce verifiable work, and improve continuously through feedback loops.

The gap between "good prompt" and "autonomous employee" is not smarter models—it's **structure**. Specifically: theory that governs when to act vs. escalate, and implementation that encodes that theory into executable behavior.

### The Real Goal: A Scalable Framework

The $150k hiring agent is **not the end product—it's the test chassis.**

| Component | Purpose |
|-----------|---------|
| **Repo** | Domain-agnostic framework: template structure, Claude behavior files, skill library, documentation |
| **Test Chassis** | Hiring agent: proof that framework works end-to-end; validates risk gating, feedback loops, artifact verification, continuous learning |
| **Scale** | Replicate validated framework across N domains (trading, consulting, systems, sales, product) with domain-specific Five Pillars |

**Why this architecture:** Prove the pattern works once (hiring) → demonstrate transferability (2-3 more domains) → scale to infinite contexts. Same infrastructure, infinite specializations.

---

## THEORY: How Autonomous Agents Think

### 1. Risk Management Gates Every Action

**Before any decision, score six factors:**
- Blast Radius — what breaks if I'm wrong?
- Reversibility — can I undo this?
- Observability — will I notice failure?
- Novelty — have I done this before?
- Privilege — who does this affect?
- Time Pressure — how urgent?

**Decision rule:** Blast Radius=HIGH OR Reversibility=LOW OR Privilege=HIGH → ESCALATE. Otherwise PROCEED.

**Why this matters:** Agents that skip risk assessment make irreversible mistakes at scale. This gate prevents cascading failures before they happen.

### 2. Knowledge Builds Incrementally Through Evidence Tiers

**Not:** "I know this works" (guessing).  
**But:** Evidence tier progression (GUESSED → SUSPECTED → KNOWN → PROVEN).

| Tier | Definition | Instances |
|------|-----------|-----------|
| **GUESSED** | One-off observation, untested | 1-2 |
| **SUSPECTED** | Observed pattern, not yet repeated | 3-5 |
| **KNOWN** | Pattern confirmed across variations | 10+ |
| **PROVEN** | Pattern holds at scale | 100+ |

**Why this matters:** Prevents false confidence. An agent that treats guesses as knowledge will confidently make the same mistake repeatedly. Evidence tiers force honesty about what you actually know.

### 3. Feedback Loops Close Automatically

**Every action generates evidence → Evidence refines Knowledge Base → Next action uses better knowledge → Loop repeats.**

Two types of feedback:
- **Prescriptive** — "How things should be" (L1-L5 decomposition, testing fixes)
- **Descriptive** — "How things actually are" (metrics, logs, outcomes)

Both feed the Knowledge Base. Both require risk gating. Neither happens in isolation.

**Why this matters:** Without closed loops, agents execute the same way forever. Feedback is how they improve from experience instead of staying static.

### 4. Knowledge Transfers Across Domains Through Five Pillars

Every domain (trading, hiring, consulting, systems) has:
- **Ontology** — what objects matter (positions, candidates, tickets)
- **Dynamics** — how they fail (position blowup, ghosting, stale data)
- **Epistemology** — how failures appear (P&L swing, silence, timeout)
- **Teleology** — which failures matter most (economic impact)
- **Control** — how to redirect outcomes (mitigations, escalations)

Learn the pattern once → apply everywhere.

**Why this matters:** Agents don't need domain expertise upfront. They need a universal reasoning structure. Once you map the Five Pillars for hiring, you can map them identically for trading. Knowledge becomes portable.

---

## HOW: Implementation in Claude Code

### 1. Knowledge Base = Five Pillars + Concrete Examples

**File structure:**
```
01-Knowledge-Base.md
├─ Ontology: Named objects in your domain (with 3+ examples)
├─ Dynamics: How they fail (with 3+ examples)
├─ Epistemology: How failures appear (with 3+ examples)
├─ Teleology: Which failures matter (with 3+ examples)
└─ Control: Mitigations for each failure (with 3+ examples)

02-Execution.md
├─ L1-L5 Decomposition Protocol (concern → intent → failure → test → artifact)
├─ 6-Factor Risk Model (when to escalate)
└─ Evidence Capture Template (expected vs. actual vs. surprise)

03-Learning.md
├─ Evidence Tier Promotion Rules
├─ Feedback Loop Closure
└─ Knowledge Base Update Protocol
```

**Concrete = examples in every section.** Not abstract: "Ontology is objects." Concrete: "In hiring, Ontology is {candidates, requisitions, engagements}. Example: candidate records must include {skills, availability, interview history} to distinguish one from another."

### 2. Execution = Claude Code Prompts + Hooks

**CLAUDE.md in project root:**
- Risk Management rules (when to escalate)
- L1-L5 decomposition walkthrough (concern → artifact)
- Evidence capture protocol (expected vs. actual → tier)
- Artifact verification gates (10-second rule)

**Hooks (.claude/hooks.yml):**
- `pre-execute`: Run 6-Factor Risk Model before any action
- `post-action`: Capture evidence (expected vs. actual)
- `knowledge-update`: Tier evidence and promote patterns

**Pluggable Skills:**
- `concern-to-intent` — decompose fuzzy requests into testable specs
- `risk-assess` — run 6-Factor model
- `evidence-tier` — classify observation by confidence
- `knowledge-promote` — move pattern up tier ladder
- `artifact-verify` — confirm output passes 10-second rule

### 3. Agents = Instantiated Per Workflow, Not Fixed Roster

**Same engine (Claude Code) + different specializations (prompts + skills):**

| Role | Specialization | Skills | Knowledge |
|------|---|---|---|
| **Validator** | Conservative gatekeeper | risk-assess, artifact-verify | Failure modes, escalation thresholds |
| **Executor** | Action-oriented doer | concern-to-intent, evidence-tier | Domain-specific primitives |
| **Learner** | Pattern analyzer | evidence-tier, knowledge-promote | Evidence tiers, confidence rules |
| **Escalator** | Human-facing bridge | artifact-verify, concern-to-intent | When/how/why to escalate |

One workflow = chain of agents. Each agent inherits shared Knowledge Base, loads only needed skills, produces artifact for next agent.

### 4. Verification = Artifacts, Not Code

**Every agent output must pass:**
- ✅ **10-second rule** — human glances and says "yes" or "no"
- ✅ **Binary result** — PASS/FAIL, not interpretation
- ✅ **Verifiable with tools** — screenshot, curl response, query result, GIF, test output

**Bad artifacts:** Code files, log dumps, "I updated X," status reports  
**Good artifacts:** Rendered pages, PDFs, curl responses, test output, email search results

---

## Bridging Theory ↔ Implementation

| Theory | Implementation |
|--------|---|
| Risk Management gates every action | `pre-execute` hook runs 6-Factor model before any tool call |
| Evidence tiers prevent false confidence | `evidence-tier` skill classifies every outcome; promotes only after 10+ instances |
| Feedback loops improve Knowledge Base | `post-action` hook captures evidence; `knowledge-promote` updates KB |
| Five Pillars transfer across domains | Template `01-Knowledge-Base.md` has Five Pillars structure; fill in your domain |
| Agents specialize but share KB | Shared KB in project root; agents load different skills/prompts per role |
| Artifacts verify, not code | `artifact-verify` skill enforces 10-second rule before human sees output |

---

## One-Week Autonomy Test

Agent runs for 5 business days with zero human intervention.

**PASS if:**
- ✅ >95% of decisions are autonomous (≤5% escalated)
- ✅ All escalations triggered by explicit risk flags (HIGH blast, LOW reversibility, HIGH privilege)
- ✅ Every artifact passes 10-second rule (human confirms in glance)
- ✅ Knowledge Base tier distribution shifts (more KNOWN, fewer GUESSED)
- ✅ Agent demonstrates learning (Week 2 uses better patterns than Week 1)

**FAIL if:**
- ❌ >10% of decisions require human approval
- ❌ Escalations triggered by "I'm not sure" instead of risk model
- ❌ Artifacts require reading code or scrolling to verify
- ❌ Knowledge Base unchanged (no new KNOWN patterns)
- ❌ Agent repeats same approach despite consistent failures

---

## Why This Works

**Theory provides the reasoning:**
- When to act independently (risk is bounded)
- When to escalate (risk is unmanageable)
- How to learn from outcomes (evidence tiers)
- How to transfer knowledge (Five Pillars)

**Implementation provides the structure:**
- Prompts that encode the theory
- Hooks that enforce the gating
- Skills that operationalize the protocol
- Artifacts that prove it worked

**Together:** An agent that thinks like a professional employee—not because it's smarter, but because it follows the same decision-making structure that makes experienced humans reliable.