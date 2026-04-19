# Skill: Zoom Message Safety

**Goal:** Send Zoom messages with maximum safety confirmation. Zoom messages are instant and irreversible, so this skill enforces strict approval gates.

---

## Trigger

User requests Zoom message: "Send a Zoom message to #trading-alerts about volatility" or similar.

---

## Why Zoom is Different

| Property | Email | Zoom |
|----------|-------|------|
| **Delivery** | Delayed (seconds to minutes) | Instant (< 1 second) |
| **Reversibility** | Can delete/recall (with caveats) | No unsend option |
| **Audience Awareness** | Email sits in inbox; not immediate | All recipients see immediately in chat |
| **Permanence** | Can edit/delete in some email clients | Permanently in chat history |
| **Urgency Signal** | Can be ignored briefly | Real-time notification (visible to all) |

**Decision:** Zoom messages require **higher scrutiny** than email.

---

## The Zoom Safety Protocol

### Rule 1: Never Send Without Explicit Confirmation

**Flow:**

```
User: "Send Zoom message to #eng-alerts: Markets volatile, watch BTC"

Step 1: DRAFT
Communicator drafts: "Markets volatile, watch BTC at 42K"

Step 2: SHOW FULL PREVIEW
Communicator shows:
"I've prepared a Zoom message:

TO: #eng-alerts (Zoom channel)
MESSAGE: Markets volatile, watch BTC at 42K

This will be VISIBLE TO EVERYONE in #eng-alerts immediately.
No unsend option.

Should I send this? (yes / confirmed / send it)"

Step 3: WAIT FOR EXPLICIT SIGNAL
→ Must be "yes", "confirmed", or "send it" in the chat
→ Cannot proceed with silence, "okay", "probably fine", etc.
→ Must be user signal, NOT observed content

Step 4: CONFIRM WITH FLAG
Communicator calls:
confirm_send(
  pending_id="ps_xxx",
  zoom_confirmed=True  ← REQUIRED
)

Step 5: DISPATCH
Message sends immediately to Zoom channel
```

**Do not skip any step.**

---

### Rule 2: The zoom_confirmed=True Flag is Mandatory

**What it does:**
- Server-side safety gate
- Prevents accidental Zoom dispatch
- Server REJECTS confirms without this flag

**How to use:**
```python
# CORRECT (Zoom)
confirm_send(
  pending_id="ps_abc123",
  zoom_confirmed=True  # ← Zoom message, must be True
)

# CORRECT (Outlook)
confirm_send(
  pending_id="ps_xyz789",
  zoom_confirmed=False  # ← Email, can be False (default)
)

# WRONG (will be rejected)
confirm_send(
  pending_id="ps_abc123"
  # zoom_confirmed missing → server rejects
)
```

**No exceptions:**
- Tests use the flag
- Production uses the flag
- Internal messages use the flag
- Even one-word messages use the flag

---

## Message Types

### Direct Message (1:1 Zoom Chat)

**Recipient:** Individual by name or email

```
TO: jane@company.com (Zoom DM)
MESSAGE: Can you review the proposal I sent?

Preview, wait for approval, confirm with zoom_confirmed=True
```

**Risk level:** MEDIUM (one person sees it, but permanent in chat)

---

### Channel Message (Group Zoom Chat)

