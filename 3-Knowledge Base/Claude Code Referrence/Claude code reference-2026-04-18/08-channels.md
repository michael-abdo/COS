# Channels: How Do I Push Events Into a Running Session?

**Quick Answer:** Channels are MCP servers that push messages, alerts, and webhooks directly into an open Claude Code session. Unlike polling integrations, events arrive immediately while the session is running. Claude can read events and reply through the same channel, creating two-way bridges to external systems.

## What Is a Channel?

**Summary:** A channel is an MCP server that pushes events into your running Claude Code session so Claude can react to external events in real-time. Events only arrive while the session is open, enabling immediate response without polling or spawning new sessions. Channels support two-way communication: Claude reads events and replies back through the same channel. (57 words)

Channels solve the "always-on awareness" problem. Without them, Claude waits passively for you to ask about external events. With them, Claude learns immediately when CI fails, a message arrives, or a metric spikes.

## Push vs. Poll: How Channels Differ

**Summary:** Polling-based integrations spawn fresh sessions and repeatedly check for new data, wasting compute and adding delay. Push channels deliver events directly into your open session immediately, without requiring you to poll or restart. Events arrive in-session only while the session is active. For always-on setups, run Claude in a background process. (55 words)

| Model | How It Works | Latency | Cost |
|-------|-------------|---------|------|
| **Polling (Traditional Integration)** | Spawn session, check for events, return result, close session | High (minutes to hours) | High (many sessions) |
| **Push (Channel)** | Event arrives in open session instantly | Low (seconds) | Low (single session) |

## Two-Way Channels

Channels can be bidirectional: Claude reads incoming events and sends replies back through the same channel.

**Hiring example:** Recruiter sends message via Slack channel → Claude reads in session → Claude replies with candidate summary → Message posted back to Slack.

**Trading example:** Risk alert arrives via Telegram → Claude reads in session → Claude queries positions → Claude sends back recommendation to Telegram.

## Examples Across Domains

**Hiring:** Slack channel pushes new applicant alerts into session; Claude reviews and replies with screening decision back to Slack.

**Trading:** Telegram channel delivers market alerts; Claude reacts in-session and sends position checks back to team.

**Systems:** Discord channel pushes CI failures into session; Claude diagnoses and posts fix back to Discord.

**Consulting:** iMessage channel sends client requests; Claude responds with status updates back to the client.

## Channel Configuration

Install a channel as a plugin, then configure with your credentials:
- Slack, Discord, iMessage, Telegram supported in research preview
- Credentials stored securely
- One channel per external platform
- Multiple sessions can subscribe to the same channel

## Always-On Setup

For continuous operation:
1. Run Claude Code in a background process: `nohup claude --continue &`
2. Attach channel plugins
3. Session remains open; events push in immediately
4. Resume with `--continue` to restore tasks and channels
