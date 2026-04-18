# COS Template — Autonomous Agent at $150k+

## The Goal: Fully-Managed Execution

Build a domain-specific agent capable of operating autonomously at professional income levels ($150k+). Success requires three measurable conditions:

| Criterion | Pass Condition | Verification |
|-----------|---|---|
| **a) Structure Knowledge** | Agent has deep enough domain knowledge to operate independently: decompose concerns, identify edge cases, execute without constant human guidance | Knowledge Base fully specified; all Five Pillars (Ontology, Dynamics, Epistemology, Teleology, Control) mapped with 3+ domain examples per pillar |
| **b) Communication Confidence** | Human stakeholders trust agent outputs without reading code; decisions are verifiable at a glance in <10 seconds | Every artifact passes 10-second rule; L5 tests are binary (pass/fail); reasoning chain is visible (L2→L3→L4→L5→artifact) |
| **c) Edge Risk Stability** | Agent handles unknowns safely; escalates only when Blast Radius=HIGH, Reversibility=LOW, or Privilege=HIGH; operates autonomously otherwise | 6-Factor Risk Model applied to every action; escalation rules explicit; >90% of decisions executed autonomously within bounded risk |

## PASS/FAIL Checklist

### FAIL if ANY of these are true:
- ❌ Agent requires human approval for >10% of decisions (edge case handling is too conservative)
- ❌ Communication requires reading code or reasoning (artifacts aren't glance-verifiable)
- ❌ Knowledge Base has unexplained gaps (Teleology unmapped, Dynamics incomplete, Control mitigations missing)
- ❌ Risk model not applied consistently (agent escalates for wrong reasons, or proceeds into genuine hazards)

### PASS if ALL of these are true:
- ✅ Knowledge Base fully specified (all 5 Pillars mapped, 3+ domain examples, <10% unknown patterns)
- ✅ 95%+ of agent decisions are autonomous and reversible within 6-Factor bounds
- ✅ Every output is verifiable artifact (screenshot, GIF, query result, test pass, curl response)
- ✅ Escalation only occurs for: HIGH blast radius, LOW reversibility, HIGH privilege
- ✅ Agent runs one week without human intervention; outcomes meet acceptance criteria

---

## What's in this template

- **template-docs/** — 5 COS documents as domain-agnostic stubs (fill in your examples)
- **CLAUDE.md** — Global instructions for risk-averse behavior, L1-L5 decomposition, artifact-first development
- **.claude/** — Safety config (hooks, settings, MCP servers)
- **CLAUDE-TOOL-DECISION-GUIDE.md** — When to use which Claude tool
- **AEO-vs-PLUGIN-BEST-PRACTICES.md** — Document vs procedural content standards

---

## Quick start

1. **Customize the Knowledge Base:** Fill template-docs/ with your domain's Five Pillars
   - 00-README.md — domain intro
   - 01-Knowledge-Base.md — what you know (ontology, failure modes, patterns)
   - 02-Execution.md — how you act (decomposition, evidence, escalation)
   - 03-Learning.md — feedback loops (observation, tier promotion, KB updates)
   - 04-Foundations.md — deep principles (five pillars applied across domains)

2. **Specify Edge Case Handling:** Document in Dynamics + Control
   - What failures can occur? (Dynamics)
   - How does each look? (Epistemology)
   - When do we escalate vs. handle autonomously? (Teleology + Risk model)

3. **Test Autonomy:** Run agent for 1 week, measure:
   - % of decisions autonomous vs. escalated
   - % of artifacts that pass 10-second rule
   - Knowledge Base gap count (should trend to zero)

4. **Iterate:** Evidence feeds back to Knowledge Base; refine until PASS criteria met

---

## Success Looks Like

One agent, no domain expert in loop:
- Receives prescriptive request (concern)
- Decomposes to L5 test (intent verified)
- Executes autonomously, respecting risk bounds
- Produces artifact human glances and approves
- Runs week-long batch with zero escalations outside policy

That's $150k autonomous. Everything else is implementation detail.
