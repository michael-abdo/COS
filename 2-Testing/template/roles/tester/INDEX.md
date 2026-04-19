# Tester Role Plugin: Index

## Overview

The tester role is responsible for QA test automation, evidence collection, and acceptance criteria verification. All tests are reproducible, evidence-based, and glance-verifiable.

**Core principle:** Test-before-trust. Every change must pass automated verification before handoff.

---

## File Structure

```
tester/
├── plugin.json                          # Plugin manifest (metadata, capabilities)
├── ROLE.md                              # Tester personality, constraints, philosophy
├── PROCEDURES.md                        # Execution workflows (Chrome automation, GIF recording)
├── INDEX.md (this file)                 # Navigation guide
└── skills/                              # Reusable testing patterns
    ├── README.md                        # Skills directory overview
    ├── form-validation-testing.md       # Pattern: automated form validation
    ├── async-assertion-waiting.md       # Pattern: polling for async operations
    └── [future skills]
```

---

## Quick Start

### For a New Tester
1. Read **ROLE.md** (5 min) — Understand tester philosophy, constraints, glance-verifiable standard
2. Read **PROCEDURES.md** (10 min) — Learn Chrome automation, GIF recording, test organization
3. Review **skills/form-validation-testing.md** — See a complete testing pattern with examples

