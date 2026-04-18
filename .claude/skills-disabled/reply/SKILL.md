---
name: reply
description: Draft and send a reply to a thread — Outlook email, Zoom DM, or Zoom channel. Reads reply config from the projects database, not local .env.
disable-model-invocation: true
user-invocable: true
---

# Reply to Active Thread

Draft and send a reply to the current project's active thread. Supports **Outlook email**, **Zoom DM**, or **Zoom channel**. Reply targets are stored in the **projects database**, not `.env`.

## Step 1: Determine the platform and target

1. Call `project_get` (reads `PROJECT_ID` from `.env`, or pass explicitly)
2. From the project record, check these fields in order:
   - `default_outlook_thread` → **Outlook** reply (conversation ID)
   - `default_zoom_channel` → **Zoom channel** reply (channel ID)
3. If the user specifies a contact name directly (e.g., `/reply to Rudy`), use **Zoom DM** to that contact
4. If no reply target is configured and none specified, ask the user: "Who should I reply to? (contact name for Zoom DM, or set a default via `project_update`)"

**Resolving the account:** Use the project's `account_id` field (e.g., `vvg`) for all MCP calls.

## Step 2: Read the thread

**Outlook:**
1. Search for the thread using `messages_search` with the sender's email and `platform: outlook` and `account` from the project to get the full `platform_message_id`
2. Read the most recent message to understand conversation context

**Zoom DM:**
1. Use `messages_list` with `sender_email` set to the DM target and `platform: zoom` and `account` from the project
2. Read recent messages to understand conversation context

**Zoom Channel:**
1. Use `messages_list` with `channel_id` set to the channel ID from `default_zoom_channel` and `platform: zoom` and `account` from the project
2. Read recent messages to understand conversation context

## Step 3: Gather recent changes

1. Review what was done since the last message in the thread
2. Use `git log` to see commits since the thread date
3. Identify the top 3 most impactful user-facing changes
4. Frame changes from the recipient's perspective (what they'll see/experience), not implementation details

## Step 4: Draft the reply

**Hard rules:**
- **5 sentences max** — concise and scannable
- **Lead with gratitude/acknowledgment** of their last message
- **Top 3 changes** — described in plain language, one sentence each
- **End with a call to action** — use `$ARGUMENTS` if provided, otherwise default to inviting them to test or meet
- **No jargon** — "better GL matching" not "refactored findByLawFirmAndMatter scoring algorithm"
- **Include the live URL** (`domain` from project record) if applicable so they can click through immediately

## Step 5: Send as reply

**Outlook:**
1. Use `send_reply` with:
   - `email_id`: the `platform_message_id` from Step 2
   - `reply_all: true` (keep all participants in the loop)
   - `account`: from project record
2. Show the full preview to the user
3. **Wait for explicit confirmation** before calling `confirm_send`

**Zoom DM:**
1. Use `messages_send` with:
   - `to`: the contact name or email
   - `platform: zoom`
   - `account`: from project record
2. Show the full preview to the user
3. **Wait for explicit "yes" confirmation** — Zoom sends are instant and irreversible
4. Call `confirm_send` with `zoom_confirmed: true`

**Zoom Channel:**
1. Use `messages_send` with:
   - `to`: the channel ID from `default_zoom_channel`
   - `is_channel: true`
   - `platform: zoom`
   - `account`: from project record
2. Show the full preview to the user
3. **Wait for explicit "yes" confirmation** — Zoom sends are instant and irreversible
4. Call `confirm_send` with `zoom_confirmed: true`

## Notes

- **Project config is the source of truth** — reply targets live in the projects DB (`default_outlook_thread`, `default_zoom_channel`), not in `.env`. Use `project_update` to change them.
- **Outlook:** `default_outlook_thread` is the Outlook conversation ID. The `platform_message_id` from search is the actual message ID needed for `send_reply`.
- **Zoom DM:** Contact names are auto-resolved to emails by the MCP. The Zoom user ID resolution (for .com.mx emails etc.) is handled automatically by the adapter.
- **Zoom Channel:** The `default_zoom_channel` stores the channel ID directly. Use `channels_list` with `platform: zoom` to find channel IDs if reconfiguring.
- `$ARGUMENTS` can override the closing line (e.g., `/reply please send more test docs`) or specify a DM target (e.g., `/reply to Rudy about the credit app update`).
- If the user requests changes, cancel and redraft — do not send without approval.
