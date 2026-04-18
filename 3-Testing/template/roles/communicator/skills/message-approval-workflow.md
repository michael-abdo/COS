# Skill: Message Approval Workflow

**Goal:** Execute multi-step approval for high-impact messages (company announcements, executive communications, large recipient lists).

---

## Trigger

User requests approval workflow: "I need to send an announcement to all engineers. Let's make sure this is right" or similar.

---

## When to Use This Skill

Use multi-step approval if **ANY** of these apply:

| Condition | Question |
|-----------|----------|
| **Blast Radius** | Going to 10+ people? |
| **Reversibility** | Cannot be unsent or edited after sending? |
| **Stakes** | Will affect business, hiring, product, company direction? |
| **Novelty** | Is this a new pattern or message type? |
| **Legal** | Could this create liability or compliance issues? |

**Decision:** If ANY condition is true, use this workflow.

---

## Workflow: 4-Stage Approval

### Stage 1: Draft & Initial Preview

**Compose message:**
```
Recipient: All engineers (45 people)
Subject: Spring engineering roadmap update

Team,

We're shifting focus to [new direction]. Here's why [context]. Your first task: [action].

More details in [link].

Thanks,
[Name]
```

**Show initial preview:**
```
TO: All engineers (45 people)
SUBJECT: Spring engineering roadmap update

[FULL MESSAGE TEXT]

Blast Radius: 45 people
Reversibility: NO (email sent, archived)
Difficulty: MEDIUM (roadmap change)

Ready for stage 2? (yes / confirmed / send it)
```

**Wait for approval to continue.**

### Stage 2: Risk Assessment

**Show risk summary:**

```
RISK ASSESSMENT:

Blast Radius: 45 recipients
├─ Once sent, all see it immediately
└─ No unsend option

Reversibility: LOW
├─ Email is permanent in inboxes
└─ Archives keep it forever

Recipient Knowledge: MIXED
├─ Team may not know full context
└─ Recommend context in message or separate doc

Timing: Good
├─ Not urgent or crisis
└─ Allows normal processing

Recommendation: SAFE to send after final confirmation
```

**Ask user:**
```
Everything look OK? Any changes needed? (yes to proceed to stage 3, or ask to revise)
```

**If revisions needed:** Go back to Stage 1.

### Stage 3: Stakeholder Check (Optional)

**If message affects other teams, ask:**

```
This message affects:
- Engineering team (primary)
- Product team (secondary - mentioned new direction)
- Marketing (may need to know)

Should I notify product or marketing leads before sending?
(yes, no, or give me their emails)
```

**If yes:** Send preview to stakeholders, capture feedback, incorporate changes, return to Stage 1.

### Stage 4: Final Confirmation

**Show final preview with timestamp:**

```
FINAL CONFIRMATION

Message will be sent to: 45 engineers
Send time: 2026-04-18 14:30 UTC
Platform: Outlook

[FULL MESSAGE TEXT]

This action is irreversible. Should I send? (yes to confirm, no to cancel)
```

**Wait for final "yes".**

**If user hesitates:**
```
Take your time. Any last concerns?
- Wording issue? (I can revise)
- Recipient list wrong? (I can verify)
- Timing issue? (I can schedule for later)
- Still unsure? (Let's discuss)
```

### Stage 5: Send & Confirmation

```
Call: messages_send(
  to="[recipients]",
  subject="Spring engineering roadmap update",
  message="[body]",
  account="vvg",
  platform="outlook"
)
→ Returns pending_id
```

**Then:**
```
Call: confirm_send(
  pending_id=pending_id,
  zoom_confirmed=False  # Outlook
)
```

**Confirmation to user:**
```
Message sent!
Recipients: 45 engineers
Sent at: 2026-04-18 14:30 UTC
Tracking: [message_id]

Any follow-up actions?
- Send to another group?
- Schedule follow-up reminder?
- Create response mechanism (reply form, survey)?
```

---

## Example: Company Announcement

**User request:** "I need to announce we're consolidating to one office. This will affect everyone."

