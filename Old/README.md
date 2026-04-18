# Old/Archive — Legacy Documentation

This folder contains legacy best practices and reference documents from the original monolithic CLAUDE.md. These have been decomposed into the proper COS structure:

- **Knowledge Base/** — Core concepts in AEO format (Ontology, Epistemology, Risk Model, L2-L5)
- **.claude/skills/** — Executable skills and procedures
- **CLAUDE.md** — New, focused project instructions
- **AGENT-PROCEDURES.md** — Agent behavior rules
- **COS-L2-L5-CONCERNS.md** — User-level threat model (kept at root as reference)
- **AGENTIC-OPERATING-SYSTEM.md** — Meta-architecture (kept at root as reference)

## Files Archived Here

| File | Purpose | Why Moved |
|------|---------|----------|
| AEO-vs-PLUGIN-BEST-PRACTICES.md | AEO formatting comparison | Superseded by CLAUDE.md + Knowledge Base examples |
| IDEAL-EMPLOYEE-AGENT-TOOL.md | Aspirational agent design | Reference only; built into AGENT-PROCEDURES.md |
| claude-tool-decision-tree.mmd | Tool selection diagram | Reference; specialized agents need their own decision trees |
| GF17_Rev3_BidSpec12_MindScope_Validation_2026-04-04_11-49AM_CT.docx | Business validation doc | Project-specific; not COS framework |
| USE CASE STORY | Use case narrative | Moved to archive to keep root clean |

## What's Kept at Root

- **README.md** — Project overview
- **CLAUDE.md** — Project instructions (new, focused)
- **AGENT-PROCEDURES.md** — Universal agent rules
- **COS-L2-L5-CONCERNS.md** — Reference for threat model
- **AGENTIC-OPERATING-SYSTEM.md** — Reference for meta-architecture
- **Knowledge Base/** — AEO-formatted concepts
- **.claude/skills/** — Active skills and procedures

This structure allows children agents to load only what they need, when they need it.
