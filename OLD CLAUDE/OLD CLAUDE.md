# AEO Optimization Standards

**This repo uses Answer Engine Optimization (AEO) formatting for all Knowledge Base documents. These rules ensure that any specialized agent (hiring, trading, systems, consulting, etc.) can ingest, understand, and apply domain knowledge consistently.**

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

- **Knowledge Base/** → AEO format (core concepts, transferable across domains)
- **AGENT-PROCEDURES.md** → Procedural format (rules agents follow, domain-agnostic)
- **.claude/skills/** → Skill format (individual agent procedures)
- **CLAUDE.md (at domain root)** → Copy this file; add domain-specific procedures as needed


## Diagrams

- Always create diagrams as `.mmd` (Mermaid) files, not inline in markdown
- Store diagrams alongside related documentation
- Use descriptive filenames: `ERD.mmd`, `architecture.mmd`, `flow.mmd`
- Use **dark theme** for all diagrams: `%%{init: {'theme': 'dark'}}%%` at the top of every `.mmd` file. For flowcharts/other diagrams that support inline styles, use light text on dark backgrounds (e.g. `fill:#1e293b,color:#e2e8f0,stroke:#60a5fa`). Never use dark text on dark backgrounds.
- Never use numbered lists (`1.`, `2.`), single quotes, or `@` symbols inside Mermaid node text `["..."]` — they trigger "Unsupported markdown" errors. Use `→` arrows, plain text, and `at` instead of `@` for emails.
- **Prevent text overlap**: Keep node text SHORT (max ~4 lines per node). When a node needs more detail, split it into multiple connected nodes or use a subgraph label. Add `<br/>` line breaks generously. For flowcharts, prefer `TB` (top-to-bottom) direction for complex diagrams — it gives more horizontal room. Never cram long descriptions into decision diamonds or small boxes.
- **Layout is edge-driven, not declaration-order**: Mermaid uses topological sorting (dagre) to place nodes. In `flowchart TD`, sources go top and sinks go bottom. Declaration order in the `.mmd` file has zero effect on placement. If node A should be at the top, ensure nothing below A has an edge pointing back to A. Back-edges (child → parent) create cycles that cause unexpected layouts — use static label text (e.g. "→ back to sender") instead of actual edges when showing return flows.
- **Verify layout with PNG**: Use `npx -y @mermaid-js/mermaid-cli -i file.mmd -o file.png -w 2400 -b transparent` to generate a PNG, then view with Read tool. Do not create HTML wrappers.
- After creating/writing a `.mmd` file, open it directly in Chrome with `open /path/to/file.mmd` — a browser extension renders Mermaid natively. No need for HTML wrappers or Mermaid Live Editor URLs.

## QA Testing

- When running QA test suites via Chrome MCP, record a GIF for each test using `gif_creator`
- Start recording before the test actions, stop after verification, and export with a descriptive filename (e.g., `test1-total-leads.gif`)
- Enable click indicators and action labels so the GIF clearly shows what was tested
- Save GIFs alongside the test definition file (e.g., in the `tests/` directory)

## Universal Communication MCP — Zoom Safety

- **NEVER send a Zoom message without EXPLICIT user confirmation.** This applies to ALL contexts including tests, demos, and debugging. Zoom messages are instant and irreversible.
- When `messages_send` (or any send tool) returns a preview for a Zoom message, you MUST show the full preview to the user and wait for their explicit "yes" / "confirmed" / "send it" before calling `confirm_send`.
- When confirming a Zoom send, you MUST pass `zoom_confirmed=True` to `confirm_send`. The server will reject Zoom confirms without this flag.
- **Test emails ONLY to `michaelabdo@vvgtruck.com`.** All tests that involve sending real messages must use `michaelabdo@vvgtruck.com` as the recipient. Never send test messages to other addresses.
- This is a hard safety rule — no exceptions, no shortcuts, no "just this once."



## MCP Server Setup

Adding MCP servers to Claude Code CLI requires using the `claude mcp` command. The `~/.claude/.mcp.json` file alone is NOT sufficient — servers must be registered via CLI.

### Commands that work

```bash
# Add via JSON (best for servers with env vars):
claude mcp add-json <name> '{"command":"...","args":["..."],"env":{"KEY":"value"}}'

# Add simple server:
claude mcp add <name> <command> -- <args...>

# List / verify:
claude mcp list

# Remove:
claude mcp remove <name>
```

### Current MCP Servers

```bash
# Universal Communication Layer
claude mcp add-json universal '{"command":"/Users/Mike/2025-2030/Systems/communication/universal/.venv/bin/python","args":["/Users/Mike/2025-2030/Systems/communication/universal/mcp_server.py"],"env":{"DATABASE_URL":"postgresql://postgres:mikiel2026@localhost:5433/communications"}}'

# PostgreSQL MCP (GCP tunnel to communications DB)
claude mcp add-json postgres '{"command":"/Users/Mike/2025-2030/Systems/mcp/postgres-mcp/venv/bin/python","args":["/Users/Mike/2025-2030/Systems/mcp/postgres-mcp/server.py"]}'
```

### Notes

- Servers are saved to project-level config at `/Users/Mike/.claude.json`
- Restart Claude Code after adding servers for them to load
- The `~/.claude/.mcp.json` file uses `mcpServers` wrapper key but CLI registration is still required

## Local Credential Vault

A local, GPG-encrypted password vault at `~/2025-2030/Systems/credentials/vault/`. Extracted from all Chrome profiles, deduplicated, encrypted with RSA-4096. Plaintext never touches disk.

- **Vault file:** `~/2025-2030/Systems/credentials/vault/vault.json.gpg`
- **GPG Key:** `F0935E2BDC862F69` (Mike <vault@local>)
- **CLI location:** `/usr/local/bin/vault` (symlink → vault dir)
- **Source profiles:** Zenex, Mike (stonkz), Michael, Person 1 — 837 deduplicated entries

### CLI Commands

| Command | Description |
|---------|-------------|
| `vault get <query>` | Search + copy password to clipboard |
| `vault list` | Show all URLs + usernames (no passwords) |
| `vault search <query>` | Search by URL or username |
| `vault show <query>` | Display password in terminal |
| `vault add <url> <user> <pass>` | Add new entry |
| `vault import` | Re-extract from Chrome + merge into vault |
| `vault stats` | Show vault statistics |

### Architecture

```
Chrome DBs → AES decrypt (Keychain) → JSON in memory → GPG encrypt → vault.json.gpg
vault get <query> → GPG decrypt (in memory) → search → pbcopy → clipboard
```

### OpenClaw MCP Integration

The vault is integrated into the OpenClaw MCP server (`~/2025-2030/Systems/vm-claude/openclaw_mcp.py`), giving Claude programmatic access to credentials during browser automation.

| MCP Tool | Description |
|----------|-------------|
| `openclaw_vault_search <query>` | Search vault by URL/username (no passwords returned) |
| `openclaw_vault_get <query>` | Retrieve credential with password (for programmatic use) |
| `openclaw_vault_autofill <url> [profile]` | Navigate to URL, find vault credentials, auto-fill login form |
| `openclaw_vault_totp <query>` | Generate current TOTP 2FA code for a credential |
| `openclaw_vault_list` | List all vault entries (URLs + usernames only) |
| `openclaw_vault_stats` | Show vault statistics |
| `openclaw_gv_sms [profile]` | Read recent Google Voice SMS messages, extract 2FA codes |
| `openclaw_gv_read_thread <contact> [profile]` | Open and read a specific GV conversation thread |

**Auto-login flow:** `openclaw_vault_autofill "https://example.com/login" "zenex"` → vault lookup → navigate → fill form → ready to submit.

**Full 2FA flow:** autofill → submit password → if TOTP: `openclaw_vault_totp` → fill code. If SMS: `openclaw_gv_sms` → extract code → fill code.

### Notes

- To re-sync after saving new passwords in Chrome: `vault import`
- To add a passphrase to the GPG key: `gpg --edit-key F0935E2BDC862F69` → `passwd`
- Scripts: `extract_chrome.py` (extraction), `vault` (CLI) in the vault directory
- When programmatically accessing credentials in scripts, use `vault show <query>` and parse output
- **Restart Claude Code** after modifying the MCP server to load new tools
