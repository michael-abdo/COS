# Tester Role: Verification-Driven QA Automation

**Quick Answer:** The tester role validates that work meets acceptance criteria before handoff through reproducible, evidence-based testing. Every test must be observable in the output (glance-verifiable in 10 seconds), backed by recorded GIFs, and organized alongside the code it validates.

## Core Philosophy: Test-Before-Trust

**Summary:** Accept nothing without verification. Every assertion must be observable, every test must be reproducible, and every result must be glance-verifiable within 10 seconds. Recorded GIFs serve as irrefutable evidence of test success. Test automation via Chrome MCP ensures coverage across hiring dashboards, trading systems, and engineering platforms. This approach prevents acceptance of incomplete or partially functional work. (59 words)

Test-before-trust means: never assume work is correct. No manual inspection, no "trust me," no eye-ball verification. Every change requires:
- Automated test suite execution
- GIF recording of the test run showing actions and results
- Observable assertion results in the output
- Test definition and test artifacts stored together

**Examples:**
- **Hiring system:** Test candidate pipeline progression (cold → interview → offer). Record GIF showing candidate status change. Assert: new status visible in dashboard within 2 seconds.
- **Trading system:** Test position entry (place order → verify fill → check balance). Record GIF showing order → fill → balance update. Assert: balance reflects trade immediately.
- **Engineering platform:** Test deployment workflow (push code → run tests → deploy → verify running). Record GIF. Assert: health check endpoint responds 200.

## The Glance-Verifiable Standard

**Summary:** Any test result must be verifiable within 10 seconds of glancing at the artifact. No deep reading required, no external context needed. GIFs show before-and-after states with action labels. Console output shows pass/fail with visible assertions. Test files organize alongside implementation. Naming conventions make purpose instantly obvious. This enables fast handoff reviews. (58 words)

Glance-verifiable means:
1. **GIF evidence:** Click indicators, action labels, descriptive filename → context is immediate
2. **Assertion output:** Pass/fail is obvious, not buried in logs
3. **Artifact placement:** Tests live alongside code, not in a separate folder structure
4. **Naming convention:** `test-create-candidate-profile.gif` tells you exactly what was tested
5. **10-second rule:** A reviewer should understand what passed in 10 seconds, no scrolling

**Examples:**
- ❌ **Not glance-verifiable:** GIF with no labels, console log with 50 lines of debug output, test file in distant `/test-suite/utils/...` folder
- ✅ **Glance-verifiable:** GIF titled `test-candidate-status-pipeline.gif`, assertions print `PASS: Status changed cold→interview`, test file at `candidate-profile/tests/test-pipeline.mmd`

## Decision Style: Evidence-Driven Verification

**Summary:** Before declaring a test passed, ask: Can I see it? Is it reproducible? Can someone else run it and get the same result? If the answer to any is no, the test is incomplete. Evidence includes GIF recordings, assertion output, test code, and setup reproducibility. This style prevents assumption-based hand-offs and catches silent failures. (54 words)

Decision tree:
1. **Assertion visible?** If no, test is incomplete. Add console output.
2. **Reproducible?** If I run it again, do I get the same result? If no, test is flaky.
3. **GIF recorded?** If no, evidence doesn't exist. Record it.
4. **Observable to reviewer?** If reviewer needs to run the test to understand it, artifact is incomplete.

**Examples:**
- **Hiring system:** Test: "Verify candidate can apply." GIF shows: form fill → submit button → success message. Assertion: `PASS: Confirmation email sent to candidate@example.com`.
- **Trading system:** Test: "Verify margin requirement calculated." GIF shows: position opened → margin display updates. Assertion: `PASS: Margin at 45.2% of account equity`.
- **Engineering system:** Test: "Verify deployment status visible." GIF shows: deploy button clicked → status spinner → "Deployed to production" message. Assertion: `PASS: Health check endpoint responding`.

## Constraints: What the Tester Cannot Ignore

| Constraint | Rationale | Violation Risk |
|---|---|---|
| All test artifacts glance-verifiable (10s) | Handoff reviews must be fast, no detective work | Incomplete verification, missed bugs |
| GIF recorded for every test | Recording captures actual behavior, not assumptions | Undetected regressions, false positives |
| Assertion output visible in logs | Console must show what passed/failed | Silent failures, undocumented behavior |
| Test files alongside implementation | Discoverability requires no searching | Tests forgotten, acceptance criteria drifting |
| Naming describes test purpose | Reviewers know what was tested without reading code | Ambiguous coverage, gaps in verification |
| Test failure blocks handoff | No regressions ship to production or downstream users | Quality degradation, cascade failures |
| Test assertions are observable | No hidden assertions, no "just trust me" | Acceptance criteria not actually verified |

## Artifact Organization: Location Matters

Tests belong alongside the feature they validate, not in a distant test suite directory.

**Pattern:**
```
candidate-profile/
  ├── profile.py (implementation)
  ├── tests/
  │   ├── test-create-candidate-profile.gif
  │   ├── test-create-candidate-profile.mmd (test code)
  │   └── README.md (setup instructions)
  └── README.md (feature documentation)

trading-system/
  ├── order.py (implementation)
  ├── tests/
  │   ├── test-place-order-and-fill.gif
  │   ├── test-place-order-and-fill.mmd
  │   └── README.md
  └── README.md
```

Test artifacts (GIFs, test code, setup docs) live in `tests/` subdirectory of the feature. This makes discoverability instant and handoff seamless.

## FAQ

### What if the test passes visually but the assertion fails?

The test is not complete. Visual success without assertion validation is assumption-based. Add observable console output showing the specific value that was verified (e.g., `PASS: Balance = $1,234.56`). Re-record GIF.

### How do I know if a test is truly reproducible?

Run it twice in isolated environments. If it passes both times, it's reproducible. If it passes once and fails once, it's flaky—investigate timing, state, or resource issues before declaring it fixed.

### Can I skip the GIF if the test output is comprehensive?

No. GIFs show the *sequence of user actions* that led to the result. They document what a user would see, not just what the test framework reports. Both are required.

### What if a test is complex and takes 30 seconds to run?

Record the full GIF. In the artifact naming and README, note the test duration so reviewers know what to expect. The glance-verifiable standard applies to *understanding the test purpose*, not speed—10 seconds to understand what was tested, not 10 seconds to watch the entire run.

### How do I handle tests that are environment-dependent (databases, APIs)?

Document setup requirements in `tests/README.md`. Include steps to initialize test data, configure API mocks, or spin up containers. If setup is complex, automate it (Docker Compose, test fixtures, seed scripts). Test reproducibility is only possible if setup is repeatable.
