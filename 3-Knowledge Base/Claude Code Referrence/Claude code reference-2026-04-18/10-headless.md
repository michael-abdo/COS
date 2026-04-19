# Programmatic Execution: How Do I Run Claude Code from Scripts or CI?

**Quick Answer:** Use the Agent SDK CLI, Python, or TypeScript to run Claude Code non-interactively. Pass `-p` with your prompt to the CLI, or import the SDK in scripts. The same tools, agent loop, and context management power both interactive and programmatic execution.

## What Is the Agent SDK?

**Summary:** The Agent SDK provides programmatic access to Claude Code's tools, agent loop, and context management via CLI, Python, or TypeScript packages. Run Claude in scripts, CI/CD pipelines, or backend services without a terminal. All Claude Code features work programmatically: tool approval, memory, hooks, skills, plugins, MCP servers, CLAUDE.md. (52 words)

The Agent SDK removes the interactive terminal. Your scripts and CI systems now have the same Claude capabilities you do manually.

## CLI Usage

Add the `-p` (or `--print`) flag to run non-interactively:

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

All CLI options work with `-p`:

| Option | Purpose |
|--------|---------|
| `-p "prompt"` | Run with given prompt, no interaction |
| `--continue` | Continue a previous conversation |
| `--allowedTools` | Pre-approve tools, no confirmation prompts |
| `--output-format json` | Structured output for parsing |
| `--bare` | Skip auto-discovery for deterministic CI behavior |

## Bare Mode: Deterministic CI Behavior

**Summary:** Bare mode skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md. Use it in CI and scripts where you need identical results on every machine, regardless of local configuration. Bare mode reduces startup time and eliminates environmental variation. Specify only what the script needs. (49 words)

Without `--bare`, Claude discovers and loads your local project config, which may differ across machines. In CI, that's a problem: the same script produces different results depending on the agent's environment. Bare mode guarantees consistency.

```bash
# With auto-discovery (environment-dependent)
claude -p "Run tests" --allowedTools "Bash"

# Bare mode (same result everywhere)
claude -p "Run tests" --allowedTools "Bash" --bare
```

## Examples Across Domains

**Hiring:** CI pipeline spawns Claude agent with `-p "Screen candidates from queue"`, receives JSON results, posts to ATS. Uses `--bare` so candidate screening works identically on all CI runners.

**Trading:** Backend cron spawns Claude agent with `-p "Check portfolio risk"`, returns JSON threshold violations. Bare mode ensures risk check is consistent across staging and production.

**Systems:** Post-deploy hook spawns Claude agent with `-p "Run smoke tests"` and `--allowedTools "Bash,Read"`. Bare mode prevents local plugins from interfering with deployment validation.

**Consulting:** Scheduled job spawns Claude agent with `-p "Generate weekly status report"`, returns formatted markdown, posts to Slack. Bare mode ensures report format is identical every week.

## Python and TypeScript SDKs

The Agent SDK is also available as Python and TypeScript packages for deeper programmatic control:

| Language | Use Case |
|----------|----------|
| **CLI** | Scripts, CI/CD pipelines, shell integration |
| **Python** | Backend services, data pipelines, ML workflows |
| **TypeScript** | Node.js backends, serverless functions, web servers |

Each provides the same agent loop with language-native API and error handling.
