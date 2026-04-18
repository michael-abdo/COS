# AEO Rules vs Plugin/Skill Best Practices

## Core Difference

| Aspect           | AEO Document Rules                       | Plugin/Skill Best Practices                               |
| ---------------- | ---------------------------------------- | --------------------------------------------------------- |
| **Primary Goal** | Optimize for LLM citation & AI ingestion | Optimize for user invocation & execution clarity          |
| **Audience**     | AI systems reading/citing your docs      | Humans deciding when to use a tool                        |
| **Structure**    | Answer-first, summary-heavy              | Action-first, goal-first                                  |
| **Example**      | "Knowledge Base is..." (define term)     | "`/gap-audit`: Run quality audit on code" (invoke action) |

---

## The Two Paths

### 📖 Path 1: Documents (AEO Rules Apply)

**What:** Core knowledge documents, guides, reference materials  
**Where:** `template-docs/`, `docs/`, tutorials  
**Rules:** Follow AEO 10-rule checklist

**Examples of AEO documents:**
- 01-Knowledge-Base.md (what the Five Pillars are)
- 02-Execution.md (how to execute safely)
- 03-Learning.md (how to close the feedback loop)
- 04-Foundations.md (why the system works)

**Structure: Summary → Answer → Examples → Why**
```markdown
## Ontology: What Patterns Persist?

**Summary:** [40-60 words answering the core question]

**The question:** What patterns persist enough to name?

**The answer:** [Core concept, literal language, no metaphors]

**Examples:**
- Domain 1: [example]
- Domain 2: [example]
- Domain 3: [example]

**Why this matters:** [Impact/importance]
```

---

### 🔧 Path 2: Procedural Content (AEO Rules Do NOT Apply)

**What:** Skills, agents, hooks, MCP servers, CLAUDE.md  
**Where:** `.claude/`, `hooks/`, `skills/`  
**Rules:** **Different standards apply** (see below)

**Examples of procedural content:**
- Skills: `gap-audit.md` (how to run an audit)
- CLAUDE.md: "Always use tables for structured data"
- Hooks: `block-destructive-bash.sh` (prevent `rm -rf`)
- Agents: "Explore the codebase and report..."

**Structure: Action → Context → Steps**
```markdown
## Gap Audit (Skill)

**When to use:** After implementing a feature, before submitting

**What it does:** Audits code against design docs (ERD, workflow, UI)

**How to invoke:** `/gap-audit`

**Steps:**
1. Read the three foundation docs
2. Compare documented vs implemented capabilities
3. Classify gaps: Code Bug, Missing Capability, Partial Implementation, Architecture Gap
```

---

## Writing Standards by Tool Type

### 📄 CLAUDE.md (Global Rules)

**AEO applies?** ❌ No  
**Standard:** Concise, imperative

| Aspect | Standard | Why | Example |
|--------|----------|-----|---------|
| **Summary needed?** | No | Rules don't need explanation | "Never change EMAIL_SAFETY_MODE without confirmation" |
| **Multi-domain examples?** | No | Rules are universal | "This applies to all VVG projects" |
| **Structure** | Rule + Context + Impact | Fast scanning for safety | "HARD RULE — no exceptions, no shortcuts" |
| **Length** | 1-5 lines per rule | Scannable | "**NEVER** remove the safety gate in email/service.ts" |

**Bad (over-explained):**
```markdown
## Email Safety

The email safety gate is important because we learned a hard lesson when...
You should always remember to check EMAIL_SAFETY_MODE...
It's a best practice to...
```

**Good (imperative):**
```markdown
## VVG Email Safety Gate

- **NEVER** change `EMAIL_SAFETY_MODE` to `live` without explicit human confirmation
- **NEVER** remove or weaken the safety gate in `src/lib/email/safety.ts`
- Default is `EMAIL_SAFETY_MODE=block` (nothing leaves)
- This is a hard safety rule — no exceptions
```

---

### 🎯 Skill.md (User-Invoked Actions)

**AEO applies?** ❌ No  
**Standard:** Goal-first, procedural

| Aspect | Standard | Why | Example |
|--------|----------|-----|---------|
| **When to use section?** | Yes | User decides relevance | "Use this after writing code, before submitting for review" |
| **Summary?** | Brief (1 sentence) | State the outcome | "Audits code against design docs and classifies gaps" |
| **Multi-domain examples?** | No | Skills are tool-specific | "`/gap-audit` works on any implementation" |
| **Step-by-step?** | Yes | Procedural clarity | "1. Read ERD; 2. Compare; 3. Classify gaps" |
| **Length** | 200-400 words | Scannable + complete | Full skill fits in one screen |

**Bad (too documented):**
```markdown
## Gap Audit

The gap audit skill is based on the concept that every implementation...
Historically, we've found that teams often miss important details when...
The process involves understanding the three foundation documents...
First, you should read the ERD carefully. The ERD defines...
Then you should check your code against it...
```

**Good (action-first):**
```markdown
## Gap Audit

**When to use:** After implementing a feature, before code review  
**What it does:** Compares code to design docs; flags missing capabilities

**Invoke:** `/gap-audit`

**Steps:**
1. Read the three foundation docs: ERD.mmd, workflow.mmd, UI
2. Compare documented capabilities vs your implementation
3. Classify gaps: Code Bug / Missing Capability / Partial / Architecture Gap
4. Fix or document each gap before submitting
```

