# COS L2-L5 Concern Pairs — User Level

**All L2 Concerns at user/business abstraction level (what could go wrong in actual work) paired with L5 Tests (binary acceptance criteria).**

---

## User-Level L2 Concerns: Hiring Domain

### H-1: Wrong Candidates Advance
**L2 Concern:** What if you apply to roles you're actually unqualified for, waste time, and damage reputation?  
**L5 Test:** Before application: role-qualification tier is ≥40% match (demonstrated by 3+ of 5 required skills). Application passes screening OR feedback explains specific misalignment. 0 rejections due to "lacks core skills."

### H-2: No Signal to Distinguish Success
**L2 Concern:** What if you can't tell whether an application approach is working or failing?  
**L5 Test:** After 10 applications: (1) pass-to-screening rate is measurable (target: 20%+), (2) screening-to-interview rate is clear, (3) interview-to-offer rate is tracked. Can you show week-over-week improvement or stagnation?

### H-3: Same Failed Approach Repeated
**L2 Concern:** What if you keep applying the same way despite consistent rejections?  
**L5 Test:** After 3 consecutive rejections with same reason, application strategy changes measurably (different hook, different role level, different company type). Next 3 applications use new approach. Measure: 0 repeated rejection patterns.

### H-4: Opportunities Lost to Timing
**L2 Concern:** What if you escalate too late—candidate loses interest, company fills role, deadline passes?  
**L5 Test:** Response time SLA: ≤24h to close-ended messages, ≤48h to information requests. Interview follow-up within 24h. Offer decision within 48h. Measure: 0 lost opportunities due to slow response.

### H-5: Proposing Overqualified/Underqualified Candidate
**L2 Concern:** What if resume positioning alienates the hiring team (too junior or too senior for the role)?  
**L5 Test:** Resume for role tier X emphasizes: (1) achievements at tier X level, (2) growth trajectory consistent with role, (3) specific evidence of tier X skills. Hiring team feedback: "right level for this role." 0 rejections for tier misalignment.

### H-6: Knowledge About Roles Becomes Stale
**L2 Concern:** What if you apply outdated knowledge about what companies want, missing market shifts?  
**L5 Test:** Every 4 weeks: sample 5 job postings from target companies, extract 3 emerging skill requirements not in your KB. Update KB with new signals. Measure: top 5 required skills change week-over-week (pattern updates monthly).

---

## User-Level L2 Concerns: Systems Engineering Domain

### S-1: Silent Failures Cascade Undetected
**L2 Concern:** What if a system failure appears only at user level (timeouts, 500 errors), but your monitoring doesn't catch the root cause?  
**L5 Test:** For every user-visible failure type, trace back to specific resource metric (CPU spike, disk full, memory leak, network latency). Alert fires ≥30min before user impact. Measure: 0 silent failures; all failures caught by monitoring first.

### S-2: Mitigation Creates Worse Problem
**L2 Concern:** What if you increase retries to handle timeouts, but create retry storms that take down the system?  
**L5 Test:** Before deploying any mitigation (retry config, cache size, load balancer threshold), model second-order effects. Test on staging with realistic load. Measure: no incidents caused by deployed mitigations.

### S-3: Risk Model Applied Inconsistently
**L2 Concern:** What if you escalate some HIGH-blast-radius changes but push others through without approval?  
**L5 Test:** 100% of production changes rated by 6-Factor model. HIGH blast radius OR LOW reversibility → human approval logged. Decision audit: show that identical-risk changes always follow same escalation path.

### S-4: Cascade Assumptions Unvalidated
**L2 Concern:** What if you assume a failure in system A won't affect system B, but the dependency is hidden?  
**L5 Test:** Dependency map exists and is validated quarterly. Every mitigation documents affected systems. Staging tests with realistic inter-system load. Measure: 0 cascades from undocumented dependencies.

### S-5: Expertise Gaps Leave Blind Spots
**L2 Concern:** What if you don't know distributed consensus is broken until it fails in production?  
**L5 Test:** For each system layer (compute, OS, network, storage, distributed, DevOps, observability), KB lists ≥3 known failure modes + ≥1 known unknown. Blind spots are explicit. Measure: all layer-specific unknowns investigated within 3 months.

### S-6: Learning Stopped After Initial Fix
**L2 Concern:** What if you fix an incident but never update KB, so the team repeats it 6 months later?  
**L5 Test:** Post-incident: failure mode added to KB with tier=KNOWN, mitigation added, alert configured. Next similar incident gets faster resolution (halved MTTR). Measure: 0 identical incidents 6+ months apart.

---

## User-Level L2 Concerns: Trading Domain

### T-1: Position Blowup Undetected
**L2 Concern:** What if a position breaches risk limits (max drawdown, margin requirement) without triggering a kill-switch?  
**L5 Test:** Real-time monitoring: position size, leverage, daily P&L, margin ratio all polled ≥every 60s. Kill-switch executes within 30s of breach. Measure: 0 positions exceed risk limits by >10%.

### T-2: Edge Case Assumptions Hidden
**L2 Concern:** What if your trading strategy works great in normal markets but breaks at 4pm (option expiry), earnings, or gap days?  
**L5 Test:** Strategy KB lists market conditions: normal volatility, low volume, earnings week, option expiry, gaps. For each condition, documented entry/exit rules. Backtested separately across all conditions. Measure: strategy performs within 20% of mean across all conditions.

