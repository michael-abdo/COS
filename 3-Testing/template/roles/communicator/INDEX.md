# Communicator Role Plugin - Complete Index

**Location:** `/Users/Mike/2025-2030/Systems/COS/template/roles/communicator/`

**Version:** 1.0.0

**Description:** Conservative, verification-focused role for managing all outbound communication. Enforces Zoom safety, test isolation, and preview-approval workflows.

---

## Directory Structure

```
communicator/
├── plugin.json                          # Claude plugin manifest
├── ROLE.md                              # Personality & decision style
├── PROCEDURES.md                        # Execution rules & protocols
├── README.md                            # Quick start & overview
├── INDEX.md                             # This file
└── skills/                              # Communication tactics
    ├── cold-outreach.md
    ├── conditional-reply-setup.md
    ├── message-approval-workflow.md
    └── zoom-message-safety.md
```

---

## File Reference

### Core Files

| File | Purpose | Key Content |
|------|---------|------------|
| **plugin.json** | Plugin metadata | Manifest, entrypoint, capabilities, MCP dependencies |
| **ROLE.md** | Personality definition | Cautious profile, decision style, communication patterns, risk assessment |
| **PROCEDURES.md** | Execution rules | Zoom safety protocol, preview workflow, test isolation, error handling, audit trail |
| **README.md** | User guide | Quick start, safety rules, workflows, examples, troubleshooting |

### Skill Files (in `skills/`)

| Skill | Trigger | Flow |
|-------|---------|------|
| **cold-outreach.md** | "Send cold email to..." | Draft → Preview → Approval → Send |
| **conditional-reply-setup.md** | "Send & auto-reply if..." | Draft + conditions → Preview both → Approval → Send with monitoring |
| **message-approval-workflow.md** | "Announce to all engineers" | Multi-stage approval (draft, risk, stakeholder, final, send) |
| **zoom-message-safety.md** | "Send Zoom message to..." | Strict preview → Explicit signal → Confirm with flag |

---

## Critical Safety Rules (Enforced)

1. **Zoom Messages:** Explicit user confirmation required ("yes", "confirmed", "send it")
2. **Zoom Flag:** `zoom_confirmed=True` MUST be passed to confirm_send()
3. **Test Routing:** All test messages MUST route to `michaelabdo@vvgtruck.com`
4. **Preview-First:** Full message shown before approval request (no truncation)
5. **No Shortcuts:** Urgency, context, or "just this once" never override rules

---

## Usage Examples

### Load the Role

```bash
.communicate  # Activates communicator role
```

### Request Actions

```
User: "Send a cold email to jane@acme.com about hiring"
→ Uses: cold-outreach.md

User: "Send Zoom announcement about layoffs to all staff"
→ Uses: message-approval-workflow.md

User: "Reply to John's proposal with auto-approval if he says yes"
→ Uses: conditional-reply-setup.md

User: "Send Zoom message to #trading-alerts about volatility"
→ Uses: zoom-message-safety.md
```

---

## Key Procedures (PROCEDURES.md)

### Zoom Safety Protocol
- Rule 1: Explicit confirmation (show preview, wait for "yes")
- Rule 2: zoom_confirmed=True flag (mandatory for Zoom)
- Rule 3: Test email routing (michaelabdo@vvgtruck.com only)

### Message Preview Workflow
- Standard format: TO → SUBJECT → MESSAGE body
- Full text, no truncation
- Attachments listed by filename

### Conditional Reply Setup
- Message + condition definitions
- JSON array with label, description, action
- System monitors for replies, classifies, executes

### Cold Outreach Workflow
- 5-step flow: Gather → Draft → Preview → Approve → Send
- Risk assessment for new contacts
- Follow-up planning

### Risk Escalation
- Blast radius, reversibility, recipient trust, novelty, time pressure
- Multi-stage confirmation for high-impact messages

---

## MCP Tools Required

The plugin uses these Universal Communication MCP tools:

- `messages_send()` — Draft and send message
- `confirm_send()` — Dispatch with approval flags
- `send_reply()` — Reply to existing message
- `messages_send_scheduled()` — Schedule for future
- `conditional_reply_send()` — Send with reply conditions
- `conditional_reply_to()` — Reply with conditions
- `messages_list()` — Retrieve for context
- `create_email_draft()` — Draft without sending

