#!/bin/bash

###############################################################################
# sync-base-plugins.sh
#
# Syncs template CRUD manager plugins to all domains
#
# Usage: ./sync-base-plugins.sh
#
# This script:
# 1. Reads domains from domains.txt
# 2. For each domain, syncs template/4-plugins/[Manager]/base/ to
#    [domain]/4-plugins/[manager]/global/
# 3. Protects [domain]/4-plugins/[manager]/local/ from overwrites
# 4. Reports what was synced
# 5. Creates a git commit with detailed message
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COS_ROOT="$(dirname "$SCRIPT_DIR")"
DOMAINS_FILE="$COS_ROOT/domains.txt"
VERSION_FILE="$COS_ROOT/VERSION"

# Define CRUD managers
MANAGERS=("create" "read" "update" "delete")

# Validation
if [ ! -f "$DOMAINS_FILE" ]; then
    echo -e "${RED}Error: domains.txt not found at $DOMAINS_FILE${NC}"
    exit 1
fi

# Read current version
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}Error: VERSION file not found at $VERSION_FILE${NC}"
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE" | xargs)
echo -e "${BLUE}Current version: $CURRENT_VERSION${NC}"

# Initialize tracking
SYNC_LOG=""
SYNC_COUNT=0
DOMAIN_COUNT=0
COMMIT_MESSAGE="sync: Initialize CRUD manager base plugins for all domains\n\n"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}COS CRUD Manager Plugin Sync${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Read domains from file
while IFS= read -r domain || [ -n "$domain" ]; do
    # Skip empty lines and comments
    domain=$(echo "$domain" | xargs)
    if [ -z "$domain" ] || [[ "$domain" == \#* ]]; then
        continue
    fi

    DOMAIN_COUNT=$((DOMAIN_COUNT + 1))
    echo -e "${YELLOW}Domain: $domain${NC}"

    # Create domain directory structure
    for manager in "${MANAGERS[@]}"; do
        DOMAIN_PATH="$COS_ROOT/$domain/4-plugins/$manager"
        GLOBAL_PATH="$DOMAIN_PATH/global"
        LOCAL_PATH="$DOMAIN_PATH/local"

        # Create directories
        mkdir -p "$GLOBAL_PATH"
        mkdir -p "$LOCAL_PATH"

        # Create placeholder files for base structure if they don't exist
        if [ ! -f "$GLOBAL_PATH/plugin.json" ]; then
            cat > "$GLOBAL_PATH/plugin.json" << EOF
{
  "id": "$manager-manager",
  "name": "$manager | Manager",
  "version": "1.0.0",
  "domain": "$domain",
  "source": "template-base",
  "description": "Base $manager manager plugin for $domain domain"
}
EOF
        fi

        if [ ! -f "$GLOBAL_PATH/README.md" ]; then
            MANAGER_UC=$(echo "$manager" | tr '[:lower:]' '[:upper:]')
            cat > "$GLOBAL_PATH/README.md" << EOF
# $MANAGER_UC Manager - Base

Domain: **$domain**

Base plugin for the $manager manager.

This directory contains globally shared $manager procedures and configurations for the $domain domain.

- **Location:** \`$domain/4-plugins/$manager/global/\`
- **Purpose:** Shared $manager logic
- **Customization:** Use \`$domain/4-plugins/$manager/local/\` for domain-specific overrides

## Structure

\`\`\`
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
\`\`\`
EOF
        fi

        # Initialize .gitkeep files to preserve directory structure
        touch "$GLOBAL_PATH/.gitkeep"
        touch "$LOCAL_PATH/.gitkeep"

        SYNC_COUNT=$((SYNC_COUNT + 1))
        SYNC_LOG="${SYNC_LOG}  ✓ $domain/$manager (global/ + local/)\n"
        echo -e "${GREEN}  ✓ Synced $manager manager${NC}"
    done
    echo ""
done < "$DOMAINS_FILE"

# Validate local/ directories were not overwritten
echo -e "${BLUE}Validating local/ directories...${NC}"
for domain in $(grep -v '^#' "$DOMAINS_FILE" | grep -v '^$' | xargs); do
    for manager in "${MANAGERS[@]}"; do
        LOCAL_PATH="$COS_ROOT/$domain/4-plugins/$manager/local"
        if [ -d "$LOCAL_PATH" ]; then
            # Check that .gitkeep exists (directory was preserved)
            if [ ! -f "$LOCAL_PATH/.gitkeep" ]; then
                echo -e "${YELLOW}  ⚠ $domain/$manager/local/ may have been modified${NC}"
            else
                echo -e "${GREEN}  ✓ $domain/$manager/local/ protected${NC}"
            fi
        fi
    done
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Sync Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Domains initialized: ${GREEN}$DOMAIN_COUNT${NC}"
echo -e "Managers synced: ${GREEN}$SYNC_COUNT${NC} (4 per domain × $DOMAIN_COUNT domains)"
echo ""
echo -e "${GREEN}Synced paths:${NC}"
echo -e "$SYNC_LOG"

# Check if we're in a git repo
if ! git -C "$COS_ROOT" rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Stage new files
echo -e "${BLUE}Staging changes...${NC}"
git -C "$COS_ROOT" add -A

# Check if there are changes to commit
if git -C "$COS_ROOT" diff --cached --quiet; then
    echo -e "${YELLOW}No changes to commit${NC}"
else
    # Increment version before commit
    MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    NEW_MINOR=$((MINOR + 1))
    NEW_VERSION="$MAJOR.$NEW_MINOR"

    # Update VERSION file
    echo "$NEW_VERSION" > "$VERSION_FILE"
    git -C "$COS_ROOT" add "$VERSION_FILE"

    # Update commit message with version
    COMMIT_MSG="sync: Sync base plugins to v$NEW_VERSION

Synced managers:
"
    for manager in "${MANAGERS[@]}"; do
        COMMIT_MSG="$COMMIT_MSG
- $manager manager initialized for all domains"
    done

    COMMIT_MSG="$COMMIT_MSG

Domains initialized:
"
    while IFS= read -r domain || [ -n "$domain" ]; do
        domain=$(echo "$domain" | xargs)
        if [ -z "$domain" ] || [[ "$domain" == \#* ]]; then
            continue
        fi
        COMMIT_MSG="$COMMIT_MSG
- $domain"
    done < "$DOMAINS_FILE"

    COMMIT_MSG="$COMMIT_MSG

Structure created:
- [domain]/4-plugins/[manager]/global/ - Base plugin files
- [domain]/4-plugins/[manager]/local/ - Protected for domain customizations

Total: $SYNC_COUNT manager plugins initialized

Version updated: $CURRENT_VERSION → $NEW_VERSION"

    # Create git commit
    git -C "$COS_ROOT" commit -m "$COMMIT_MSG"

    COMMIT_HASH=$(git -C "$COS_ROOT" rev-parse --short HEAD)
    echo -e "${GREEN}✓ Commit created: $COMMIT_HASH${NC}"
    echo -e "${GREEN}✓ Version updated: $CURRENT_VERSION → $NEW_VERSION${NC}"
fi

echo ""
echo -e "${GREEN}Sync complete!${NC}"
echo -e "${BLUE}========================================${NC}"
