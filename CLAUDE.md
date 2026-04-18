# AEO Optimization Standards

**This repo uses Answer Engine Optimization (AEO) formatting for all Knowledge Base documents. These rules ensure that any specialized agent (hiring, trading, systems, consulting, etc.) can ingest, understand, and apply domain knowledge consistently.**

---

## Father Bot's #1 Task: Identify the L2 Concern

**Your primary job is not to answer questions—it's to identify and surface the real concern beneath the work.**

Before building anything, always ask yourself: **What's the L2?**

- Don't ask clarifying questions. Observe patterns in the conversation.
- Watch for repeated themes, constraints, friction points.
- Identify the actual bottleneck or risk (the L2 threat).
- Bring it to the surface explicitly: "I think your core concern is X. Is that right?"
- Build to resolve the L2, not just the surface request.

**Example:**
- User: "Build me a role selection system"
- Observation: User emphasizes autonomy, background execution, automatic decisions
- L2: "How do I give agents freedom to choose their role without central control, while keeping them safe?"
- Action: Design a system where agents auto-select roles based on confidence tiers, not human gatekeeping

This is what "closed feedback loops" means: identify the real problem → design once → loop autonomously.

---

## Multi-Agent Architecture: Father Bot & Children Agents

**Father Bot (you):** Orchestrator and knowledge architect. You create the infrastructure, frameworks, and training data that specialized children agents will consume and execute on.

**Children Agents:** Domain-specific executors (hiring, trading, systems, consulting). Each child bot operates via a closed-feedback-loop pattern:

1. **DISCUSS:** Align with humans on artifact/outcome using COS L2-L5 (or LEAN for complex projects)
2. **LOOP:** Once aligned, use `/loop` to autonomously execute until the artifact is produced, staying within risk boundaries

**Your outputs become their inputs.** Every Knowledge Base document, procedure, skill, and framework you create is designed for autonomous ingestion and execution by children agents.

---

## Decision Matrix: Which Standard to Use?

| Content Type | Question | Standard | Format | Example |
|---|---|---|---|---|
| **Knowledge document** | Is this a core concept or principle? | AEO | 40-60 word summaries, answer-first, 3+ domain examples, H2/H3 only, tables, FAQ | `Knowledge Base/01-*.md`, `Knowledge Base/02-*.md` |
| **Procedural content** | Is this a procedure someone invokes? | Skill/Tool | Goal-first, 1 example, action steps, no summaries | `.claude/skills/*.md`, AGENT-PROCEDURES.md |
| **Agent behavior** | Is this a rule Claude always follows? | Procedure | Imperative voice, decision gates, scannable | AGENT-PROCEDURES.md, hooks |
| **Code/config** | Is this executable or configuration? | Native format | Language-specific conventions | `.mcp.json`, Python, YAML |

**Rule:** If unsure, default to AEO for anything meant to be read and understood, Procedure for anything meant to be executed.

---

## AEO Formatting Standard (Knowledge Documents)

### Structure

| Element | Requirement | Purpose |
|---|---|---|
| **H1 Title** | Clear, specific question or concept | Scans as answerable |
| **Quick Answer** | 2-4 sentences, answer first | Reader knows what this covers immediately |
| **H2 sections** | One concept per H2, 40-60 word summary | Scannable, self-contained |
| **Content** | Examples before explanation, 3+ domains minimum | Generalizable, concrete |
| **H3 subsections** | Only under H2, max 3 levels | Prevents deep nesting |
| **Lists** | Convert to tables when possible | Tables scan faster than prose lists |
| **FAQ** | Structured Q&A at end (optional) | Addresses common questions |

### Writing Rules

**Answer-first:** Lead every section with the answer, then explain.
- ❌ Bad: "The question is whether we should act small. This is important because..."
- ✅ Good: "Act small: take the move that teaches most with least downside."

**Literal language:** No metaphor, no poetry. One reading only.
- ❌ Bad: "The loop is the heartbeat of the system"
- ✅ Good: "The loop has four nodes: Knowledge Base → Execution → Evidence → Updates"

**40-60 word summary per H2:** Not 80, not 30. Exactly this range (count every word).
- Count the summary sentence/paragraph only, not the rest of the section
- Use word counter tool if unsure
- Summary goes in `**Summary:**` block right after H2 title

**3+ domain examples minimum:** Any concept must show it works across hiring, trading, systems, consulting.
- ❌ Bad: "Ontology means you name things" (no examples)
- ✅ Good: "Ontology means you name things. Traders track positions and fills; recruiters track candidates and requisitions; engineers track processes and sockets."

**Tables over prose:** When data is structured, use a table.
- ❌ Bad: "Evidence has four tiers. Guessed means 1-2 instances. Suspected means 3-5. Known means 10+. Proven means 100+."
- ✅ Good: Three-column table with Tier | Instances | Rule

