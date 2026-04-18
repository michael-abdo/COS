# Building a Child Agent: How to Spawn Domain-Specific Executors

**Quick Answer:** Spawn a child agent by defining their domain concern, copying parent CLAUDE.md, adding domain-specific Knowledge Base docs, loading marketplace plugins, and releasing them with `/loop` for autonomous execution.

## Core Foundation Skills

Four skills enable the autonomous execution loop:

| Skill | Purpose |
|-------|---------|
| **concern-to-intent** | Decompose fuzzy request → L3 invariant → L5 binary test |
| **risk-assess** | Score 6 factors (blast radius, reversibility, etc.) → PROCEED/ESCALATE/SHRINK |
| **evidence-tier** | Classify pattern confidence (GUESSED → SUSPECTED → KNOWN → PROVEN) |
| **artifact-verify** | Validate output is glance-verifiable in 10 seconds |

## The Five-Step Process

**Step 1: Define Domain Concern**
What could go wrong in this domain? (Hiring: "wrong candidates advance." Trading: "position exceeds risk tolerance." Systems: "deployment breaks production.") This becomes the child's mission.

**Step 2: Copy Parent CLAUDE.md**
Clone `/Users/Mike/2025-2030/Systems/COS/CLAUDE.md` into the domain project root. Extend with domain-specific procedures, risk gates, and evidence tiers.

**Step 3: Build Domain Knowledge Base**
Create domain-specific AEO-formatted documents covering:
- Ontology (named primitives the domain tracks)
- Risk model (domain-specific 6-factor gates)
- Procedures (domain workflows)
- Examples across sub-domains (hiring: recruiting, interviews, offers; trading: positions, fills, market signals)

**Step 4: Load Marketplace Plugins**
Install pre-built skills from `cos-marketplace`:
- `disambiguate` — clarify fuzzy requests
- `concern-decompose` — break concerns into L2-L5
- Domain-specific plugins (e.g., `hiring-screening`, `trading-risk-check`)

**Step 5: Release with /loop**
Execute: `/loop "Run autonomous workflow for [domain concern]"` with constraints from CLAUDE.md. Agent runs closed feedback loop: DISCUSS (align) → LOOP (execute) → verify (test) → update Knowledge Base.

## What the Child Inherits

- **Parent Knowledge Base** — Core COS concepts, transferable across domains
- **Parent CLAUDE.md** — Formatting standards, L2-L5 process, multi-agent architecture
- **Parent Framework** — 6-Factor risk gates, evidence tiering, artifact verification
- **Parent Skills** — Foundation skills (concern-to-intent, risk-assess, evidence-tier, artifact-verify)

## Feedback Loop

Each child execution produces:
- **Evidence** — Patterns observed, confidence tier assigned
- **Updates** — New Knowledge Base docs, refined procedures, discovered edge cases
- **Inheritance** — Stronger agents inherit the updated KB, repeat

This is how the system learns: child agents discover patterns → parent KB grows → all future children are stronger.
