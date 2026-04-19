# Plugins: What's the Difference Between Plugins and .claude/ Configuration?

**Quick Answer:** Plugins are versioned packages that bundle skills, agents, hooks, and MCP servers—designed for sharing across projects and teams. The `.claude/` directory is for personal, project-specific configuration. Choose plugins when you want to reuse functionality across multiple projects or share with teammates; choose `.claude/` for one-off customization.

## Standalone Configuration vs. Plugins

**Summary:** Standalone configuration (`.claude/` directory) applies only to the current project. Plugins are versionable packages that can be installed across projects. Use standalone for personal, experimental, or one-time customizations. Use plugins when you need the same skills across multiple projects, want to share with teammates, or intend to publish to a marketplace. (49 words)

| Aspect | Standalone (`.claude/`) | Plugins |
|--------|--------|----------|
| **Scope** | Single project only | Reusable across projects |
| **Skill namespace** | `/skill-name` | `/plugin-name:skill-name` |
| **Version control** | Manual; live edits | Semantic versioning |
| **Sharing** | Copy directory | Install from marketplace |
| **Best for** | Experiments, personal | Repeated use, team distribution |

## Plugin Structure

**Summary:** A plugin is a directory with `.claude-plugin/plugin.json` (metadata), plus optional directories: `skills/`, `agents/`, `hooks/`, `.mcp.json`, and supporting files. The manifest declares version, dependencies, and author. Skills are stored as `skill-name/SKILL.md`. Hooks go in `hooks/hooks.json`. Everything loads automatically when the plugin is enabled. (51 words)

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `.claude-plugin/` | Metadata only | `plugin.json` manifest |
| `skills/` | Reusable procedures | `skill-name/SKILL.md` files |
| `agents/` | Custom agent definitions | Agent configuration files |
| `hooks/` | Event automation | `hooks.json` configuration |
| `.mcp.json` | External integrations | MCP server configs |

## Examples Across Domains

**Hiring:** Create a `recruiting-toolkit` plugin with skills for resume parsing, candidate outreach, interview scheduling. Use it on every hiring project. Share with recruiting team via marketplace.

**Trading:** Create a `backtest-suite` plugin with agents for strategy validation, risk analysis, and performance reporting. Install on every strategy evaluation project.

**Systems:** Create a `deploy-toolkit` plugin with hooks for pre-commit checks, post-deployment smoke tests. Share across all infrastructure projects so everyone runs same checks.

**Consulting:** Create a `client-analysis` plugin with skills for competitor research, market sizing, financial modeling. Reuse it on every engagement without copy-pasting.

[Full documentation saved from https://code.claude.com/docs/en/plugins.md]
