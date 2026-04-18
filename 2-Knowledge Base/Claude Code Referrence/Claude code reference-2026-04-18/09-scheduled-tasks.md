# Scheduled Tasks: When Should I Repeat a Prompt?

**Quick Answer:** Use `/loop` to run prompts on a schedule—polling for status, babysitting long-running tasks, or setting one-time reminders. Tasks are session-scoped and survive session restarts if unexpired. For reactive behavior (events arriving without polling), use channels instead.

## What Are Scheduled Tasks?

**Summary:** Scheduled tasks automatically re-run a prompt on a specified interval within a Claude Code session. Use them to poll deployments, monitor PR merges, check build status, or trigger reminders later in the session. Tasks execute on your machine while the session runs, and persist across restarts if within expiration windows. (51 words)

Scheduled tasks solve the "checking problem." Without them, you poll manually: "Is the build done yet?" With tasks, Claude checks automatically on your schedule.

## /loop vs. Other Scheduling Options

**Summary:** Claude Code offers three scheduling models: Cloud (Anthropic infrastructure, always running, persistent), Desktop (your machine, scheduled task daemon, persistent), and /loop (in-session, lightweight, requires open session). Choose /loop for simple polling within a session. Choose Cloud for always-on without keeping a terminal open. Choose Desktop for persistent background scheduling. (52 words)

| Option | Runs On | Requires Session Open? | Persists Across Restarts? | Best For |
|--------|---------|----------------------|-------------------------|----------|
| **/loop** | Your machine | Yes | Only if unexpired; restore with `--resume` | Session-scoped polling, reminders, babysitting |
| **Cloud scheduling** | Anthropic infrastructure | No | Yes | Always-on monitoring without your machine running |
| **Desktop cron** | Your machine | No | Yes | Persistent background tasks independent of Claude |

## Task Scope and Expiration

Tasks are session-scoped: they live in the current conversation. Starting a new session stops all tasks. Resuming with `--resume` or `--continue` restores unexpired tasks:
- **Recurring tasks:** Restored if created within the last 7 days
- **One-shot tasks:** Restored if scheduled time hasn't passed yet

## Examples Across Domains

**Hiring:** Schedule task to poll job board every 2 hours for new applications; auto-notify recruiter when threshold met.

**Trading:** Schedule task to check position P&L every 15 minutes; alert if drawdown exceeds tolerance.

**Systems:** Schedule task to poll deployment status every 5 minutes; rollback if build fails within 30 minutes.

**Consulting:** Schedule task to remind yourself at 3pm to send client status update; one-time task to check deliverable review by end of week.

## Push vs. Poll Decision

| Situation | Use This | Why |
|-----------|----------|-----|
| **CI failure arrives immediately, you react live** | Channels | No polling overhead; instant push |
| **You want to check status every N minutes** | /loop | Simple, lightweight, session-scoped |
| **Background job must run 24/7, you sleep** | Cloud or Desktop cron | Always-on without session overhead |
| **Reminder at specific future time** | One-shot /loop task | Perfect for "check on this later" |
