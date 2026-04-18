---
name: chase-pay
description: Pay a Chase credit card in one tool call. Handles browser start, vault login, and payment via the openclaw_chase_pay_auto MCP tool. Use when the user asks to pay their Chase CC, transfer to a credit card, or schedule a Chase card payment. Always confirm amount and source account with the user before executing — real money moves.
user-invocable: true
---

# Chase Pay — Single-Call Credit Card Payment

Schedules a Chase credit card payment with zero manual navigation. The single tool `openclaw_chase_pay_auto` handles everything: starting Chrome, logging in via the vault, and running the payment.

## When to use

- User says "pay my Chase CC", "pay the credit card from [account]", "schedule a Chase payment"
- User wants to transfer money from a Chase checking account to a Chase credit card

## Before you call the tool

**Always confirm with the user:**
1. **Amount** — dollar figure
2. **Source account** — which checking account to pay from (Day Trading, VVG Income, Personal Brand, etc.)
3. **Destination** — confirm it's the Expenses CC (default) unless user specifies otherwise

Real money moves. Do not guess. If the user hasn't named a source account, ask which one.

## How to call

```python
openclaw_chase_pay_auto(
    amount="100",                        # string, dollar amount
    from_account="Day Trading (...9742)", # string, REQUIRED — no default
    date=""                              # optional, mm/dd/yyyy, defaults to today
)
```

**Known source account labels** (use exact strings):
- `"Day Trading (...9742)"`
- `"VVG Income (...0312)"`
- `"Personal Brand (...3655)"`

## Verification (L5 test)

After the tool returns success, take a screenshot to confirm the payment flyout is visible:

```python
openclaw_browser_screenshot(profile="zenex")
```

The screenshot must show:
- "You've scheduled a $X.XX payment to Expenses (...8417)"
- Source account matching what was requested
- A confirmation number
- Status: Pending

**Binary pass/fail:** Confirmation flyout visible = pass. Anything else = investigate the `pay_result` field in the tool response.

## If it fails

The tool returns a `step` field indicating where it failed:
- `ensure_chrome` — Chrome failed to start. Check `openclaw_browser_start` manually.
- `vault_autofill` — Login fill failed. Check vault credentials with `openclaw_vault_get "chase.com"`.
- `wait_for_dashboard` — Login didn't reach dashboard. Chase may be prompting for 2FA or showing a security screen. Screenshot and investigate.
- Pay step errors — Look at `pay_result.error`. If it mentions "Other amount" or "Timeout waiting for element", the underlying CDP script may need updating.

## Do NOT

- Do not use `openclaw_chase_pay` directly — it requires manual login setup
- Do not use `openclaw_chase_combo` unless the user explicitly wants the two-step transfer+pay flow
- Do not default the source account — always require explicit user input
- Do not bypass the screenshot verification step
