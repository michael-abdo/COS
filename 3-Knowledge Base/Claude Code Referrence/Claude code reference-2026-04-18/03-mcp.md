# MCP Servers: How Do I Connect Claude to External Systems?

**Quick Answer:** The Model Context Protocol (MCP) is an open standard for connecting Claude to tools, APIs, and data sources. You configure MCP servers in settings; Claude discovers and loads them automatically at session start. Each server exposes tools Claude can invoke, resources Claude can query, and prompts Claude should reference.

## MCP Core Concepts

**Summary:** MCP servers are integrations that expose three types of capabilities: tools (Claude can invoke), resources (Claude can read), and prompts (context Claude should load). Servers are stateless; Claude Code manages the connection. Configure in `.mcp.json` or settings, and Claude discovers at startup. Anthropic maintains built-in servers; you can add community or custom servers. (52 words)

| Component | Role |
|-----------|------|
| **Tools** | Actions Claude can invoke (query API, run command, etc.) |
| **Resources** | Data Claude can read (files, databases, dashboards) |
| **Prompts** | Context or instructions loaded when relevant |
| **Configuration** | `.mcp.json` or settings tells Claude Code where server runs |

## Server Types: Built-in, Community, Custom

**Summary:** Anthropic maintains built-in servers for common integrations (GitHub, linear, Slack, etc.). Community repos host additional servers. You can create custom servers using the MCP spec in any language. Custom servers run as separate processes; Claude Code communicates via standard protocol. One configuration file can load servers from multiple sources. (53 words)

| Server Type | Maintenance | Setup | When to Use |
|-------------|-------------|-------|------------|
| **Built-in** | Anthropic | Toggle in settings | GitHub, Slack, Jira, etc. |
| **Community** | Community maintainers | Add repo to config | Specialized integrations |
| **Custom** | You | Build + configure | Internal APIs, private systems |

## Examples Across Domains

**Systems:** MCP server wraps your Datadog API. Claude queries deployment logs, reviews metrics, restarts services—all through Claude tools bound to your API.

**Trading:** Custom MCP server queries your broker's position database. Claude sees current holdings, can check historical fills, queries volatility surfaces—live market state always accessible.

**Hiring:** GitHub MCP server queries candidates' repos. Claude reads code, reviews contributions, checks open-source activity without leaving the conversation.

**Consulting:** Slack MCP server lets Claude read team updates, post status messages, and reply in threads while focusing on analysis in Claude Code.
