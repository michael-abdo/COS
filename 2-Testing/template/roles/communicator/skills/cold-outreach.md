# Skill: Cold Outreach

**Goal:** Draft and send an initial contact message to a prospect, respecting preview-approval workflow.

---

## Trigger

User requests cold outreach: "Send a cold email to jane@acme.com about hiring" or similar.

---

## Workflow

### Step 1: Gather Information

Ask user (if not provided):
- **Recipient name:** Jane Doe (if unknown, fetch from email or LinkedIn)
- **Recipient email:** jane@acme.com
- **Reason for contact:** Why this person? What do they care about?
- **Your ask:** What do you want them to do? (1 specific ask only)

### Step 2: Draft Message

Compose using this structure:
```
Subject: [Specific hook: mention something about them or your work]

Hi [Name],

[Context: Why you're reaching out]

[Value: What's in it for them? What problem do you solve?]

[Ask: One specific request—call, meeting, intro, feedback]

Best,
[Your name]
```

**Constraints:**
- Length: 40-150 words (3-5 sentences)
- Tone: Warm, not salesy
- Hook: Personal reference or relevant detail (shows you researched)
- Ask: Specific (not "let's talk about everything")

### Step 3: Show Preview

```
TO: [recipient_name] <[recipient_email]>
SUBJECT: [subject]

[FULL MESSAGE TEXT]

Should I send this? (yes / confirmed / send it)
```

**Wait for explicit signal.**

### Step 4: Validate Before Send

Check:
- [ ] Recipient email is correct (typo check)
- [ ] Subject line is clear and benefit-focused
- [ ] Ask is specific (not vague)
- [ ] No generic template language ("I was looking at your profile")
- [ ] Tone matches user's voice

### Step 5: Send

```
Call: messages_send(
  to="recipient_email",
  subject="subject",
  message="body",
  account="vvg",
  platform="outlook"  # default for cold outreach
)
```

### Step 6: Confirm

```
Call: confirm_send(
  pending_id=pending_id,
  zoom_confirmed=False  # outlook does not require flag
)
```

### Step 7: Follow-up Plan

Ask user:
- "When should I follow up if they don't reply?" (default: 1 week)
- "Should I set a reminder?" (send_scheduled)
- "Any conditional replies?" (if yes, use conditional_reply_send pattern)

---

## Example

**User request:** "Send a cold email to john@startup.io. He's a CTO, and we're hiring for infrastructure."

**Response:**

```
I'll draft a cold email to John. Here's what I have:

TO: John (john@startup.io)
SUBJECT: Hiring great infrastructure engineers

Hi John,

I noticed your work on distributed tracing at [previous company]. We're building similar infrastructure and need someone like you.

Would you be open to a quick conversation about what we're doing?

Best,
[Your name]

Should I send this? (yes / confirmed / send it)
```

**User:** "yes, send it"

**Action:** Send with confirm_send(zoom_confirmed=False).

**Follow-up:** "Sent! I'll set a reminder to follow up in 1 week if John doesn't reply. Want me to draft the follow-up now?"

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Wrong email address | Verify before preview; ask user to confirm |
| Too salesy tone | Review draft; rephrase as conversation, not pitch |
| Unclear ask | Ensure ask is specific (meeting, call, intro) not vague |
| No research shown | Include 1-2 details showing you know their work |
| Follow-up fatigue | Limit to 2-3 touchpoints; space by 1 week |

---

## FAQ

**Q: Should I use a template?**
A: No. Each outreach is unique. Templates are spotted and ignored. Use context specific to the person.

**Q: How many people should I send to at once?**
A: One at a time. Each requires individual approval. Batches bypass human review (dangerous).

**Q: What if they don't reply?**
A: Wait 1 week, then send ONE follow-up. After 2 weeks of silence, stop. They're not interested.

**Q: Can I mention our company name if we're stealth?**
A: Ask user. If yes, keep company reference vague ("we're a startup building X"). If no, say "I work with a team building X".

**Q: Should I include my LinkedIn?**
A: Only if user requests it. Most cold outreach works better with minimal links (reduces noise).
