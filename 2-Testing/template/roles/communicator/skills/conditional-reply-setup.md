# Skill: Conditional Reply Setup

**Goal:** Send a message with built-in auto-reply rules triggered by recipient response classification.

---

## Trigger

User requests conditional replies: "Send this email and auto-reply if they say yes" or similar.

---

## How It Works

1. **Send initial message** to recipient
2. **System monitors** incoming replies (polling)
3. **Classify reply** using AI (matches conditions)
4. **Trigger action** automatically (reply, send email, notify)

**Timeline:** Monitoring continues for 72 hours (default) or until flow completes.

---

## Setup Workflow

### Step 1: Draft Initial Message

Compose message as normal. Example:

```
Hi Jane,

Can you review the proposal I sent? Your feedback would be really helpful.

Thanks,
[Name]
```

### Step 2: Define Conditions

Create JSON array with each reply pattern:

```json
[
  {
    "label": "positive",
    "description": "She agrees, provides feedback, or shows enthusiasm",
    "action": "reply",
    "response_content": "Thank you! I'll incorporate your feedback and send a revised version by Friday."
  },
  {
    "label": "needs_clarification",
    "description": "She asks questions or needs more context",
    "action": "reply",
    "response_content": "Good point. Let me explain [clarification]. Does that help?"
  },
  {
    "label": "declined",
    "description": "She declines, says no, or shows no interest",
    "action": "notify"
  },
  {
    "label": "unmatched",
    "description": "Anything else",
    "action": "notify"
  }
]
```

**Anatomy of a condition:**
- `label`: unique string ID (no spaces)
- `description`: what this condition means (used by AI classifier)
- `action`: what to do when matched
  - `"reply"`: auto-reply in-thread with response_content
  - `"send_email"`: send separate email (requires action_params)
  - `"notify"`: classify only, no auto-action
- `response_content`: text to reply with (if action is "reply")
- `action_params`: dict with email params (if action is "send_email")

### Step 3: Show Preview

Show BOTH message and conditions to user:

```
TO: jane@company.com
SUBJECT: Review of proposal

Hi Jane,

Can you review the proposal I sent? Your feedback would be really helpful.

Thanks,
[Name]

---

CONDITIONS:
1. "positive" (She agrees or gives feedback)
   → Auto-reply: "Thank you! I'll incorporate your feedback and send a revised version by Friday."

2. "needs_clarification" (She asks questions or needs more context)
   → Auto-reply: "Good point. Let me explain [clarification]. Does that help?"

3. "declined" (She declines or shows no interest)
   → Notify only (you'll see her reply)

4. "unmatched" (Anything else)
   → Notify only

Should I set this up? (yes / confirmed / send it)
```

**Wait for explicit signal.**

### Step 4: Send with Conditions

```
Call: conditional_reply_send(
  to="jane@company.com",
  message="Hi Jane...",
  subject="Review of proposal",
  conditions='[{"label": "positive", ...}, ...]',
  account="vvg",
  platform="outlook",
  expires_hours=72
)
```

Returns: `pending_id`

### Step 5: Final Confirm

```
Call: confirm_send(
  pending_id=pending_id,
  zoom_confirmed=False  # Outlook
)
```

### Step 6: Monitor

System monitors for replies. When a reply arrives:
1. **Classify:** AI matches reply against condition descriptions
2. **Execute:** Trigger action for matched condition
3. **Notify user:** Tell you what happened ("Jane replied: matched 'positive' → auto-reply sent")

---

## Examples by Use Case

### Example 1: Hiring Feedback Loop

**Message:** "Can you review Jane's background? Does she fit the role?"

**Conditions:**
```json
[
  {
    "label": "yes",
    "description": "Hiring manager approves Jane or shows strong interest",
    "action": "reply",
    "response_content": "Great! I'll send her next steps."
  },
  {
    "label": "no",
    "description": "Hiring manager declines or shows no interest",
    "action": "reply",
    "response_content": "Got it. I'll move on to other candidates."
  },
  {
    "label": "maybe",
    "description": "Hiring manager needs more info or is undecided",
    "action": "notify"
  }
]
```

### Example 2: Client Proposal Loop

**Message:** "Attached is our proposal for [project]. Any questions?"

