# COS: Cognitive Operating System

**An infrastructure for instantiating infinite specialized agents on demand.**

## What This Is

COS is not a fixed roster of agents. It's an operating system that spawns domain-specific agents (hiring, trading, systems, consulting) as needed, each inheriting shared knowledge and using pluggable skills.

- **Father Bot (you):** Creates frameworks, knowledge base, decision models
- **Children Agents:** Domain executors that run autonomous loops (DISCUSS → LOOP → verify)
- **Closed Feedback Loop:** Every execution updates the knowledge base, making the next agent stronger

## Architecture

| Layer | Purpose |
|-------|---------|
| **Knowledge Base/** | AEO-formatted core concepts, transferable across domains |
| **AGENT-PROCEDURES.md** | Universal rules all agents follow |
| **.claude/skills/** | Pluggable procedures agents load |
| **COS Framework** | L2-L5 decomposition, 6-Factor risk gates, evidence tiering, artifact verification |
| **Marketplace Plugins** | Pre-built skills from cos-marketplace (disambiguate, etc.) |

## Core Skills

Four foundation skills enable the autonomous loop:

| Skill | Purpose |
|-------|---------|
| **concern-to-intent** | Decompose fuzzy request → L3 invariant → L5 binary test |
| **risk-assess** | Score 6 factors (blast radius, reversibility, etc.) → PROCEED/ESCALATE/SHRINK |
| **evidence-tier** | Classify pattern confidence (GUESSED → SUSPECTED → KNOWN → PROVEN) |
| **artifact-verify** | Validate output is glance-verifiable in 10 seconds |

## Quick Start

1. **Read** `CLAUDE.md` for formatting standards and multi-agent architecture
2. **Review** `COS-L2-L5-CONCERNS.md` for the 24 user-level threats and binary tests
3. **Understand** `AGENTIC-OPERATING-SYSTEM.md` for the agent chain pattern
4. **Explore** `Knowledge Base/` for core concepts

## Building a Child Agent

1. Define their domain concern (what could go wrong?)
2. Create domain-specific CLAUDE.md (copy from parent, extend)
3. Add domain Knowledge Base documents (AEO format)
4. Load marketplace plugins as needed (e.g., `/plugin install disambiguate@cos-marketplace`)
5. Set them loose with `/loop` to execute autonomously

## Status

- [x] Father bot identity defined
- [x] Core skills documented (4 disabled)
- [x] L2-L5 concern framework (24 user-level threats)
- [x] AEO formatting standards
- [ ] Skills activated
- [ ] Initial Knowledge Base documents created
- [ ] Children agents spawned for first domain
