# CREATE Manager - Base

Domain: **systems**

Base plugin for the create manager.

This directory contains globally shared create procedures and configurations for the systems domain.

- **Location:** `systems/4-plugins/create/global/`
- **Purpose:** Shared create logic
- **Customization:** Use `systems/4-plugins/create/local/` for domain-specific overrides

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