**Conditions:**
```json
[
  {
    "label": "approved",
    "description": "Client approves, signs, or shows clear buy-in",
    "action": "send_email",
    "action_params": {
      "to": "billing@company.com",
      "subject": "New Project: [Name] — Schedule kickoff",
      "body": "Project approved. Schedule kickoff for next week."
    }
  },
  {
    "label": "revisions_needed",
    "description": "Client asks for changes or modifications",
    "action": "reply",
    "response_content": "Understood. I'll incorporate those changes and send a revised version by Thursday."
  },
  {
    "label": "declined",
    "description": "Client declines or passes",
    "action": "notify"
  }
]
```

### Example 3: Trading Alert Loop

**Message:** "Markets moving: BTC at 42K. Watch this level."

**Conditions:**
```json
[
  {
    "label": "action_taken",
    "description": "Trader reports taking a position or action",
    "action": "reply",
    "response_content": "Logged. Monitoring next support level at 41.5K."
  },
  {
    "label": "question",
    "description": "Trader asks follow-up question",
    "action": "notify"
  }
]
```

---

## Decision: Reply vs Notify vs Send Email

| Action | When to Use | Example |
|--------|------------|---------|
| **reply** | Quick, in-thread response needed | "Got it!" "Thanks for clarifying" |
| **notify** | You want to read the reply yourself | Questions, unclear responses |
| **send_email** | Trigger workflow outside the thread | Send invoice, escalate to manager |

**Rule:** Prefer `reply` for conversational responses, `notify` for anything you want to see, `send_email` for workflows.

---

## Safety Guardrails

**Conditions must be clear and non-overlapping:**
- ❌ "positive" = "good response" (too vague; AI might mismatch)
- ✅ "approved" = "Explicitly approves, says yes, or uses approval language" (clear)

**Auto-replies should be brief and not assume too much:**
- ❌ "response_content": "I'm thrilled to hear you agree! Let's get started immediately and I'll send contracts."
- ✅ "response_content": "Thank you! I'll send next steps."

**Monitor for classify errors:**
- If AI classifies replies incorrectly, add more specific condition descriptions
- Example: If "maybe" responses are being classified as "yes", add: "...does NOT contain 'let me think', 'need more info', or 'clarification'"

---

## Timeout & Expiration

**Default:** System monitors for 72 hours after message sent.

**If no reply within 72 hours:**
- Conditional reply expires
- User is notified
- No further auto-replies trigger

**To extend:**
- Add `expires_hours=144` (6 days) to conditional_reply_send() call
- Max safe timeout: 7 days

---

## Monitoring & Debugging

**User sees:**
```
Conditional reply ACTIVE
Message sent to: jane@company.com
Status: waiting for reply
Expires: 2026-04-21 (3 days)
Conditions: 4 patterns defined

[Status updates as replies arrive]
Reply detected: Jane at 2026-04-19 10:34am
Classified as: "positive"
Action triggered: Auto-reply sent
---
Your reply (auto): "Thank you! I'll incorporate your feedback and send a revised version by Friday."
```

---

## FAQ

**Q: Can I change conditions after sending?**
A: No. Once sent, conditions are locked. If you need different rules, cancel and restart with new conditions.

**Q: What if the reply contains multiple patterns?**
A: AI classifier picks the best match (highest confidence). If multiple conditions apply equally, "unmatched" is used and you're notified.

**Q: Can I reply to the auto-reply if I want to add context?**
A: Yes. Your reply will appear in the thread. User sees the full conversation: initial message → their reply → auto-reply → your additional context.

**Q: What if I want to NOT send an auto-reply but still monitor?**
A: Use `action: "notify"` with no response_content. System will monitor and tell you when a reply arrives, but won't auto-reply.

**Q: Can I use conditional replies on Zoom messages?**
A: Yes, but remember: initial Zoom message requires zoom_confirmed=True. Conditions work the same.

**Q: How many conditions can I define?**
A: Recommend 3-5. More than 5 reduces classifier accuracy. Each condition should be distinct.

**Q: What if I want to send different emails based on the reply?**
A: Use multiple `action: "send_email"` conditions with different action_params. Each condition can trigger a different email.
