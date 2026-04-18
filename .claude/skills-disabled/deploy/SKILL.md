---
name: deploy
description: Commit, push, and deploy to production. Includes build verification, PM2 restart, and post-deploy health checks.
disable-model-invocation: true
user-invocable: true
---

# Commit, Push & Deploy

> **CI/CD is the primary deployment path.** Pushing to `main` triggers automated CI (lint, typecheck, build, security gate) and auto-deploy via GitHub Actions. Use this skill as a manual fallback for: emergencies when GitHub Actions is down, visual verification via OpenClaw, or first-time server setup.

Run the full commit-push-deploy-verify pipeline. Always runs all steps: commit, push, deploy to production, and visual verification.

## Step 1: Pre-commit checks

1. Run `git status` (never use `-uall`) to see changes
2. Run `git diff --staged` and `git diff` to review what will be committed
3. Run `git log --oneline -5` to match commit message style
4. Stage relevant files (prefer named files over `git add -A`)
5. Draft a concise commit message (1-2 sentences, focus on "why")
6. Create the commit using HEREDOC format

## Step 2: Security gate — dev-bypass-auth scan

**HARD GATE: Do NOT proceed to push or deploy if any check fails.**

Before pushing code that will reach production, scan the codebase for active dev-bypass-auth patterns. These are development shortcuts that disable or weaken authentication — catastrophic if they ship to production.

### What to scan for

Search the project's source files (`.ts`, `.tsx`, `.js`, `.env`) for these patterns:

```bash
# Run from the project root
grep -rn --include='*.ts' --include='*.tsx' --include='*.js' --include='*.env' \
  -E '(FEATURE_DEV_BYPASS|DEV_BYPASS_AUTH|DISABLE_AUTH|DISABLE_MIDDLEWARE|ALLOW_TEST_AUTH|BYPASS_AUTH|bypassAuth|devBypass)\s*[=:]\s*(true|1|"true")' \
  src/ app/ lib/ .env .env.local .env.production 2>/dev/null
```

Also check for hardcoded bypass logic in auth middleware:

```bash
grep -rn --include='*.ts' --include='*.tsx' --include='*.js' \
  -E '(return true|return NextResponse\.next|skipAuth|noAuth)\s*//.*bypass|//.*TODO.*remove|//.*HACK|//.*TEMP' \
  src/ app/ lib/ 2>/dev/null
```

### How to evaluate results

| Pattern Found | In `.env.example` or comments | In active code / `.env` / `.env.local` | Action |
|---------------|-------------------------------|----------------------------------------|--------|
| `FEATURE_DEV_BYPASS=true` | OK (example) | ❌ **BLOCK** | Must be `false` or unset |
| `DISABLE_AUTH=true` | OK (example) | ❌ **BLOCK** | Must be `false` or unset |
| `DISABLE_MIDDLEWARE=true` | OK (example) | ❌ **BLOCK** | Must be `false` or unset |
| `ALLOW_TEST_AUTH=true` | OK (example) | ❌ **BLOCK** | Must be `false` or unset |
| `bypassAuth` in runtime code | — | ⚠️ **REVIEW** | Verify it's gated by `NODE_ENV !== 'production'` |
| Hardcoded `return true` in auth | — | ❌ **BLOCK** | Must be removed |

### If the project has `scripts/security-check.sh`

Run it instead of manual grep — it covers all the above and more:

```bash
npm run security:check 2>/dev/null || bash scripts/security-check.sh
```

If it exits non-zero, **STOP and show the user the failures.** Do not proceed.

### If any check fails

1. Show the user a table of findings:

| File | Line | Pattern | Status |
|------|------|---------|--------|
| `src/middleware.ts` | 42 | `DISABLE_AUTH=true` | ❌ BLOCKED |

2. **Do NOT push or deploy.** Ask the user whether to fix and re-run, or override.
3. If the user explicitly says "override" or "deploy anyway" — proceed, but log it in the commit message: `[SECURITY OVERRIDE: dev-bypass-auth active]`.

### If all checks pass

Report: `🔒 Security gate passed — no active dev-bypass-auth patterns found` and proceed to Step 3.

## Step 3: Push

1. Push to the current branch
2. Report the branch and commit hash

## Step 4: Deploy to production

### Determine deploy target