All require explicit user approval via confirm_send().

---

## Configuration

### Required Environment Variables

- `OUTLOOK_REPLY_ID` (optional) — Default email to reply to
- `ZOOM_CHAT_REPLY_ID` (optional) — Default Zoom chat to reply to
- `PROJECT_ID` (optional) — Default project context

### MCP Servers

```bash
# Universal Communication Layer (required)
claude mcp add-json universal \
  '{"command":"...","args":[...],"env":{"DATABASE_URL":"..."}}'

# PostgreSQL (for audit logs, optional but recommended)
claude mcp add-json postgres \
  '{"command":"...","args":[...]}'
```

---

## AEO Compliance

All documents follow Answer Engine Optimization (AEO) standards:

✓ **ROLE.md**
- H1 title (question format)
- Quick Answer (2-4 sentences)
- H2 summaries (40-60 words each)
- 3+ domain examples (hiring, trading, systems, consulting)
- Tables over prose
- Literal language (no metaphor)

✓ **PROCEDURES.md**
- Imperative voice (decision gates)
- Scannable structure
- Decision trees and checklists
- FAQ section
- Error handling flows

✓ **Skills** (Trigger → Workflow → Examples → Risks → FAQ)
- Goal-first format
- Step-by-step workflows
- Concrete examples
- Risk mitigations
- FAQ for common questions

---

## Common Tasks

### Sending a Cold Email
See: `skills/cold-outreach.md`
Time: ~2 minutes (draft + approval + send)

### Sending Zoom Message
See: `skills/zoom-message-safety.md`
Time: ~1 minute (draft + explicit approval + flag)

### Company Announcement
See: `skills/message-approval-workflow.md`
Time: ~5-10 minutes (multi-stage approval)

### Reply with Auto-Responses
See: `skills/conditional-reply-setup.md`
Time: ~3 minutes (draft + conditions + approval)

---

## Troubleshooting

### "zoom_confirmed flag missing"
→ Use: PROCEDURES.md → Rule 2
→ Fix: Always pass `zoom_confirmed=True` for Zoom

### "Test sent to wrong recipient"
→ Use: PROCEDURES.md → Rule 3
→ Fix: Route all tests to `michaelabdo@vvgtruck.com`

### "User said 'okay' but not approved"
→ Use: PROCEDURES.md → Message Preview Workflow
→ Fix: Ask explicitly: "yes / confirmed / send it?"

### "Message needs revision after approval"
→ Use: PROCEDURES.md → Error Handling
→ Fix: Show revised version, capture new approval

---

## Extension Points

### Adding New Skill

1. Create `skills/pattern-name.md`
2. Follow template: Trigger → Workflow → Examples → Risks → FAQ
3. Reference in README.md decision tree
4. Update this INDEX.md

### Adding New Rule

1. Document in PROCEDURES.md
2. Add decision gate or constraint
3. Add FAQ entry explaining why
4. Update safety rules summary (above)

### Adding Domain Example

1. Add to ROLE.md H2 sections (3+ domains required)
2. Hiring, trading, systems, consulting are standard
3. Verify word count (40-60 per summary)
4. Test comprehension across domains

---

## Audit & Compliance

Every send operation logs:

| Field | Example | Purpose |
|-------|---------|---------|
| Message ID | ps_a1b2c3 | Tracking |
| Recipient | jane@acme.com | Proof of correct recipient |
| Platform | zoom / outlook | Safety routing |
| Approval Signal | "yes, send it" | Proof of consent |
| Send Time | 2026-04-18T14:30:00Z | Timeline |
| Status | sent / failed | Outcome |
| zoom_confirmed | true / false | Safety flag state |

Used for: disputes, compliance, security audits.

---

## Version History

**v1.0.0** (2026-04-18)
- Initial release
- Core: ROLE.md, PROCEDURES.md, README.md, plugin.json
- 4 skills: cold-outreach, conditional-reply, message-approval, zoom-safety
- Zoom safety protocol extracted from OLD CLAUDE.md
- AEO-compliant formatting
- Complete FAQ & examples

---

## License

**Communicator Role Plugin**
- Part of COS (Consulting Operations System)
- Conservative by design, not by accident
- All safety rules are non-negotiable