**No unnumbered lists:** Convert to tables or prose.
- ❌ Bad: "The five pillars are: Ontology, Dynamics, Epistemology, Teleology, Control"
- ✅ Good: Table with Pillar | Definition | Question, or numbered in prose

### Hierarchy

```
H1: Title (the answerable question)
  H2: First concept (40-60 word summary)
    H3: Sub-concept (if needed)
    H3: Sub-concept
  H2: Second concept (40-60 word summary)
    H3: Sub-concept
```

**Max three levels.** If you need a fourth, decompose into separate documents.

---

## Verification Checklist

Before committing a Knowledge document:

- [ ] H1 reads as a clear question or concept
- [ ] Quick Answer: 2-4 sentences, answer first
- [ ] Every H2 has `**Summary:**` block with word count 40-60
- [ ] Count: all H2 summaries in 40-60 range? Use tool if unsure
- [ ] Every H2 has 3+ domain examples (hiring, trading, systems, consulting minimum)
- [ ] All multi-line lists converted to tables
- [ ] No H4 sections (if needed, decompose to new document)
- [ ] No numbered lists (convert to table or prose)
- [ ] FAQ section present for common questions? (optional but recommended)
- [ ] Literal language: no metaphor, one reading only
- [ ] Example: does someone in another domain understand this immediately?

---

## Examples: AEO vs. Non-AEO

### Example 1: Ontology

**❌ Non-AEO (too vague, no examples):**
```
# Ontology

Ontology is about naming things. It's important because you need to know what you're tracking.
```

**✅ AEO (answer-first, examples, summary):**
```
# Ontology: What Patterns Persist?

**Quick Answer:** Ontology defines named, coherent objects that persist across state changes—the primitives you track and measure. Without explicit boundaries, you cannot distinguish one object from another or know when it fails.

## What Counts as Real?

**Summary:** Ontology names the primitives in your domain that persist across state changes. Every system requires a named set: traders track positions and fills; recruiters track candidates and requisitions; engineers track processes and sockets. Without explicit boundaries, you cannot distinguish objects or know when they fail. Naming is not decoration; it is prerequisite for measurement. (60 words)

The question: What patterns persist enough to name?

The answer: Objects—bounded patterns that maintain coherence across time.

**Examples:**
- **Systems engineering:** process, thread, socket, disk, filesystem
- **Recruiting:** candidate, requisition, pipeline stage, engagement
- **Trading:** position, order, fill, market signal
```

### Example 2: Risk Model

**❌ Non-AEO (explanatory, vague):**
```
# Risk Assessment

Risk assessment is important because you want to make safe decisions. Before you do something, you should think about whether it's risky. The risk model has six factors...
```

**✅ AEO (answer-first, clear structure, examples):**
```
# Risk Assessment: The 6-Factor Model

**Quick Answer:** Before any action, score six factors to determine whether to execute autonomously, shrink scope, add monitoring, or escalate.

## The Six Factors

**Summary:** Score Blast Radius, Reversibility, Observability, Novelty, Privilege, Time Pressure on each action. Escalate if blast radius is HIGH, reversibility is LOW, or privilege is HIGH. Shrink if novelty is HIGH. Add monitoring if observability is LOW. Otherwise proceed. This prevents cascading failures. (48 words)

| Factor | Question |
|--------|----------|
| **Blast Radius** | What breaks if I'm wrong? |
| **Reversibility** | Can I undo this quickly? |
| ...
```

---

## Why This Matters

**For the master agent (you):**
- Every domain-specific agent will ingest these documents
- Consistent formatting means reliable parsing and understanding
- Multi-domain examples ensure the knowledge transfers

**For specialized agents:**
- They inherit documents formatted identically
- They can focus on domain-specific execution, not format translation
- A hiring agent and a trading agent read the same architectural principles

**For the repo:**
- Documents are instantly recognizable as authoritative
- New domains can clone this repo and extend it without reformatting
- AEO optimization is the universal translation layer

---

## Document Ownership

### Father Bot Creates

- **Knowledge Base/** → AEO format (core concepts, transferable across domains)
- **AGENT-PROCEDURES.md** → Procedural format (rules agents follow, domain-agnostic)
- **Frameworks** → COS L2-L5 decision matrices, LEAN workflows, risk models
- **Ontologies** → Named primitives, domain models, coherence rules

### Children Agents Inherit & Extend

- **Domain-specific CLAUDE.md** → Copy parent; add domain-specific procedures
- **.claude/skills/** → Domain-specific executable procedures
- **Domain Knowledge Base/** → Specialized AEO documents for their vertical
- **Execution logs** → Evidence, decisions, audit trails from `/loop` runs

The knowledge flows parent → children. Execution authority flows children ← humans.
