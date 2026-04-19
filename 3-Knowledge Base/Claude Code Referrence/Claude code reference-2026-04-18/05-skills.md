# Skills: When Should I Extract a Playbook Into a Reusable Procedure?

**Quick Answer:** Skills are procedures Claude invokes automatically or on-demand when you type `/skill-name`. Create one when you find yourself pasting the same multi-step playbook repeatedly, or when a CLAUDE.md section has grown into actionable steps rather than reference facts. Skills load only when invoked, so long guides cost nothing until used.

## What Is a Skill?

**Summary:** A skill is a SKILL.md file with frontmatter (metadata) and markdown instructions (the procedure). Claude can invoke skills automatically when they match task context, or you invoke manually with `/skill-name`. Skills load only on use, unlike CLAUDE.md reference material which is always in context. Supporting files (templates, examples, scripts) stay alongside SKILL.md for Claude to reference. (54 words)

| Aspect | CLAUDE.md Reference | Skill |
|--------|--------|--------|
| **When loaded** | Every session start | On-demand when invoked |
| **Use case** | Guidelines, conventions | Step-by-step procedures |
| **Invocation** | N/A | `/skill-name` or auto-trigger |
| **Context cost** | Always present | Only when used |
| **Files** | Single file | Directory with supporting files |

## Skill Invocation: Manual vs. Automatic

**Summary:** Skills have a `disable-model-invocation` frontmatter field. Leave it unset (default): both you and Claude can invoke the skill. Set to `true`: only you invoke manually. Use manual for workflows with side effects (commit, deploy, send message). Use automatic for knowledge skills Claude should apply when relevant. Describe what the skill does so Claude knows when to use it. (58 words)

| Invocation | When to Use | Example |
|------------|------------|---------|
| **Automatic (default)** | Background knowledge, linters, checklists | `/explain-code`, `/style-guide` |
| **Manual only** | Side effects, controlled timing | `/deploy`, `/commit`, `/send-slack` |
| **Restricted context** | Forked subagent execution | Skills with `context: fork` |

## Examples Across Domains

**Hiring:** Create `/phone-screen` skill: list of questions, evaluation rubric, reference checks. You invoke manually before each call. Claude applies it every time.

**Trading:** Create `/backtest` skill: load historical data, run strategy, record metrics, flag risks. Invoke manually for each hypothesis test.

**Systems:** Create `/code-review` skill: security checklist, performance review, test coverage validation. Claude applies automatically when reviewing PRs.

**Consulting:** Create `/client-proposal` skill: RFP analysis template, scope definition, timeline building. You invoke when starting an engagement.

<Note>
  For built-in commands like `/help` and `/compact`, and bundled skills like `/debug` and `/simplify`, see the [commands reference](/en/commands).

  **Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way. Your existing `.claude/commands/` files keep working. Skills add optional features: a directory for supporting files, frontmatter to [control whether you or Claude invokes them](#control-who-invokes-a-skill), and the ability for Claude to load them automatically when relevant.
</Note>

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools. Claude Code extends the standard with additional features like [invocation control](#control-who-invokes-a-skill), [subagent execution](#run-skills-in-a-subagent), and [dynamic context injection](#inject-dynamic-context).

[Full documentation saved from https://code.claude.com/docs/en/skills.md]