**Response (Stage 1):**
```
I'm drafting the announcement. Here's what I have:

TO: All Staff (127 people)
SUBJECT: Office consolidation announcement

Dear Team,

Effective June 1, we're consolidating to our San Francisco office. This is part of our commitment to in-person collaboration.

What this means for you:
- If remote: we'll discuss options
- If local: your office location changes (details below)
- If relocation: moving assistance available

Full details: [FAQ link]
HR will schedule 1-on-1s next week.

Thanks,
[Name]

---

Risk Assessment:
- Blast Radius: 127 people (HIGH)
- Reversibility: NO (public announcement)
- Impact: Affects everyone (HIGH)
- Novelty: Major change (HIGH)

Stage 2: Ready? (yes to proceed)
```

**User:** "yes"

**Stage 2 (Risk):**
```
RISK SUMMARY:

Blast Radius: CRITICAL (127 people)
├─ All employees receive immediately
├─ No unsend; archived permanently
└─ Public knowledge after send

Stakeholder Impact: VERY HIGH
├─ Affects employment (relocation, remote status)
├─ Legal implications (relocation assistance)
└─ HR must support messaging

Reversibility: IMPOSSIBLE
├─ Once sent, cannot recall
└─ Corrections must be separate email

Recommendation: ESCALATE to HR/leadership before final send

Should I:
a) Send to HR first for review (recommended)
b) Proceed to final confirmation
c) Revise message

Your choice?
```

**User:** "a) Send to HR first"

**Action:**
```
I'll send a preview to [hr_lead@company.com]:

Subject: [REVIEW NEEDED] Office consolidation announcement

[preview with "This is a draft pending your approval"]

After HR reviews, I'll await your signal to send to all staff.

Sending preview to HR now...
```

**Wait for HR feedback, incorporate changes, return to Stage 1 with revised message.**

---

## Escalation Patterns

| Condition | Escalate To | Action |
|-----------|------------|--------|
| Affects employment | HR | Get legal review |
| Affects product | Product leads | Get approval |
| Affects customers | Customer Success | Get customer impact assessment |
| Large audience (100+) | Manager/leadership | Get final approval |
| Time-sensitive | Specify deadline | Respect urgency but don't rush |
| First time (novel) | Ask user | Clarify intent and impact |

---

## Scheduled Messages (High-Impact)

**If user wants to schedule a message for later:**

```
You can schedule this to send automatically at a specific time.

When should I send?
- Immediately (now)
- Later today (give me time)
- Tomorrow at 9am
- Specific date/time: [date time]
```

**If later:**
```
I'll schedule the message to send at 2026-04-19 09:00 UTC.

It will remain in draft until then. You can cancel up until send time.

Ready to schedule? (yes to confirm)
```

---

## Post-Send Monitoring

**After message is sent, ask:**

```
Message sent! 

Next steps:
1. Monitor replies? (I can alert you to common themes)
2. Send follow-up reminder in 3 days? (I can schedule)
3. Log for audit trail? (automatically done)
4. Done?
```

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| Sending without multi-step approval for high-impact | Always use this workflow if blast radius >10 |
| Skipping risk assessment | Even "obvious" messages benefit from risk review |
| Not getting stakeholder input before send | Incorporate feedback before final send, not after |
| Sending during off-hours (timezone issues) | Schedule for business hours in primary timezone |
| Not providing follow-up mechanism | Include email, survey, or response channel |
| Burying the ask | Lead with context, make ask clear, put it early |

---

## FAQ

**Q: How long should Stage 2 (risk assessment) take?**
A: 2-5 minutes. It's not about overthinking; it's about catching obvious issues before irreversible send.

**Q: Can I skip stages if I'm confident?**
A: No. The workflow exists for blind spots. You might be confident and still miss something (legal issue, typo, tone problem). All stages, every time.

**Q: What if the user says "just send it" and wants to skip?**
A: Acknowledge the urgency, show the risk assessment anyway, ask: "Are you sure? Any concerns I should know?" Wait for re-confirmation. Never skip.

**Q: Can I combine Stages 1 and 2?**
A: No. Stage 1 is preview + initial approval. Stage 2 is risk analysis. Separate approvals prevent hasty sends.

**Q: What if I find an error after Stage 4 but before Stage 5 (send)?**
A: STOP. Show the error to the user. Ask: "Should I fix this and restart, or proceed as-is?" Never send with known errors without user acknowledgment.

**Q: How do I know when a message is "high-impact"?**
A: If you're asking "Is this high-impact?", it probably is. When in doubt, use the workflow.