Identify the project by checking the current working directory. Look up the matching config file in `~/.claude/skills/deploy/configs/`. Each config file has YAML frontmatter with deploy settings.

1. List files in `~/.claude/skills/deploy/configs/`
2. Match the current directory name to a config's `directory` field
3. Read that config file to get: `ssh_host`, `remote_path`, `pm2_process`, `github_repo`, `url`, `health_port`

To add a new project, create a new `.md` file in `~/.claude/skills/deploy/configs/` with the same frontmatter format.

Use the matched config values for all SSH commands, paths, and URLs below. Replace placeholders:
- `$SSH_HOST` — `ssh_host` from config
- `$REMOTE_PATH` — `remote_path` from config
- `$PM2_NAME` — `pm2_process` from config
- `$GITHUB_REPO` — `github_repo` from config
- `$DEPLOY_URL` — `url` from config
- `$HEALTH_PORT` — `health_port` from config

### 4a. Pull code

```bash
ssh $SSH_HOST "cd $REMOTE_PATH && git pull"
```

If git pull fails due to auth, use:
```bash
TOKEN=$(gh auth token)
ssh $SSH_HOST "cd $REMOTE_PATH && git remote set-url origin 'https://x-access-token:${TOKEN}@github.com/$GITHUB_REPO.git' && git pull && git remote set-url origin 'https://github.com/$GITHUB_REPO.git'"
```

### 4b. Install & Build

```bash
ssh $SSH_HOST "cd $REMOTE_PATH && npm install --legacy-peer-deps && npm run build"
```

If `npm ci` fails with peer dependency errors, use `npm install --legacy-peer-deps` instead.

### 4c. Run pending migrations (if any)

Check for new migration files and run them against the production database.

### 4d. Restart PM2

**CRITICAL: Use user-level PM2, NOT `sudo pm2`.**

```bash
ssh $SSH_HOST "pm2 restart $PM2_NAME"
```

If PM2 shows `errored` status or high restart count, there may be orphan Next.js processes:

```bash
# Check for orphans
ssh $SSH_HOST "ps aux | grep next | grep -v grep"

# Kill orphans if found
ssh $SSH_HOST "pkill -9 -f 'next-server' && pkill -9 -f 'next start'"

# Then restart
ssh $SSH_HOST "pm2 restart $PM2_NAME"
```

### 4e. Post-deploy verification

1. **Health check**: Verify API responds
```bash
ssh $SSH_HOST "curl -s -o /dev/null -w '%{http_code}' http://localhost:$HEALTH_PORT/api/health"
```
Expected: `200`

2. **PM2 status**: Confirm process is stable (online, not errored, not restarting rapidly)
```bash
ssh $SSH_HOST "pm2 list"
```

3. **Static asset verification**: Fetch the deployed page HTML, extract CSS/JS chunk URLs, and verify they all return 200:
```bash
# Extract chunk URLs from the page
curl -s "https://$DEPLOY_URL/" | grep -oE '/_next/static/[^"]+\.(css|js)' | head -5

# Verify each returns 200 (not 400/404)
curl -s -o /dev/null -w "%{http_code}" "https://$DEPLOY_URL/<chunk-url>"
```

If any chunk returns 400 or 404, the build artifacts are stale. The fix is to rebuild:
```bash
ssh $SSH_HOST "cd $REMOTE_PATH && npm run build && pm2 restart $PM2_NAME"
```

Users seeing 400 errors on CSS/JS in their browser just need a hard refresh (Cmd+Shift+R) — this is normal after deploys when the browser has cached old chunk hashes.

4. **Report results** with a summary table:

| Check | Status |
|-------|--------|
| Health API | 200 |
| PM2 status | online |
| CSS chunks | 200 |
| JS chunks | 200 |

### 4f. Visual verification with OpenClaw

After all automated checks pass, verify the deployed change visually using OpenClaw browser automation with the `zenex` profile (which has a logged-in session).

1. **Navigate** to the relevant page on `https://$DEPLOY_URL/` that was changed
2. **Take a snapshot** to confirm the page renders correctly and the change is visible
3. **Report** the visual result to the user as the final deployment artifact

```
Use openclaw_browser tools:
- openclaw_browser_open (profile: zenex)
- openclaw_browser_navigate to the changed page
- openclaw_browser_snapshot to capture the result
```

This is the final deployment gate — the human verifies the artifact in under 10 seconds.
