---
name: tradovate-login
description: Login to Tradovate on the GCP VM headless Chrome via CDP form-fill
user-invocable: false
---

# Tradovate VM Login

Login to Tradovate on the headless Chrome instance running on the GCP VM (`claude-dev-1750040389`).

## Architecture

There are two layers:
- **Local script** (`push_tradovate_session.py`) — run from your Mac via SSH tunnel, for manual login
- **VM watchdog** (`tradovate_watchdog.py`) — runs on the VM via cron every 5 min, auto-heals expired sessions

The watchdog handles self-healing automatically. This slash command is for manual intervention.

## Steps

### 1. Ensure SSH tunnel

Check if port 9223 is already forwarded. If not, establish the tunnel:

```bash
if lsof -iTCP:9223 -sTCP:LISTEN &>/dev/null; then
    echo "SSH tunnel already up"
else
    gcloud compute ssh claude-dev-1750040389 --zone=us-central1-a --project=claude-code-dev-20250615-1851 -- -L 9223:localhost:9223 -N -f
fi
```

### 2. Run the login script

```bash
python3 /Users/Mike/2025-2030/Trading/scripts/push_tradovate_session.py
```

This will:
- Get Tradovate credentials (vault → 1Password → `.tradovate_env`)
- Connect to the VM's headless Chrome via CDP on `localhost:9223`
- Fill the login form (`#name-input`, `#password-input`) and click Login
- Wait for redirect away from `/welcome` to confirm success

### 3. Report result

If the script reports SUCCESS (redirected away from `/welcome`), confirm to the user.

If it reports FAILED, run a check to grab a screenshot:

```bash
python3 /Users/Mike/2025-2030/Trading/scripts/push_tradovate_session.py --check
```

Then show the screenshot at `/tmp/tradovate_vm_screenshot.png` to the user so they can see what's on screen (reCAPTCHA, error message, etc.).

## VM Watchdog (self-healing, 2 layers)

The watchdog runs on the VM and auto-heals without local intervention:

| Component | Location |
|-----------|----------|
| Script | `/home/Mike/projects/trading/scripts/tradovate_watchdog.py` |
| Credentials | `/home/Mike/projects/trading/scripts/.tradovate_live_env` (chmod 600) |
| Cron | `*/5 * * * 0-5` (every 5 min, Sun-Fri Globex hours) |
| Log | `/home/Mike/projects/trading/scripts/logs/tradovate_watchdog.log` |
| Alerts | ntfy.sh → `mikiel-trading-heartbeat` topic |

### Healing layers

| Layer | Method | When |
|-------|--------|------|
| 1 | CDP form fill | Session expired, no CAPTCHA |
| 2 | Bridge → Claude + OpenClaw | CAPTCHA detected or Layer 1 timeout |
| alert | ntfy `urgent` | Both layers fail → manual intervention |

Layer 2 dispatches a task to the bridge API (`localhost:8585/task`) which runs Claude Code with OpenClaw browser tools (Playwright on the stonkz Chrome profile = port 9223). Claude can see and click the reCAPTCHA visually.

To check watchdog status:
```bash
gcloud compute ssh claude-dev-1750040389 --zone=us-central1-a --project=claude-code-dev-20250615-1851 --command="tail -20 /home/Mike/projects/trading/scripts/logs/tradovate_watchdog.log"
```
