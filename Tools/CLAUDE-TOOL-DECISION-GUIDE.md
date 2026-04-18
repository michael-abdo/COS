# Claude Tool Decision Guide

## Visual Decision Tree

When you want Claude to behave differently, use this flowchart to choose the right tool:

```mermaid
%%{init: {'theme': 'dark'}}%%
flowchart TD
    START["I want Claude to<br/>do X differently"]
    style START fill:#1e293b,color:#e2e8f0,stroke:#60a5fa

    Q1{"Can a markdown file<br/>handle this?"}
    style Q1 fill:#1e293b,color:#e2e8f0,stroke:#f59e0b

    Q_EVERY{"Does Claude need this<br/>on every single turn?"}
    style Q_EVERY fill:#1e293b,color:#e2e8f0,stroke:#f59e0b

    Q_FLOOD{"Will this flood<br/>the conversation?"}
    style Q_FLOOD fill:#1e293b,color:#e2e8f0,stroke:#f59e0b

    ALWAYS["CLAUDE.md or Memory<br/><br/>Here are the rules,<br/>follow them always"]
    style ALWAYS fill:#166534,color:#e2e8f0,stroke:#4ade80

    SKILL["Skill - SKILL.md<br/><br/>Here is how to do this<br/>when it comes up"]
    style SKILL fill:#1e40af,color:#e2e8f0,stroke:#60a5fa

    AGENT["Agent - forked context<br/><br/>Go figure this out,<br/>come back with the answer"]
    style AGENT fill:#6b21a8,color:#e2e8f0,stroke:#a78bfa

    Q_CHOOSE{"Does Claude need<br/>to choose when?"}
    style Q_CHOOSE fill:#7f1d1d,color:#e2e8f0,stroke:#f87171

    MCP["MCP Server<br/><br/>You can use this tool<br/>when you think you need it"]
    style MCP fill:#991b1b,color:#e2e8f0,stroke:#f87171

    HOOK["Hook<br/><br/>This runs no matter<br/>what you think"]
    style HOOK fill:#7f1d1d,color:#e2e8f0,stroke:#ef4444

    SPECTRUM["High trust ← CLAUDE.md - Skill - Agent - MCP - Hook → Low trust"]
    style SPECTRUM fill:#0f172a,color:#94a3b8,stroke:#475569

    START --> Q1
    Q1 -- "Yes" --> Q_EVERY
    Q1 -- "No" --> Q_CHOOSE

    Q_EVERY -- "Yes" --> ALWAYS
    Q_EVERY -- "No" --> Q_FLOOD

    Q_FLOOD -- "No" --> SKILL
    Q_FLOOD -- "Yes" --> AGENT

    Q_CHOOSE -- "Yes" --> MCP
    Q_CHOOSE -- "No" --> HOOK

    ALWAYS ~~~ SPECTRUM
```

---

## The 5 Options (High Trust → Low Trust)

### 1. CLAUDE.md or Memory
**Trust Level: 🟢🟢🟢 HIGHEST**

- **When to use:** Rules that apply to every Claude Code session in this repo
- **Example:** AEO formatting rules (always apply, never optional)
- **Who decides:** You decide upfront; Claude follows automatically
- **Change control:** Edit the file, change applies to all future sessions

### 2. Skill (SKILL.md)
**Trust Level: 🟢🟢 HIGH**

- **When to use:** How-tos for specific workflows; Claude invokes when relevant
- **Example:** "Run the gap audit before submitting" — user types `/gap-audit`
- **Who decides:** User explicitly invokes (`/skill-name`)
- **Change control:** Skills are version-controlled; changes apply on invocation

### 3. Agent
**Trust Level: 🟡 MEDIUM**

- **When to use:** Complex, multi-step tasks; Claude spawns a separate session to think independently
- **Example:** "Analyze this codebase and find architecture patterns"
- **Who decides:** Claude decides whether to spawn an agent (based on guidance in CLAUDE.md)
- **Change control:** Agents run with fresh context; no session state carries over

### 4. MCP Server
**Trust Level: 🟠🟠 LOW-MEDIUM**

- **When to use:** Tool access that Claude can optionally use when it thinks it needs it
- **Example:** "You have access to the PostgreSQL MCP server to query the database"
- **Who decides:** Claude decides when to call the tool
- **Change control:** Tools are always available; Claude chooses invocation

### 5. Hook (Pre/Post Tool Use)
**Trust Level: 🔴 LOWEST**

- **When to use:** Automated guardrails that run whether Claude likes it or not
- **Example:** "Block `rm -rf` commands" — runs before any bash command executes
- **Who decides:** Hook runs automatically, no discretion
- **Change control:** Hooks are enforced globally; always active

---

## Quick Reference

| Option | Applies To | Who Decides | Update Frequency | Example |
|--------|-----------|------------|------------------|---------|
| **CLAUDE.md** | Every session, always | You (upfront) | File edit | "Always use tables for structured data" |
| **Skill** | When user invokes | User (explicit) | Version-controlled | `/gap-audit` command |
| **Agent** | On complex tasks | Claude (guided) | Per-invocation | "Spawn explorer agent for codebase analysis" |
| **MCP Server** | Optional tool use | Claude (when needed) | Available always | Database query access |
| **Hook** | Every action (auto) | Automatic | Always active | "Block destructive bash commands" |

---

## Writing Guidelines by Tool Type

### ✍️ CLAUDE.md
- **Audience:** Claude reading it every session
- **Format:** Markdown sections with clear headings
- **Length:** Concise; keep it scannable
- **Tone:** Imperative ("Always...", "Never...", "Do this...")
- **Update:** When rules change fundamentally

### ✍️ Skill.md
- **Audience:** Claude deciding when to invoke (via `/command`)
- **Format:** Markdown with command name, description, steps
- **Length:** Fit in ~200-500 words; link to longer docs if needed
- **Tone:** Procedural (step-by-step, "then do X")
- **Update:** When the workflow changes

### ✍️ Agent Prompts
- **Audience:** Fresh Claude session with no prior context
- **Format:** Complete briefs; assume zero context carry-over
- **Length:** 300-500 words of clear instructions
- **Tone:** Narrative ("You're being asked to...", "The context is...")
- **Update:** Per-task; can change without affecting repo

### ✍️ MCP Servers
- **Audience:** Claude's tool selection logic
- **Format:** Function signatures + docstrings
- **Length:** Concise; let the tool design speak
- **Tone:** Technical (parameter names, return types)
- **Update:** When API surface changes

### ✍️ Hooks
- **Audience:** Bash/tool use logic (pre/post)
- **Format:** Shell scripts with clear comments
- **Length:** Minimal; run fast
- **Tone:** Technical (grep patterns, exit codes)
- **Update:** When security/safety boundaries change

---

## AEO Rules Apply To Documents, Not Tools

**Important:** The **AEO Formatting Rules** (40-60 word summaries, H2/H3 hierarchy, multi-domain examples) apply to **documents you write in this repo** (Knowledge Base, Execution, Learning, Foundations guides). 

AEO rules do **NOT** apply to:
- CLAUDE.md itself (tools have different standards)
- Skills/Agents/Hooks (procedural, not educational)
- MCP server code (technical specification, not prose)

**Applies to:** Core educational documents, tutorials, guides, reference materials.