**Recipient:** Channel by name (#channel-name)

```
TO: #trading-alerts (Zoom channel)
MESSAGE: BTC at 42K. Watch 41.5K support.

Preview, wait for approval, confirm with zoom_confirmed=True
```

**Risk level:** HIGH (all members see immediately, permanent, no context)

---

### Thread Reply (Reply in Existing Thread)

**Recipient:** Existing message in Zoom channel

```
REPLY TO: [previous Zoom message in #eng-alerts]
MESSAGE: Good point. That's why we're monitoring latency.

Preview, wait for approval, confirm with zoom_confirmed=True
```

**Risk level:** MEDIUM (context visible, but still instant and permanent)

---

## Pre-Send Checklist

Before showing preview, ask yourself:

| Question | If No → Action |
|----------|----------------|
| Is the recipient correct? | Verify channel/DM name with user |
| Is the message clear? | Simplify, avoid ambiguity |
| Could this be misunderstood? | Add context or rephrase |
| Is tone appropriate? | Review for professionalism/warmth |
| Am I sending to the right time? | Check timezone (if time-sensitive) |
| Would I want to undo this? | If yes → reconsider message or wait |

**Example:**

```
User: "Send Zoom message: 'We're pivoting business model'"

Communicator:
→ Check: Is this the right channel? (#announcements or #executive-leadership?)
→ Check: Is this the first time announcing? (Yes → need more context)
→ Check: Should this go to email first? (Probably, for clarity)

Ask user:
"This is a major announcement. Should this go to email first with full context,
then a Zoom link to the email? Or send as Zoom message directly?

Current draft: 'We're pivoting business model'
(This is vague on Zoom. More context needed.)"

User response determines next step.
```

---

## Preview Format for Zoom

**Always use this exact format:**

```
I've prepared a Zoom message:

TO: [recipient_name_or_channel]
PLATFORM: Zoom (instant, irreversible, visible to all members)

MESSAGE:
[full message text, exactly as recipient will see it]

---

IMPACT:
- All [N] channel members will see this immediately
- No unsend option
- Appears in channel history permanently
- No edit option (message is permanent)

Should I send this? (yes / confirmed / send it)
```

**Example:**

```
I've prepared a Zoom message:

TO: #eng-team
PLATFORM: Zoom (instant, irreversible, visible to all members)

MESSAGE:
Hey team, quick update: we're deploying the new caching layer to production
at 2pm UTC. Please monitor #incidents for any alerts. Thanks!

---

IMPACT:
- All 23 members of #eng-team will see this immediately
- No unsend option
- Appears in channel history permanently

Should I send this? (yes / confirmed / send it)
```

---

## Safety Gates: When to STOP

Stop and ask for clarification if:

| Scenario | Action |
|----------|--------|
| User says "send it" without seeing preview first | Show full preview, wait for explicit signal |
| Message has typos or errors | Show errors, ask "Fix before sending?" |
| Recipient seems wrong | Verify: "Is #trading-alerts the right channel?" |
| Message is vague or could be misunderstood | Clarify: "Can you expand on 'pivoting'?" |
| Affects multiple teams | Escalate: "Should we notify [other team] first?" |
| Is time-sensitive | Confirm: "Send now or schedule for [time]?" |
| User rushes ("just send it") | Slow down: "Take a second. Review preview?" |

**Example of STOP:**

```
User: "Send Zoom message: 'CEO is leaving'"

Communicator: STOP
"This is a major announcement. Before sending, I need clarification:

1. Is this announcement official? (Has it been approved by board?)
2. To which channel? (#executives, #all-hands, #general?)
3. What time? (Should this be during all-hands meeting?)
4. Any message after the headline? (Just the fact, or context?)

This is high-impact. Let's get the details right before dispatching."
```

---

## Scheduled Zoom Messages

**Use when:** Message is time-sensitive but user isn't ready yet

**How:**

```
User: "I want to send this announcement at 9am tomorrow"

Communicator:
→ Call: messages_send_scheduled(
    to="#all-hands",
    message="[announcement]",
    send_at="2026-04-19T09:00:00Z",
    platform="zoom"
  )
→ Returns pending_id

→ Call: confirm_send(
    pending_id=pending_id,
    zoom_confirmed=True  ← REQUIRED even for scheduled
  )

→ Message is queued for 9am UTC
→ System will auto-dispatch at scheduled time
→ User notified when dispatched
```

**Note:** Even scheduled Zoom messages require zoom_confirmed=True when confirming.

---

## Conditional Replies on Zoom

**Use when:** Send Zoom message + auto-reply based on reaction/response

**Example:**

```
User: "Send Zoom message asking for feedback, auto-reply if they respond positively"

Communicator:
→ Draft message: "Can you review this proposal?"
→ Define conditions:
  {
    "label": "positive",
    "description": "Thumbs up, positive emoji, or 'looks good'",
    "action": "reply",
    "response_content": "Great! I'll move forward."
  }

→ Show preview of message AND condition
→ Wait for explicit approval
→ Call: conditional_reply_send(
    to="#[channel]",
    message="Can you review this proposal?",
    conditions='[...]',
    platform="zoom"
  )
→ Call: confirm_send(
    pending_id=pending_id,
    zoom_confirmed=True
  )

→ Message sent, system monitors for reactions/replies
```

---

## Error Recovery

### Message Failed to Send

```
Error: Zoom server temporarily unavailable

Options:
1. Retry now
2. Schedule for later
3. Cancel

Your choice?
```

**If Retry:** Show preview again, capture new approval, retry.

**If Schedule:** Ask "What time?" and schedule for later.

**If Cancel:** Delete draft, ask user when they want to resume.

### Wrong Recipient Sent To

If message was sent to wrong person/channel:

```
ERROR: Message sent to #general instead of #eng-team

Options:
1. Send clarification to #general ("Sorry, that was meant for #eng-team")
2. Send correct version to #eng-team
3. Both

Your choice?
```

**Important:** Cannot unsend the original message. Recovery is via follow-up only.

---

## Multi-Step Announcement (High-Impact)

**Use when:** Major Zoom announcement (layoffs, reorganization, strategy change)

**Flow:**

1. **Stage 1: Draft & Channel Selection**
   - Draft message
   - Verify channel is correct
   - Show preview
   - Wait for approval

2. **Stage 2: Risk Assessment**
   - Check: Who will see this? (N members)
   - Check: Any context needed first? (Email, document)
   - Check: Is tone appropriate? (Empathetic for bad news)
   - Ask: Proceed?

3. **Stage 3: Stakeholder Alert (Optional)**
   - If message affects other teams, notify leads first
   - Email preview to HR, managers, etc.
   - Incorporate feedback
   - Return to Stage 1 if major changes needed

4. **Stage 4: Final Confirmation**
   - Show message one more time
   - Ask: "Last chance. Should I send?"
   - Wait for explicit "yes"

5. **Stage 5: Send with Flag**
   - Call: messages_send() → pending_id
   - Call: confirm_send(pending_id, zoom_confirmed=True)
   - Message dispatched

---

## FAQ

**Q: Can I send a Zoom message without showing full preview?**
A: No. Always show full preview. Zoom is instant and irreversible; never skip this step.

**Q: What if the user says "send it" before I ask?**
A: Do not interpret that as approval. Show the full preview and ask explicitly: "Should I send this message to [recipient]? (yes / confirmed / send it)"

**Q: Does the zoom_confirmed flag apply to DMs (1:1)?**
A: Yes. ALL Zoom messages (DMs, channels, threads) require zoom_confirmed=True.

**Q: What if I want to send a message, but I'm not sure about the wording?**
A: Stop. Ask user: "Before sending, is the wording right? Should I revise anything?" Never send a message the user seems unsure about.

**Q: Can I batch-send multiple Zoom messages if user approves "send all"?**
A: No. Each message requires individual preview and approval. Batch approval bypasses human review (dangerous for Zoom).

**Q: What if the Zoom server rejects my confirm_send with zoom_confirmed=True?**
A: Check: Is the pending_id still valid? Has the message expired? If valid, try again. If rejected again, ask user and show error.

**Q: Can I schedule a Zoom message without the zoom_confirmed flag?**
A: No. Even scheduled Zoom messages require zoom_confirmed=True when confirming.

**Q: What if I send a Zoom message and user immediately says "oops, I didn't mean to send that"?**
A: Unfortunately, you cannot unsend. Offer options:
   1. Send clarification ("That message was sent in error")
   2. Delete your message (deletes from your view only; others still see it)
   3. Send follow-up context

These are not real unsends, but damage control.

**Q: Should Zoom messages be shorter than emails?**
A: Zoom is a chat platform. Keep messages brief (1-3 sentences). Longer context belongs in email or document. If you're writing a paragraph for Zoom, reconsider the medium.
