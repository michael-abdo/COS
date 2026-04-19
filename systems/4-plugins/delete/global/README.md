# DELETE Manager - Base

Domain: **systems**

Base plugin for the delete manager.

This directory contains globally shared delete procedures and configurations for the systems domain.

- **Location:** `systems/4-plugins/delete/global/`
- **Purpose:** Shared delete logic
- **Customization:** Use `systems/4-plugins/delete/local/` for domain-specific overrides

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