### For Testing a Specific Feature
1. Navigate to the feature's `tests/` directory
2. Read `tests/README.md` — Understand setup, prerequisites, test scenarios
3. Review `tests/test-[name].mmd` — See the test flowchart
4. View `tests/test-[name].gif` — See the recorded evidence
5. Reference **skills/** if you need to add new test patterns

### For Creating a New Skill
1. Read **skills/README.md** — Understand skill organization
2. Copy **skills/form-validation-testing.md** as a template
3. Follow the structure: Setup, Pattern, Example, Reusable Code Snippet
4. Test your skill in a real test scenario before committing

---

## Key Concepts

| Concept | Where to Learn | Key File |
|---------|---|---|
| **Test-Before-Trust** | Core philosophy, decision tree | ROLE.md |
| **Glance-Verifiable** | 10-second rule for all artifacts | ROLE.md → "The Glance-Verifiable Standard" |
| **Chrome MCP Automation** | Step-by-step test execution | PROCEDURES.md → "Chrome MCP Test Automation" |
| **GIF Recording** | How to record test evidence | PROCEDURES.md → "GIF Recording: Workflow and Configuration" |
| **Test Organization** | Where tests live, naming conventions | PROCEDURES.md → "Test File Organization" |
| **Assertion Validation** | Making test results observable | PROCEDURES.md → "Assertion Validation: Making Test Results Observable" |
| **Form Validation Pattern** | Automated form field testing | skills/form-validation-testing.md |
| **Async Waiting Pattern** | Polling for API responses, state changes | skills/async-assertion-waiting.md |

---

## Constraints: Never Ignore These

1. **All test artifacts must be glance-verifiable (10-second rule)**
   - GIF with labels and click indicators
   - Test code is clear and flows logically
   - README explains purpose without reading implementation

2. **No test passes without recorded GIF evidence**
   - GIF must show the complete test sequence
   - Includes both actions (clicks, typing) and results (assertions)
   - Descriptive filename explains what was tested

3. **Every test assertion must be observable in the output**
   - Console logs show `PASS: [specific assertion]` or `FAIL: [expected vs actual]`
   - Never silent passes
   - Failure includes actual value, not just "test failed"

4. **Test files belong alongside implementation, not distant**
   - Feature code at `candidate-profile/profile.py`
   - Tests at `candidate-profile/tests/test-*.mmd` and `test-*.gif`
   - Never: `test-suite/qa/automation/profile-tests/...`

5. **Test failure blocks handoff**
   - If any test fails, do not hand off to production
   - Document failure in `tests/README.md`
   - Root-cause the failure before re-testing
   - No "probably works" states

---

## Workflows by Scenario

### Scenario 1: Testing a New Feature

**Goal:** Verify feature works as spec'd before handoff.

**Steps:**
1. Create `feature-folder/tests/` directory
2. Write test definition: `test-[feature].mmd` (flowchart of test steps)
3. Start Chrome automation and recording: `gif_creator(action='start_recording')`
4. Execute test steps via Chrome MCP (click, fill, submit)
5. Add observable assertions: `console.log('PASS: Status changed')`
6. Stop recording: `gif_creator(action='stop_recording')`
7. Export GIF with full visibility: `gif_creator(action='export', options={...})`
8. Save GIF to `tests/test-[feature].gif`
9. Create `tests/README.md` with setup, steps, expected result
10. Hand off with all artifacts linked

### Scenario 2: Regression Testing (Existing Feature)

**Goal:** Verify nothing broke in a feature someone else changed.

**Steps:**
1. Navigate to feature's `tests/` directory
2. Read `README.md` for setup instructions
3. Follow setup steps (seed data, login, etc.)
4. Re-run test via Chrome automation and GIF recording
5. If test passes: hand back to developer with GIF as proof
6. If test fails: document failure, identify root cause, request fix

### Scenario 3: Flaky Test (Passes Sometimes, Fails Sometimes)

**Goal:** Debug and fix non-deterministic test behavior.

**Steps:**
1. Run test 5 times in a row
2. Capture failures with full GIF and console logs
3. Common causes: timing issues (use async-assertion-waiting skill), data inconsistency, race conditions
4. If timing: increase timeout in waitFor() or add polling
5. If data: ensure test setup is idempotent (runs the same every time)
6. If race condition: add synchronization (wait for state before proceeding)
7. Re-test 5 more times to confirm fix
8. Only consider fixed when 100% consistent

---

## FAQ

### What makes a test "glance-verifiable"?

A test artifact is glance-verifiable if a reviewer can understand what was tested and whether it passed in 10 seconds, without running code or reading documentation.

**Example: Good**
- GIF named `test-candidate-status-pipeline.gif` with click indicators and action labels
- Final frame shows "Status: interview" on screen
- Console shows `PASS: Status changed from cold to interview`

**Example: Bad**
- GIF with no labels, filename `test1.gif`
- No assertion visible, just a series of clicks
- Reviewer must run test themselves to understand what passed

### Do I need to test every feature?

Yes. Before handoff, every feature must have:
- At least one test covering the happy path (user succeeds)
- At least one test covering a common error case (user makes a mistake, sees error message)
- All tests recorded as GIFs with assertions visible

### Can I test manually instead of automating?

Only if automation is impossible. Manual testing is:
- Slow (human must repeat steps each time)
- Unreliable (human makes mistakes)
- Not reproducible (next person can't re-run it)

Prefer Chrome MCP automation + GIF recording. It's reproducible and fast.

### What if a feature is too complex to test in one GIF?

Split it into multiple tests. Each test covers one scenario:
- `test-create-candidate.gif` (just form fill + submit)
- `test-candidate-status-update.gif` (status change)
- `test-bulk-import.gif` (import CSV)

Each has its own GIF, test code, and assertion. Multiple small tests beat one massive test.

### How long should a test take to run?

Most tests: 2–10 seconds (Chrome automation is fast)
Complex workflows: up to 30 seconds
Deployment tests: 30–120 seconds

If a test takes >2 minutes, split it into smaller tests.

### Can I re-use test code from another feature?

Yes, use the skills framework. If your feature has the same pattern as `form-validation-testing`, reference that skill in your test file:

```markdown
# Candidate Form Validation Test

This test uses the **form-validation-testing** skill from `/roles/tester/skills/`.

Setup: [specific to this feature]
Test: [adapt form-validation pattern to this form]
```

---

## Editing This Plugin

- **plugin.json:** Update version, description, capabilities when adding features
- **ROLE.md:** Update personality, constraints, examples when refining the philosophy
- **PROCEDURES.md:** Add new workflows as they emerge (new testing patterns, tools)
- **skills/:** Create new skill files as you discover reusable testing patterns

All changes should maintain AEO formatting (40-60 word summaries, answer-first, 3+ domain examples).

---

## Related Files

- **CLAUDE.md** (at repo root) — Project-wide standards (AEO formatting, diagram rules, MCP setup)
- **OLD CLAUDE.md** (reference) — Original QA Testing section, extracted into this plugin
- **communicator role** (sibling plugin) — Complementary role for message verification