---

### 🤖 Agent Prompts (Independent Research)

**AEO applies?** ❌ No  
**Standard:** Full context, narrative

| Aspect | Standard | Why | Example |
|--------|----------|-----|---------|
| **Summary of task?** | Yes | Fresh context, assume zero prior knowledge | "Your job is to explore the codebase and..." |
| **Background context?** | Yes | Agent has no session history | "Here's why we're doing this..." |
| **Expected output?** | Yes | Clear deliverable | "Return: file paths, patterns found, recommendations" |
| **Multi-domain examples?** | No | Task-specific | "In this repo, look for X patterns" |
| **Length** | 300-500 words | Complete brief | One long paragraph or 3-5 sections |

**Good agent prompt:**
```markdown
Explore the codebase to find all API endpoints and their security checks.
Context: We're auditing auth behavior across the system.
Return: List of endpoints, which have auth checks, which don't, recommendations.
```

---

### 🔌 MCP Servers (Tool Functions)

**AEO applies?** ❌ No  
**Standard:** Function specification

| Aspect | Standard | Why | Example |
|--------|----------|-----|---------|
| **Docstring needed?** | Yes | Claude reads function signatures | "Query the database and return rows matching pattern" |
| **Examples?** | Only in docstring | Concise reference | One example per function in the docstring |
| **Prose explanation?** | No | Code is the spec | Parameters speak for themselves |
| **Length** | Function signature + 1-2 line docstring | Technical clarity | `def query(sql: str) -> List[Dict]` |

**Good MCP function:**
```python
def crm_query(sql: str, max_rows: int = 50) -> dict:
    """Query the Consulting CRM database (read-only, tenant-scoped).
    Args: sql (SELECT query), max_rows (max 100)
    Returns: dict with rows, rowCount, latencyMs
    """
```

---

### 🪝 Hooks (Automated Safety)

**AEO applies?** ❌ No  
**Standard:** Minimal, fast

| Aspect | Standard | Why | Example |
|--------|----------|-----|---------|
| **Comments?** | Yes, minimal | Explain what's blocked and why | "# Block: rm -rf prevents data loss" |
| **Explanation prose?** | No | Run fast, no extra processing | Just the grep pattern + exit logic |
| **Examples?** | Comments only | Self-documenting via grep patterns | `grep "rm -rf" # blocks recursive delete` |
| **Length** | 10-30 lines | Minimal overhead | Hook runs before EVERY bash command |

**Good hook:**
```bash
#!/bin/bash
# Pre-bash hook: block dangerous commands

patterns=(
  "rm -rf"           # recursive delete
  "git push --force" # force push (can overwrite upstream)
  "\.env"            # credential files
)

for pattern in "${patterns[@]}"; do
  if [[ "$command" =~ $pattern ]]; then
    echo "❌ BLOCKED: $pattern (safety rule)"
    exit 1
  fi
done
```

---

## Decision Matrix

**When writing new content, ask:**

| Question | Answer → Use Standard |
|----------|---|
| "Is this a core concept people need to understand?" | **AEO document rules** (40-60 summaries, multi-domain examples) |
| "Is this a procedure someone will invoke?" | **Skill standards** (goal-first, steps, when-to-use) |
| "Is this a rule Claude always follows?" | **CLAUDE.md standards** (imperative, no explanation) |
| "Is this a complex research task?" | **Agent standards** (full context, narrative) |
| "Is this a tool function?" | **MCP standards** (function signature + docstring) |
| "Is this automated enforcement?" | **Hook standards** (minimal, fast) |

---

## Example: Documenting a New Feature

**Feature:** Automated screenshot capture for QA

### ✅ Do Use AEO Rules (If writing educational content)
```markdown
## Screenshot Automation: Capturing Evidence

**Summary:** Screenshot automation uses Claude's Chrome MCP to verify UI changes...
[Answer] [Examples from 3 domains] [Why it matters]
```
→ For: `docs/guides/screenshot-testing.md` (educational guide)

### ❌ Don't Use AEO Rules (If writing procedural content)
```markdown
## Using Screenshot Capture in QA Tests

**When to use:** After UI changes, before submitting  
**Invoke:** Via `gif_creator` MCP server  
**Steps:**  
1. Call `mcp__claude-in-chrome__screenshot`  
2. Verify viewport dimensions...
```
→ For: `skills/qa-screenshot.md` (procedural skill)

---

## Summary

| Path | Uses AEO? | Format | When | Audience |
|------|---|---------|------|----------|
| **Documents** | ✅ Yes | Summaries + Examples | Learning/reference | AI systems + humans learning |
| **CLAUDE.md** | ❌ No | Rules + Context | Every session | Claude executing rules |
| **Skills** | ❌ No | When + Steps | User invokes | Humans deciding/acting |
| **Agents** | ❌ No | Full brief | Complex task | Fresh Claude session |
| **MCP** | ❌ No | Function spec | Tool available | Claude choosing tools |
| **Hooks** | ❌ No | Minimal code | Auto-enforce | Bash pre-processor |

**Key:** AEO optimizes for **citation and understanding**. Procedural tools optimize for **action and clarity**. They serve different masters.
