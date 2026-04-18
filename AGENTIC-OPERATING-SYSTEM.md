# Agentic Operating System — Infinite Agent Factory

## Core Concept

**Not a fixed roster of agents. An infrastructure that instantiates agents on demand for any workflow stage.**

One engine (Claude Code), infinite specializations (agent prompts + skills). Each agent:
- Inherits shared Knowledge Base (no redundancy)
- Loads only required skills (composable)
- Respects universal risk gates (6-Factor model)
- Produces artifact for next agent in chain
- Feeds evidence back to KB (learning loop)

## Why This Works

| Property | Benefit |
|----------|---------|
| **Shared Knowledge Base** | Agents don't replicate expertise; all draw from same Five Pillars |
| **Pluggable Skills** | Load only what each agent needs; minimal overhead per instantiation |
| **Universal Risk Gates** | Same 6-Factor model everywhere; consistent safety boundaries |
| **Artifact Handoff** | Output of Agent[N] = input to Agent[N+1]; no manual translation |
| **Structural Feedback** | Evidence from any agent → KB update → improves all agents |
| **Scale to Infinity** | Workflow has 7 handoffs? Create 7 agents. 47 handoffs? 47 agents. Same infrastructure. |

## Workflow as Agent Chain

Instead of monolithic agent, design the workflow as a handoff sequence:

```
INPUT
  ↓
Agent[1] (e.g., Dataset Validator)
├─ Skill: precondition checking
├─ Personality: conservative blocker
└─ Output: PASS/BLOCK
  ↓ (if PASS)
Agent[2] (e.g., L5 Decomposer)
├─ Skill: L1-L5 breakdown
├─ Personality: action-oriented
└─ Output: L5 test + artifact
  ↓
Agent[3] (e.g., Risk Assessor)
├─ Skill: 6-Factor model
├─ Personality: escalation-focused
└─ Output: PROCEED/ESCALATE
  ↓ (if PROCEED)
Agent[4] (e.g., Evidence Tierer)
├─ Skill: outcome observation
├─ Personality: pattern-seeking
└─ Output: evidence tier → KB update
  ↓
FEEDBACK TO KB
```

## No Fixed Roster

Agents are **generated per workflow**, not predefined:

| Workflow Example | Agents Needed |
|---|---|
| Job application pipeline | Scraper → Parser → Matcher → Proposal Writer → Reviewer → Submitter → Logger |
| Trading signal discovery | Data ingester → Pattern finder → Hypothesis generator → Backtester → Risk analyzer → Trader |
| Research synthesis | Paper fetcher → Abstract extractor → Theme mapper → Evidence tierer → KB integrator |
| System debugging | Log analyzer → Symptom classifier → Root cause mapper → Mitigation tester → KB updater |

Each workflow spawns its own agent chain. Same infrastructure, different instantiations.

## Implementation Anchors

**Knowledge Base:** Domain expertise (Five Pillars, examples, failure modes)  
**Execution Protocol:** L1-L5 decomposition (concern → verifiable artifact)  
**Risk Model:** 6-Factor gating (same everywhere)  
**Skill Library:** Pluggable capabilities (load what agent needs)  
**Claude Code:** Runtime engine (agent instantiation + execution)  
**Feedback Loops:** Evidence tiering (outcome → KB refined)

## Success Looks Like

One workflow request:
1. System analyzes: "This needs X handoffs"
2. Spawns X agents with appropriate skills + prompts
3. Each agent executes its role, produces artifact for next
4. Output artifact passes 10-second glance test
5. Evidence feeds back to KB
6. Next workflow (same domain) runs stronger because KB improved

**No redesign. No rebuild. Infinite adaptation through specialization.**

That's an Operating System for agents.
