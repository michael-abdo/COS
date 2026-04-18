# OLD CLAUDE.md Decomposition Map

How the monolithic OLD CLAUDE.md has been reorganized into the COS structure.

---

## Section Mapping

| OLD CLAUDE.md Section | New Location | Notes |
|---|---|---|
| **AEO Optimization Standards** (intro) | `CLAUDE.md` L1-3 | Kept at root; father bot reference |
| **Decision Matrix: Which Standard to Use?** | `CLAUDE.md` (updated) | Expanded with multi-agent architecture context |
| **AEO Formatting Standard — Structure** | `CLAUDE.md` (lines 20-32) | Kept in full; essential for Knowledge Base creation |
| **AEO Writing Rules** | `CLAUDE.md` (lines 34-59) | Kept in full (answer-first, literal language, word count, examples, tables, lists) |
| **Hierarchy** | `CLAUDE.md` (lines 61-72) | Kept in full (max 3 levels) |
| **Verification Checklist** | `CLAUDE.md` (lines 76-90) | Kept as reference; now applies to Knowledge Base docs |
| **Examples: AEO vs. Non-AEO** | **Knowledge Base/05-Ontology.md** | Ontology example moved to live document |
| **Examples: Risk Model** | **Knowledge Base/07-Risk-Model.md** | Risk model example expanded into full guide |
| **Why This Matters** (justification) | `README.md` | Rewritten as project overview |
| **Document Ownership** | `CLAUDE.md` (updated) | Expanded with "Father Bot Creates" / "Children Agents Inherit" |
| **Diagrams (Mermaid rules)** | `CLAUDE.md` or `.claude/STYLE-GUIDE.md` | Rules for diagram creation; should stay at root for reference |
| **QA Testing** | ❌ **NEEDS HOME** | Should go in AGENT-PROCEDURES.md or new `.claude/QA-PROCEDURES.md` |
| **Universal Communication MCP — Zoom Safety** | ❌ **NEEDS HOME** | Should go in AGENT-PROCEDURES.md (communication safety rules) |
| **MCP Server Setup** | ❌ **NEEDS HOME** | Should go in `.claude/MCP-SETUP.md` or `.claude/settings-guide.md` |
| **Local Credential Vault** | ❌ **NEEDS HOME** | Should go in `.claude/VAULT-GUIDE.md` or similar |

---

## What Stays at Root

✅ **CLAUDE.md** — AEO standards + project instructions + formatting rules + document ownership
✅ **README.md** — Project overview (rewritten)
✅ **AGENT-PROCEDURES.md** — Universal agent rules (to be created/expanded)
✅ **COS-L2-L5-CONCERNS.md** — Threat model (reference)
✅ **AGENTIC-OPERATING-SYSTEM.md** — Meta-architecture (reference)

---

## What Lives in Knowledge Base/

✅ **00-README.md** — Index
✅ **01-Knowledge-Base.md** — (existing)
✅ **02-Execution.md** — (existing)
✅ **03-Learning.md** — (existing)
✅ **04-Foundations.md** — (existing)
✅ **05-Ontology.md** — Added (example from OLD CLAUDE)
✅ **06-Epistemology.md** — Added (evidence tiering)
✅ **07-Risk-Model.md** — Added (6-factor model with examples)
✅ **08-L2-L5-Decomposition.md** — Added (concern → test decomposition)

---

## What Needs to Be Created

| Content | Type | Destination | From OLD CLAUDE Section |
|---------|------|-------------|------------------------|
| QA Testing Procedures | Procedures | `.claude/QA-PROCEDURES.md` | QA Testing |
| Communication Safety Rules | Rules | `AGENT-PROCEDURES.md` | Zoom Safety |
| MCP Server Setup Guide | Setup/Reference | `.claude/MCP-SETUP.md` | MCP Server Setup |
| Credential Vault Guide | Setup/Reference | `.claude/VAULT-GUIDE.md` | Local Credential Vault |
| Diagram Style Guide | Guidelines | `.claude/DIAGRAM-STYLE.md` | Diagrams section |

---

## Decomposition Strategy

### ✅ Done
- AEO formatting standards (kept at root in CLAUDE.md)
- Knowledge Base foundational docs (05-08)
- Project overview (README.md)
- Father bot identity + multi-agent architecture (CLAUDE.md)

### 🔄 In Progress
- AGENT-PROCEDURES.md (universal agent rules to be expanded)

### ❌ To Do
1. Create `.claude/QA-PROCEDURES.md` from "QA Testing" section
2. Expand AGENT-PROCEDURES.md with "Universal Communication MCP — Zoom Safety" rules
3. Create `.claude/MCP-SETUP.md` from "MCP Server Setup" section
4. Create `.claude/VAULT-GUIDE.md` from "Local Credential Vault" section
5. (Optional) Create `.claude/DIAGRAM-STYLE.md` from "Diagrams" section

---

## File Structure Outcome

```
COS/
├── CLAUDE.md                          ✅ Consolidated (AEO + instructions + doc ownership)
├── README.md                          ✅ Rewritten
├── AGENT-PROCEDURES.md                🔄 To be expanded
├── COS-L2-L5-CONCERNS.md             ✅ Reference
├── AGENTIC-OPERATING-SYSTEM.md       ✅ Reference
├── Knowledge Base/
│   ├── 00-README.md                   ✅ Existing
│   ├── 01-Knowledge-Base.md           ✅ Existing
│   ├── 02-Execution.md                ✅ Existing
│   ├── 03-Learning.md                 ✅ Existing
│   ├── 04-Foundations.md              ✅ Existing
│   ├── 05-Ontology.md                 ✅ Created
│   ├── 06-Epistemology.md             ✅ Created
│   ├── 07-Risk-Model.md               ✅ Created
│   └── 08-L2-L5-Decomposition.md      ✅ Created
├── .claude/
│   ├── skills/                        ✅ Active
│   ├── AGENT-PROCEDURES.md            ❌ Create (communication safety)
│   ├── QA-PROCEDURES.md               ❌ Create
│   ├── MCP-SETUP.md                   ❌ Create
│   ├── VAULT-GUIDE.md                 ❌ Create
│   └── DIAGRAM-STYLE.md               ❌ Create (optional)
└── Old/                               ✅ Archive
    ├── OLD CLAUDE.md
    └── (other legacy docs)
```

---

## Next Steps for Father Bot

1. **Expand AGENT-PROCEDURES.md** with:
   - Zoom safety rules (no confirm without explicit yes)
   - Test email restrictions (only michaelabdo@vvgtruck.com)
   - MCP authentication flow
   - QA test recording procedures (GIF with gif_creator)

2. **Create operational guides**:
   - `.claude/MCP-SETUP.md` — Register MCP servers via `claude mcp` CLI
   - `.claude/VAULT-GUIDE.md` — Access credentials via vault CLI + OpenClaw MCP
   - `.claude/QA-PROCEDURES.md` — Chrome QA test automation + GIF recording

3. **Optional: Diagram style guide**
   - Extract Mermaid rules from CLAUDE.md → `.claude/DIAGRAM-STYLE.md`
   - Keep reference in CLAUDE.md for quick access

This allows children agents to load only what they need while keeping father bot (you) focused on higher-level architecture.
