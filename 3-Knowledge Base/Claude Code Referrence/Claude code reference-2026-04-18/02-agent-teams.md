# Agent Teams: When Do I Need Multiple Sessions Communicating?

**Quick Answer:** Agent teams coordinate multiple independent Claude Code sessions—each teammate has its own context window and can message other teammates directly. Use teams when parallel exploration adds value: different reviewers checking security vs. performance vs. tests simultaneously, or multiple hypotheses tested in parallel.

## When Agent Teams Beat Single Sessions

**Summary:** Agent teams shine when parallel exploration adds real value: multiple teammates investigating different angles simultaneously, then comparing findings. Teams work best for research reviews, new feature implementation where modules are independent, debugging with competing hypotheses, and cross-layer changes. Teams cost more tokens but converge faster on complex problems. (50 words)

| Use Case | Why Teams Work |
|----------|----------------|
| **Research/Review** | Multiple perspectives on same problem; can challenge each other |
| **New Features** | Each teammate owns separate module; no step-on-each-other |
| **Competing Hypotheses** | Test theories in parallel; debate which is correct |
| **Cross-Layer Changes** | Frontend, backend, tests as independent teams |

## Teams vs. Subagents vs. Single Session

**Summary:** Subagents work in isolated context within one session; teams coordinate fully independent sessions with inter-agent messaging. Single sessions are best for sequential work. Subagents preserve context cheaply. Teams cost more tokens but enable direct agent-to-agent negotiation. Choose based on whether teammates must communicate. (48 words)

| Feature | Single Session | Subagents | Agent Teams |
|---------|----------------|-----------|-------------|
| Context | One window | Isolated; results return | Fully independent |
| Communication | N/A | Report to main only | Direct agent-to-agent |
| Token cost | Lowest | Medium | Highest |
| Best for | Sequential work | Focused tasks | Parallel with discussion |
| Coordination | Linear | Lead decides | Self-coordinate via tasks |

## Examples Across Domains

**Hiring:** Spawn 3 teammates—one reviews technical fit, one checks culture alignment, one plays devil's advocate. Each reads the same resume and interviews independently, then they debate conclusions.

**Trading:** Spawn 4 hypothesis teams—trend-follower, mean-reversion, volatility arbitrage, macro regime. Each backtests simultaneously on same market data. They report results; you decide which to deploy.

**Systems:** Spawn 3 reviewers—one audits security implications, one checks performance, one validates test coverage. All review same PR simultaneously, challenge each other's conclusions.

**Consulting:** Spawn market research, financial modeling, and competitive analysis teams. Each owns a workstream. They share findings weekly and identify synergies nobody noticed working solo.

[Full documentation saved from https://code.claude.com/docs/en/agent-teams.md]
