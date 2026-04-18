# Subagents: When Should I Delegate to Isolated Context?

**Quick Answer:** Subagents are isolated worker threads—each runs in its own context window with custom system prompt, tool restrictions, and permissions. Use one when a research or verification task would clutter your main conversation, or when you need to enforce constraints on what tools a worker can use.

## What Are Subagents?

**Summary:** Subagents are specialized AI assistants that handle specific task types in isolated context windows. When you spawn a subagent, it works independently with its own system prompt, tool allowlist, and permissions. Results return to the main conversation as summaries. Use subagents to preserve context—keeping exploration separate from implementation—and to enforce hard constraints on tool access. (60 words)

| Aspect | Purpose |
|--------|---------|
| **Context Isolation** | Task runs in separate window; results summarized back |
| **Tool Restrictions** | Limit which tools the subagent can access |
| **Custom Prompt** | Define specialized behavior for the task type |
| **Independent Permissions** | Subagent permissions don't affect main session |
| **Reusability** | Define once, spawn many times across projects |

## When to Use Subagents vs. Agent Teams

**Summary:** Subagents work within a single session and report results back to the main agent. Agent teams coordinate multiple independent sessions with direct inter-agent communication. Choose subagents for focused, sequential work. Choose teams for parallel exploration where workers need to discuss and challenge each other's findings. (48 words)

| Feature | Subagents | Agent Teams |
|---------|-----------|-------------|
| Context | Isolated; summarizes back | Fully independent |
| Communication | Report-only to main agent | Direct agent-to-agent |
| Best for | Focused, sequential tasks | Parallel hypothesis testing |
| Token cost | Lower; results summarized | Higher; each has full window |
| Coordination | Main agent decides flow | Agents self-coordinate via task list |

## Examples Across Domains

**Hiring:** Spawn a subagent to research a candidate's GitHub repos while you review cover letters. The subagent returns a summary: public projects, language stats, contribution patterns.

**Trading:** Spawn a subagent to backtest a strategy on 10 years of SPY data. Main agent continues monitoring live positions. Subagent returns win rate and max drawdown.

**Systems:** Spawn a subagent to debug a performance regression in logs while you review the recent code changes. Subagent returns root cause analysis: which function calls are slow.

**Consulting:** Spawn a subagent to compile a competitive analysis while you draft the client proposal. Subagent returns one-page summary of 5 competitors' pricing, features, and weaknesses.
