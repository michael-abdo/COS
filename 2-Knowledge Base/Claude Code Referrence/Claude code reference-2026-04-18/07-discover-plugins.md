# Plugin Marketplaces: How Do I Find and Install Extensions?

**Quick Answer:** Plugin marketplaces are catalogs of prebuilt extensions. Add a marketplace to register its catalog, then install individual plugins to extend Claude Code with skills, agents, hooks, and MCP servers without building them yourself.

## What Is a Plugin Marketplace?

**Summary:** A plugin marketplace is a catalog of prebuilt extensions created and shared by others. Marketplaces function like app stores: registering a marketplace gives you access to browse available plugins, but you still choose which ones to install individually. No automatic installation occurs. Each plugin bundles skills, agents, hooks, or MCP servers. (56 words)

Marketplaces solve discovery and distribution. Without them, you must build everything yourself. With them, you reuse battle-tested extensions.

## How Marketplaces Work

**Summary:** Two-step process: first, register the marketplace catalog with Claude Code (no plugins installed). Second, browse the catalog and install individual plugins you want. This decouples discovery from installation, allowing you to explore without commitment. Installing a plugin integrates its skills, agents, hooks, and MCP servers into your project. (52 words)

| Step | Action | Result |
|------|--------|--------|
| **1. Register** | Add marketplace URL to Claude Code settings | Catalog becomes browsable; no plugins installed |
| **2. Install** | Select and install individual plugins from catalog | Plugin's skills, agents, hooks, MCP servers integrated |

## What Plugins Contain

A single plugin can bundle:
- **Skills** — Reusable procedures Claude can call
- **Agents** — Specialized Claude instances with defined roles
- **Hooks** — Automated shell commands at lifecycle points
- **MCP Servers** — External integrations (databases, APIs, services)

## Examples Across Domains

**Hiring:** Marketplace plugin bundles candidate screening agent, resume parsing skill, ATS integration hook, and LinkedIn MCP server.

**Trading:** Marketplace plugin bundles risk validation hook, position size calculator skill, market data MCP server, and trade confirmation agent.

**Systems:** Marketplace plugin bundles code formatter hook, test validator skill, Kubernetes MCP server, and deployment agent.

**Consulting:** Marketplace plugin bundles deliverable formatter hook, stakeholder notification skill, CRM MCP server, and proposal review agent.

## Benefits of Using Marketplaces

| Benefit | Advantage |
|---------|-----------|
| **No build time** | Install working extensions instead of writing from scratch |
| **Quality assurance** | Plugins tested by multiple users before you install |
| **Speed to capability** | Hours instead of weeks to add new domain functionality |
| **Consistency** | All users of the same plugin share identical behavior |
