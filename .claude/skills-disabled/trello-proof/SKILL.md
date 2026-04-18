---
name: trello-proof
description: Navigate to a production URL in Chrome, screenshot it, and upload as proof-of-completion to a Trello card
user-invocable: false
---

# Trello Proof of Completion

Navigate to a production deployment in Chrome, take a screenshot as proof, and upload it to a Trello card with a comment.

## Arguments

`$ARGUMENTS` should contain:
- The production URL to screenshot (e.g., "https://employee-recognition.vtc.systems/core/pipeline")
- The Trello card name, search term, or URL (e.g., "employee recognition", "https://trello.com/c/83xOMBIl")

If arguments are missing or ambiguous, ask the user for:
1. What URL to navigate to for the screenshot
2. Which Trello card to attach it to

## Workflow

### Step 1: Navigate and screenshot in Chrome

Use Chrome MCP tools to capture the production deployment:

1. **Load Chrome tools** — use ToolSearch to load `mcp__claude-in-chrome__tabs_context_mcp`, `mcp__claude-in-chrome__tabs_create_mcp`, `mcp__claude-in-chrome__navigate`, and `mcp__claude-in-chrome__computer`
2. **Get tab context** — call `tabs_context_mcp` to see existing tabs
3. **Create a new tab** — call `tabs_create_mcp` to open a fresh tab
4. **Navigate** to the production URL the user specified
5. **Wait** for the page to fully load (use `computer` with `action: wait`, 2-3 seconds)
6. **Take screenshot** — use `computer` with `action: screenshot` to capture the page
7. **Save to disk** — capture the Chrome window to a file:

```bash
screencapture -l $(osascript -e 'tell app "Google Chrome" to id of window 1') /tmp/trello-proof-$(date +%Y%m%d-%H%M%S).png
```

If that doesn't capture the right window, fall back to:
```bash
screencapture -x /tmp/trello-proof-$(date +%Y%m%d-%H%M%S).png
```

8. **Show the screenshot** to the user using the Read tool so they can verify it looks correct.

### Step 2: Find the target Trello card

If `$ARGUMENTS` contains a Trello URL or short link (e.g., `trello.com/c/...`), extract the card ID directly.

Otherwise, use the Universal Communication MCP's Trello tools. Load the tool with ToolSearch first:

```
ToolSearch: "select:mcp__universal__trello_search"
```

Then call `trello_search` with the card name to find matching cards.

Present matching cards in a table and ask the user to confirm which card.

### Step 3: Confirm with the user

Before uploading, show a summary and **ask for explicit confirmation**:

```
Screenshot: [filename] ([size])
Source: [production URL that was screenshotted]
Card: [card name]
Board: [board name]
Comment: "Proof of completion — [timestamp]"

Upload this proof? (yes/no)
```

**Do NOT proceed without explicit "yes" from the user.**

### Step 4: Upload proof via MCP

Load and call the `trello_proof` MCP tool:

```
ToolSearch: "select:mcp__universal__trello_proof"
```

Then call `trello_proof` with:
- `card_id`: The confirmed card ID
- `file_path`: Path to the screenshot
- `source_url`: The production URL that was screenshotted

This uploads the attachment and posts the comment in one call.

### Step 5: Report results

| Field | Value |
|-------|-------|
| Source | [production URL] |
| Card | [card name + URL] |
| Attachment | [filename] |
| Comment | Posted |
| Status | Done |
