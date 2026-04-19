# Hooks: When Should Deterministic Rules Override Claude's Judgment?

**Quick Answer:** Hooks are shell commands that execute automatically at specific lifecycle points—when Claude edits files, finishes tasks, or needs input. Use hooks for deterministic actions (format code, send notifications, validate commands) that should always run. For decisions requiring judgment, use prompt-based or agent-based hooks instead.

## What Are Hooks?

**Summary:** Hooks are user-defined shell commands that execute deterministically at specific points in Claude Code's lifecycle. They ensure certain actions always happen rather than relying on the LLM to choose to run them. Hooks enforce project rules, automate repetitive tasks, and integrate with existing tools. They prevent Claude from accidentally skipping critical steps. (55 words)

Hooks provide control when you need guarantees, not flexibility. They run at predictable moments: on file edits, task completion, or when awaiting input. No judgment calls—just execution.

## Types of Hooks

**Summary:** Shell hooks run deterministic commands (format, validate, notify). Prompt-based hooks use Claude to evaluate conditions before deciding whether to execute. Agent-based hooks spawn isolated agents to handle complex decisions. Choose shell for guarantees, prompt/agent for judgment. Each type solves different problems. (45 words)

| Hook Type | When to Use | Example |
|-----------|-----------|---------|
| **Shell Hook** | Action must always happen; no judgment needed | Format code, send Slack notification, validate syntax |
| **Prompt-based Hook** | Need Claude to evaluate a condition | Decide if test failures are critical before notifying |
| **Agent-based Hook** | Need isolated context to handle decision | Spawn triage agent to classify error severity |

## Common Use Cases Across Domains

**Hiring:** Auto-format candidate feedback before sending to pipeline; notify recruiter when new requisitions arrive.

**Trading:** Validate trade syntax before execution; notify risk team if position exceeds threshold; format trade logs for compliance.

**Systems:** Run linter after code edit; send deployment notification to Slack; validate infrastructure changes against policy.

**Consulting:** Auto-format deliverables; notify stakeholders when tasks complete; validate client data privacy rules.

## Configuration

Hooks are defined in a settings file (`.claude/settings.json` or project-level config). Specify the event, the command to run, and optionally the hook type (shell, prompt, or agent).

## Hooks vs. Other Extensions

| Extension | Purpose | Execution Model |
|-----------|---------|-----------------|
| **Hooks** | Enforce deterministic rules at lifecycle points | Automatic, no judgment |
| **Skills** | Give Claude additional instructions and commands | Claude-initiated, optional |
| **Plugins** | Package extensions with skills, agents, hooks together | Installable, reusable |
| **MCP Servers** | External integrations (databases, APIs, tools) | On-demand tool calls |