### T-3: Correlation Assumptions Fail
**L2 Concern:** What if two assets you thought move together suddenly diverge (hedge fails)?  
**L5 Test:** Before deploying any hedge (e.g., long ES, short QQQ), analyze correlation history: normal, stress, crisis periods. Documented max divergence. Stop-loss configured for tail scenarios. Measure: 0 unexpected hedge losses >predicted max divergence.

### T-4: Overoptimization on Historical Data
**L2 Concern:** What if your strategy worked great on 2023 data but fails on new market regime?  
**L5 Test:** Strategy tested on: (1) in-sample data, (2) out-of-sample data, (3) forward test on live data. Out-of-sample performance reported separately. Measure: live performance within 80% of backtest; if not, strategy is rejected or rebuilt.

### T-5: Risk Limits Silently Exceeded
**L2 Concern:** What if you're supposed to take max 2% heat per trade but are actually taking 3%—slippage and execution costs hidden?  
**L5 Test:** Trade log records: intended position size, actual size (after slippage/fills), P&L (realized), risk taken (actual vs. planned). Weekly audit: actual risk vs. stated policy. Measure: 95%+ of trades within policy, outliers documented with reason.

### T-6: System Downtime Causes Blind Loss
**L2 Concern:** What if your trading system goes down mid-trade—position orphaned, cannot exit, gap against you?  
**L5 Test:** Kill-switch exists outside main system (manual, broker-level, or hardware failover). Tested monthly. Position monitoring runs independent of execution system. Measure: 0 gaps from system failures; all positions exited within 30s of detection.

---

## User-Level L2 Concerns: Cross-Domain

### X-1: Automated System Trusted Too Early
**L2 Concern:** What if you deploy an agent that runs autonomously, makes decisions you later discover were wrong, and you can't undo 50 bad actions?  
**L5 Test:** Agent runs in sandbox/low-stakes mode first (apply to 5 test roles, trade $100, change 1 file). Only after ≥95% human-approval rate across 10+ actions, escalate to autonomous. Measure: rollback possible for all autonomous batches until confidence=PROVEN.

### X-2: Evidence Confuses Correlation With Causation
**L2 Concern:** What if you conclude "X causes Y" from observation, then apply that wrong assumption at scale?  
**L5 Test:** Before making decisions on claimed causation (e.g., "warm intro causes response"), run isolated test: change ONLY that variable, hold all else constant. Evidence records: hypothesis → test → result. Measure: 0 deployed decisions based on unvalidated causation.

### X-3: Knowledge Base Drives Wrong Decisions
**L2 Concern:** What if your KB says "Pattern X always fails" but that's outdated—market changed, you changed, context shifted?  
**L5 Test:** Monthly audit: for each KNOWN pattern, pull 5 recent examples. Do they still hold? If <80% match, demote tier or mark conditional. Measure: 0 decisions driven by stale KNOWN patterns; all patterns reviewed quarterly.

### X-4: Tier Confusion Scales Failures
**L2 Concern:** What if you marked something KNOWN on just 2 instances, scaled to 100 actions, and they all fail?  
**L5 Test:** Tier audit: GUESSED claims have ≥2 instances, SUSPECTED ≥5 across contexts, KNOWN ≥10 across contexts, PROVEN ≥100. Pick random KNOWN entry, verify data. Measure: 100% tier audit passes; no stale over-promoted patterns.

### X-5: Blind Risk Escalation
**L2 Concern:** What if HIGH-risk decisions are made without explicit approval, because risk model wasn't run?  
**L5 Test:** Every decision ≥ medium scope gets 6-Factor assessment. HIGH blast radius + LOW reversibility → escalation gate (must log decision + approval). Audit: sample 20 decisions, verify all with HIGH/LOW factors are logged. Measure: 100% of risky decisions have explicit records.

### X-6: Learning Discipline Breaks, Nothing Improves
**L2 Concern:** What if you execute consistently but never close the feedback loop—each batch of actions is isolated, patterns never emerge?  
**L5 Test:** Weekly review: for every metric (success rate, time-to-X, cost-per-action), compare this week vs. last week. At least 1 metric should trend positive, or 1 KB pattern should shift tier. Measure: 0 flat weeks; system demonstrates learning ≥every 2 weeks.

---

## Summary: User-Level Threats

| Domain | Key User Threats |
|--------|---|
| **Hiring** | Wrong roles, no progress signal, repeated failures, slow response, wrong positioning, stale knowledge |
| **Systems** | Silent failures, mitigation cascades, inconsistent risk, hidden dependencies, expertise gaps, no learning |
| **Trading** | Undetected blowup, edge cases, hedge failure, overoptimization, risk creep, system downtime |
| **Cross-Domain** | Agent trusted too early, correlation→causation confusion, stale KB, tier overpromotion, blind risk, broken learning |

**Total: 24 L2 Concerns (user/business level) paired with 24 L5 Tests (measurable outcomes)**

Each test answers: "Did this threat actually get prevented or mitigated?" Binary: PASS or FAIL.
