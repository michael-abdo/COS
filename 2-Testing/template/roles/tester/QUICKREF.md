# Tester Role: Quick Reference Card

## One-Page Cheatsheet for QA Test Automation

### Core Rule
**Test-before-trust:** Never accept work without automated, reproducible, evidence-based verification.

---

## Test Creation Checklist

### Step 1: Create Test Directory
```bash
mkdir -p feature-folder/tests/
cd feature-folder/tests/
```

### Step 2: Write Test Definition
Create `test-[scenario].mmd` (Mermaid flowchart):
```
START → Action 1 → Action 2 → Assert → PASS/FAIL
```

### Step 3: Automate with Chrome MCP
```javascript
// 1. Launch browser
mcp__claude-in-chrome__tabs_context_mcp(createIfEmpty=true)

// 2. START RECORDING
gif_creator(action='start_recording', tabId=<tab>)

// 3. Execute test steps
navigate(url='...', tabId=<tab>)
left_click(ref=<button>, tabId=<tab>)
type(text='...', tabId=<tab>)

// 4. Add observable assertions
javascript_tool(action='javascript_exec', 
  text='console.log("PASS: Status changed")', tabId=<tab>)

// 5. STOP RECORDING
gif_creator(action='stop_recording', tabId=<tab>)

// 6. EXPORT
gif_creator(action='export', tabId=<tab>, download=true,
  filename='test-scenario.gif',
  options={'showClickIndicators': true, 'showActionLabels': true})
```

### Step 4: Create Setup Documentation
`tests/README.md`:
```markdown
# Test: [Feature Name]

## Setup
- Prerequisites (databases, logins, seed data)
- Commands to run before test (./scripts/seed-data.sh)

## Steps
1. Navigate to feature
2. [Action]
3. [Action]
...

## Expected Result
[Specific observable result]

## Evidence
See: test-scenario.gif
```

### Step 5: Verify Glance-Verifiable
✓ Filename describes test: `test-candidate-status-update.gif`
✓ GIF shows click indicators (orange circles)
✓ GIF shows action labels (black text)
✓ Final frame shows assertion result (console log or UI state)
✓ All three artifacts present:
  - `test-scenario.mmd` (test code)
  - `test-scenario.gif` (recorded evidence)
  - `README.md` (setup + instructions)

---

## GIF Recording Configuration

```json
{
  "showClickIndicators": true,    // Orange circles at click locations
  "showActionLabels": true,        // Black labels: "Click", "Type search"
  "showDragPaths": true,           // Red arrows for drag sequences
  "showProgressBar": true,         // Orange progress bar at bottom
  "showWatermark": false,          // Hide Claude watermark
  "quality": 10                    // High quality (1=best, 30=worst)
}
```

---

## Assertion Examples

### Good (Observable)
```javascript
console.log('PASS: Status changed to interview');
console.log('FAIL: Status is cold, expected interview');
console.log('PASS: Balance updated to $1234.56');
```

### Bad (Hidden)
```javascript
console.log('Test passed');  // Too vague
console.log('OK');           // Ambiguous
// Silent pass (no output at all)
```

---

## Async Operations (Polling Pattern)

```javascript
// Helper
function waitFor(predicate, timeoutMs = 5000) {
  return new Promise((resolve, reject) => {
    const start = Date.now();
    const check = setInterval(() => {
      try {
        if (predicate()) {
          clearInterval(check);
          resolve();
        }
      } catch (e) {}
      if (Date.now() - start > timeoutMs) {
        clearInterval(check);
        reject(new Error('Timeout'));
      }
    }, 100);
  });
}

// Usage
const status = document.querySelector('[data-test=status]');
button.click();
waitFor(() => status.textContent === 'interview', 5000)
  .then(() => console.log('PASS: Status updated'))
  .catch(() => console.log('FAIL: Status never updated'));
```

---

## File Organization Pattern

```
feature-folder/
├── implementation.py         (feature code)
├── README.md                 (feature docs)
└── tests/
    ├── README.md             (setup + test overview)
    ├── test-scenario-1.mmd   (test flowchart)
    ├── test-scenario-1.gif   (recorded evidence)
    ├── test-scenario-2.mmd
    └── test-scenario-2.gif
```

**Never:** `test-suite/qa/feature-tests/...` (tests must be discoverable)

---

## Naming Convention

| Artifact | Pattern | Example |
|----------|---------|---------|
| GIF | `test-[feature]-[scenario].gif` | `test-candidate-pipeline.gif` |
| Test code | `test-[feature]-[scenario].mmd` | `test-candidate-pipeline.mmd` |
| Setup docs | `README.md` | `tests/README.md` |

---

## Common Test Timeouts

| Operation | Timeout |
|-----------|---------|
| DOM update (click → element appears) | 500ms |
| Form submission → API response | 2–5 sec |
| Status broadcast → UI update | 1–2 sec |
| Database write → query result | 2–5 sec |
| Deployment → health check | 30–60 sec |

---

## Debugging Failed Tests

1. **Does the element exist?**
   ```javascript
   console.log('Element:', document.querySelector('[data-test=status]'));
   ```

2. **What's the current value?**
   ```javascript
   console.log('Status:', element.textContent);
   ```

3. **Is it visible?**
   ```javascript
   console.log('Display:', window.getComputedStyle(element).display);
   ```

4. **Increase timeout**
   ```javascript
   waitFor(() => condition, 10000)  // 10 seconds instead of 5
   ```

5. **Add polling logs**
   ```javascript
   waitFor(() => {
     console.log('Polling... status:', element.textContent);
     return element.textContent === 'interview';
   }, 5000)
   ```

---

## Test Failure → Root Cause Analysis

Don't just re-run. Diagnose:

| Failure | Root Cause | Fix |
|---------|-----------|-----|
| Test passes/fails randomly | Race condition, timing | Use async-assertion-waiting skill |
| Always fails | Code bug or test data issue | Fix code or seed data differently |
| Passes locally, fails in CI | Environment difference | Document in tests/README.md |
| Works once, times out next | State pollution | Reset database/cache between tests |

---

## Skills You Can Use

| Skill | Use When |
|-------|----------|
| **form-validation-testing** | Testing forms, required fields, validation errors |
| **async-assertion-waiting** | Waiting for API responses, status changes, broadcasts |

See `skills/` directory for full implementations.

---

## Emergency Checklist: "Test Doesn't Work"

1. ✓ Does the element exist? (`querySelector`)
2. ✓ Is the element visible? (`offsetHeight > 0`)
3. ✓ Did the action execute? (check click indicator in GIF)
4. ✓ Is assertion reaching the right element? (console log the selector)
5. ✓ Does test data exist? (seed database before test)
6. ✓ Is timeout long enough? (increase from 5s to 10s)
7. ✓ Is environment set up? (follow tests/README.md)

If all ✓ and still broken → ask for help (this is a real bug)

---

## Key Files

- **ROLE.md** — Personality, philosophy, constraints
- **PROCEDURES.md** — Detailed workflows, GIF recording, test organization
- **INDEX.md** — Navigation guide, quick-start paths
- **skills/form-validation-testing.md** — Form testing patterns
- **skills/async-assertion-waiting.md** — Async operation patterns

---

## Contact

This role was extracted from OLD CLAUDE.md QA Testing section (2026-04-18).

For questions about testing patterns, see INDEX.md → FAQ or ROLE.md → FAQ.
