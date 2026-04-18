---
name: chase-transfer
description: Transfer money between Chase checking accounts (VVG Income, Personal Brand, Day Trading) using the OpenClaw MCP browser tools. Use when the user asks to transfer money between their Chase checking accounts, move funds from one account to another, or fund a sub-account. The existing openclaw_chase_transfer CDP tool is unreliable (picks wrong browser tab); this skill uses the manual MCP browser flow that works every time. Always confirm source, destination, and amount with the user before executing — real money moves.
user-invocable: true
---

# Chase Transfer — Manual MCP Flow

Transfer money between Chase checking accounts by driving the browser directly with OpenClaw MCP tools. The `openclaw_chase_transfer` Tampermonkey/CDP tool is unreliable because it connects to whichever tab CDP picks first, which is often not the Chase tab. This skill uses the **browser_type + refs** approach which is proven to work.

## When to use

- User says "transfer from [account] to [account]", "move $X from VVG Income to Personal Brand/Day Trading", "fund my trading account"
- Any movement of money between VVG Income, Personal Brand, and Day Trading

## Before calling

**Always confirm with the user:**
1. **Source account** — only VVG Income (...0312) is a valid source in this flow (it's the pre-selected source on the transfer page)
2. **Destination** — Day Trading (...9742) or Personal Brand (...3655)
3. **Amount**

**Do not default anything.** If the user says "transfer $100 to trading", confirm "from VVG Income?" before proceeding.

## Known account labels (exact strings from the dashboard)

| Account | Last 4 | Role |
|---------|--------|------|
| VVG Income | 0312 | Source (only) |
| Personal Brand | 3655 | Destination |
| Day Trading | 9742 | Destination |
| Expenses CC | 8417 | CC — use chase-pay skill instead |

## Step-by-step flow

### 1. Check browser state — are we logged into Chase?

```
openclaw_browser_screenshot(profile="zenex")
```

If the screenshot shows the Chase login page → go to step 2 (login first).
If it shows the Chase dashboard → skip to step 3.
If it shows something else → navigate to `https://secure.chase.com/web/auth/dashboard#/dashboard/overview` first and screenshot again.

### 2. Login (only if not already logged in)

Navigate to the **iframe-bypass login URL** (critical — regular Chase URL puts the form inside an iframe and refs won't work):

```
openclaw_browser_navigate(url="https://secure.chase.com/web/auth/?fromOrigin=https://secure.chase.com", profile="zenex")
```

Wait 3 seconds, then snapshot to get refs:

```
openclaw_browser_snapshot(profile="zenex")
```

Expected refs on the login page:
- `e2` — Username textbox
- `e3` — Password textbox
- `e7` — Sign in button

Get credentials from the vault:

```
openclaw_vault_get(query="chase.com")
```

Then click + type each field (click first so the focus is set, then type — important for React):

```
openclaw_browser_click(ref="e2", profile="zenex")
openclaw_browser_type(ref="e2", text="<username>", profile="zenex")
openclaw_browser_click(ref="e3", profile="zenex")
openclaw_browser_type(ref="e3", text="<password>", profile="zenex")
openclaw_browser_click(ref="e7", profile="zenex")
```

Wait 10 seconds for the dashboard to load.

### 3. Click "Transfer money" on VVG Income

From the dashboard, snapshot to get refs:

```
openclaw_browser_snapshot(profile="zenex")
```

The dashboard has three "Transfer money" buttons (one per checking account), in this order:
- `e22` — Transfer money (VVG Income) — **use this one**
- `e26` — Transfer money (Personal Brand)
- `e30` — Transfer money (Day Trading)

Click the VVG Income one:

```
openclaw_browser_click(ref="e22", profile="zenex")
```

Wait 4 seconds for the transfer page to load.

### 4. Fill the transfer form

The transfer page URL will be `.../cashTransfersArea/transferMoney.../initiateTransfer`. "Transfer from" is **pre-filled with VVG Income** — do not touch it.

Snapshot to get form refs:

```
openclaw_browser_snapshot(profile="zenex")
```

Expected refs on the transfer form (initial state, before dropdown opens):
- `e20` — "Transfer to, Choose an account" button (the dropdown trigger)
- `e22` — Amount textbox
- `e28` — Next button

**Click the "Transfer to" dropdown (e20)** to expand it:

```
openclaw_browser_click(ref="e20", profile="zenex")
```

Snapshot again — the dropdown is now expanded and adds listbox options:

```
openclaw_browser_snapshot(profile="zenex")
```

Expected new refs in the expanded state:
- `e22` — option "Day Trading (...9742), $X,XXX.XX"
- `e23` — option "Personal Brand (...3655), $XX.XX"
- `e25` — Amount textbox (renumbered because of new elements)
- `e31` — Next button (renumbered)

**IMPORTANT:** Always re-read the snapshot after clicking the dropdown because opening it renumbers all refs below it.

Click the destination option:
- Day Trading → click the "Day Trading" option
- Personal Brand → click the "Personal Brand" option

```
openclaw_browser_click(ref="<dest_ref>", profile="zenex")
```

Click the Amount field then type:

```
openclaw_browser_click(ref="<amount_ref>", profile="zenex")
openclaw_browser_type(ref="<amount_ref>", text="<amount>", profile="zenex")
```

Click Next:

```
openclaw_browser_click(ref="<next_ref>", profile="zenex")
```

Wait 3 seconds.

### 5. Confirm on the verify page

URL will be `.../verifySingleTransfer`. Screenshot to verify the details match:

```
openclaw_browser_screenshot(profile="zenex")
```

Visually confirm:
- Transfer from: VVG Income (...0312)
- Transfer to: <destination>
- Amount: $<amount>
- Date: today

If anything is wrong, click "Back" or "Cancel" and abort.

Snapshot to get the "Transfer money" button ref (usually around `e22`):

```
openclaw_browser_snapshot(profile="zenex")
```

Click the final "Transfer money" button:

```
openclaw_browser_click(ref="<transfer_money_ref>", profile="zenex")
```

Wait 4 seconds.

### 6. Verify success (L5 test)

Screenshot the confirmation page:

```
openclaw_browser_screenshot(profile="zenex")
```

The URL should contain `singleTransferConfirmation;paymentId=<number>` — the paymentId IS the confirmation number.

The page must show:
- ✅ green checkmark
- "You've scheduled a transfer of $X.XX to your [Destination] account."
- Transaction number
- Status in the activity log at the bottom showing "Completed"

**Binary pass/fail:** Confirmation checkmark visible + paymentId in URL = pass.

## Why not use `openclaw_chase_transfer`?

The existing `openclaw_chase_transfer` MCP tool runs a Node.js CDP script that connects to `port 9222` without specifying a target tab. It picks whichever tab CDP returns first, which is often a random unrelated tab (e.g. palisadestrategic.com). The script then navigates that wrong tab to Chase and fails because it's not logged in. Until the CDP script is patched to find the Chase tab explicitly, use this manual MCP flow.

## Common failures

| Error | Cause | Fix |
|-------|-------|-----|
| Snapshot shows "(no interactive elements)" | Form is inside an iframe | Navigate to the iframe-bypass URL (step 2) |
| Click timeout on ref e2 | Stale refs — dropdown was opened in between | Re-snapshot and use fresh refs |
| Login error page "It looks like this part of our site isn't working" | Chase throttle or temp outage | Wait 1 minute, retry |
| "Enter your username" error shown after submit | `browser_type` went to wrong element OR refs were stale | Snapshot fresh and retry click+type sequence |
| CDP transfer tool says "Tile Transfer money button not found" | CDP picked wrong tab | Don't use `openclaw_chase_transfer`; use this manual flow |

## Do NOT

- Do not use `openclaw_chase_transfer` — it's broken due to tab selection bug
- Do not try to use a source account other than VVG Income (form only allows this one as source from the dashboard tile)
- Do not skip the screenshot verification step
- Do not hardcode refs — **always re-snapshot** after any click that changes page state (dropdowns, navigation, form submission)
