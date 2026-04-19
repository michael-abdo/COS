# UPDATE Manager - Base

Domain: **trading**

Base plugin for the update manager.

This directory contains globally shared update procedures and configurations for the trading domain.

- **Location:** `trading/4-plugins/update/global/`
- **Purpose:** Shared update logic
- **Customization:** Use `trading/4-plugins/update/local/` for domain-specific overrides

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
