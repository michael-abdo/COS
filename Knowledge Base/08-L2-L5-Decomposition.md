# L2-L5 Decomposition: From Concern to Verifiable Outcome

**Quick Answer:** Convert fuzzy requests into binary tests. L2 states the threat ("what could go wrong?"), L3 defines the invariant ("always X"), L4 specifies failure mode (logical NOT), L5 proposes a testable outcome with a concrete artifact.

## The Five Levels

**Summary:** L2-L5 decomposition transforms vague concerns into binary acceptance criteria. L2 is the business worry; L3 is the rule that prevents it; L4 describes failure logically; L5 is the test (artifact + acceptance rule). The artifact must be glance-verifiable in 10 seconds—something human can see and say "yes" or "no" without interpretation. This prevents "I updated X" claims and replaces them with visible proof. (63 words)

| Level | Definition | Example (Hiring) | Example (Trading) |
|-------|-----------|------------------|-------------------|
| **L2: Concern** | What could go wrong? (Business threat) | "What if I apply to roles I'm unqualified for and damage my reputation?" | "What if a position breaches risk limits undetected?" |
| **L3: Intent** | What invariant prevents the threat? (Universal rule: Every/All/Always X has Y) | "Every application hits ≥3 of 5 required signals for the role tier" | "All open positions are monitored for margin ratio ≥200% at all times" |
| **L4: Failure** | Logical NOT of Intent (When does the rule break?) | "Some applications hit <3 signals and still advance" OR "Feedback explains misalignment" | "Position margin ratio drops <200%" OR "Margin breach goes undetected >60s" |
| **L5: Test** | Binary acceptance criterion (Artifact + rule) | "Application rejected OR hired team confirms ≥3 signals evident. Artifact: hiring manager feedback." | "Position monitoring alert fires within 30s of breach. Artifact: alert log + position snapshot." |

## Step-by-Step Decomposition

### Step 1: State L2 Concern
Restate request as "what could go wrong?"

**Bad:** "Improve the resume"
**Good:** "What if resume gets rejected due to missing signals that matter to target roles?"

### Step 2: Derive L3 Intent
What universal rule prevents the threat? Must be: Every/All/Always X has Y (not "try hard" or "be careful").

**Bad:** "Resume should be good"
**Good:** "Every resume for tier-X roles must hit ≥3 of 5 critical signals"

### Step 3: Derive L4 Failure
Logical NOT of the rule. Mechanical, not creative.

**Bad:** "Resume is bad"
**Good:** "Resumes hit <3 signals OR hiring team says 'missing what matters'"

### Step 4: Propose L5 Test
Binary: "If THIS is true, concern resolved." One sentence. Includes artifact.

**Bad:** "Resume is better"
**Good:** "New resume sent to 5 hiring managers across target companies. ≥3 confirm ≥2 of 3 critical signals evident. Artifact: email feedback from hiring managers."

### Step 5: Name the Artifact
What will human see to verify? Concrete: screenshot, PDF, email, dashboard, query result, test output. NOT: "code", "status report", "I updated X".

**Bad artifact:** "Resume updated"
**Good artifact:** "Email responses from 5 hiring managers showing feedback"

### Step 6: Apply 10-Second Rule
Can human glance for 10 seconds and verify? If no, reframe.

**Bad:** Email thread 50 messages long (requires reading)
**Good:** Screenshot of 5 manager quotes with their names and date (glanceable)

### Step 7: Get Validation
Present L2/L3/L5 + artifact. Wait for approval before executing.

## Examples Across Domains

### Recruiting: Resume Positioning

| Level | Content |
|-------|---------|
| **L2** | What if resume positioning alienates the hiring team (too junior or too senior)? |
| **L3** | Every resume for role tier X must emphasize achievements at tier X level + growth trajectory consistent with role |
| **L4** | Resume emphasizes tier X+2 achievements OR hiring team feedback says "overqualified" OR "too junior" |
| **L5** | Resume sent to 3 hiring managers for tier X role. Feedback: "Right level for this role" OR explicit tier feedback provided. Zero rejections for tier misalignment. Artifact: 3 manager feedback emails with tier assessment. |

**10-second rule check:** ✅ Yes. Human reads 3 feedback lines, sees "2/3 say 'right level'" → concern resolved.

### Systems: Silent Failure Detection

| Level | Content |
|-------|---------|
| **L2** | What if a system failure appears only at user level (timeouts) but monitoring misses the root cause? |
| **L3** | For every user-visible failure type, there exists a specific resource metric that precedes user impact by ≥30min |
| **L4** | User-visible failure occurs before monitoring detects root cause cause OR no alert fires before impact |
| **L5** | For each failure type (timeout, 500 error, latency spike), trace to resource metric. Alert fires ≥30min before user impact. Artifact: alert log + timeline showing detection time vs. user impact time. |

**10-second rule check:** ✅ Yes. Human sees timeline: metric alert 2:15pm, user errors 2:47pm → confirmed.

### Trading: Hedge Failure Risk

| Level | Content |
|-------|---------|
| **L2** | What if two assets you thought move together suddenly diverge (hedge fails)? |
| **L3** | Before deploying any hedge, correlation history is documented across normal, stress, and crisis market periods, with max divergence quantified |
| **L4** | Hedge deployed without documented correlation analysis OR hedge loss exceeds predicted max divergence |
| **L5** | Hedge strategy: ES long, QQQ short. Correlation analysis shows: normal period (0.95), stress period (0.80), crisis (0.40). Max divergence: 2 ES points. Stop-loss set at 3 points. Artifact: correlation report + trade log showing stop execution within max divergence. |

**10-second rule check:** ✅ Yes. Human sees correlation table + trade log showing "stopped at 2.5 points, within 3-point max" → verified.

## FAQ

**Q: What if the concern is vague ("make it better")?**
A: Reject it. Request concrete L2: "What specifically could go wrong?" Vague concerns can't reach L5.

**Q: Can L5 have multiple tests (OR)?**
A: Yes. "Resume accepted OR feedback explains misalignment" is valid. But each OR branch must be binary and glance-verifiable.

**Q: What if L3 feels too strict?**
A: Good. Intent should be strict. If it feels loose ("try hard to apply to relevant roles"), reframe: "What's the minimum bar?" That's your L3.

**Q: When do I use L2-L5?**
A: Before creative work, features, or decisions. Especially when: request is fuzzy, "done" is undefined, or you're uncertain about success criteria.
