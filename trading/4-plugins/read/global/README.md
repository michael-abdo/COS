# READ Manager - Base

Domain: **trading**

Base plugin for the read manager.

This directory contains globally shared read procedures and configurations for the trading domain.

- **Location:** `trading/4-plugins/read/global/`
- **Purpose:** Shared read logic
- **Customization:** Use `trading/4-plugins/read/local/` for domain-specific overrides

## Structure

```
global/
├── plugin.json
├── README.md
├── ROLE.md (manager role definition)
├── PROCEDURES.md (manager procedures)
├── skills/ (reusable procedures)
└── hooks/ (event handlers)

local/
├── plugin.json (domain overrides)
└── [domain-specific customizations]
```
