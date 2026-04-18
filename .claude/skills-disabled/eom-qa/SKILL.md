---
name: eom-qa
description: QA gate for VVG monthly EOM consolidated report emails. Downloads XLSX and PDF attachments from Outlook, parses the email HTML body, and cross-compares all three data sources to catch mismatches in review counts, ratings, star buckets, and per-location breakdowns. Use this skill whenever the user mentions EOM QA, monthly report QA, checking monthly emails, verifying EOM reports, or wants to validate that the consolidated monthly digest emails have consistent data across email body, XLSX, and PDF attachments. Also trigger when the user says "qa the eom", "check the monthly reports", or "verify the digests".
user-invocable: true
---

# EOM Report QA — Cross-Source Data Verification

This skill verifies that the three data sources in each consolidated monthly report email are internally consistent. A mismatch means a bug in the generation pipeline.

## The Three Sources

Each EOM email contains three representations of the same data:

| Source | Where | What to Extract |
|--------|-------|-----------------|
| **Email Body** | HTML content via messages_get | 4 stat card values only: Reviews, Avg Rating, 1-2 Star, 3-5 Star |
| **XLSX** | `reviews_*.xlsx` attachment | Row counts, ratings, per-address groupings (the ground truth) |
| **PDF** | `location_rankings_*.pdf` attachment | Location table + summary footer (read visually) |

### Parsing Reality

The Outlook API returns mangled HTML where inline styles are stripped. Reliably extracting only the **4 stat card values** from the email body is feasible. The location breakdown table in the email body CANNOT be reliably parsed from stripped HTML — address numbers blend with stat numbers. Use the **PDF** (read visually) as the location-level source instead.

## QA Checks

### Check 1: Total Review Count (3-way)
- Email body stat card "Reviews" number
- XLSX: count all data rows across Positive + Negative sheets
- PDF: sum the "Reviews" column across all locations
- **All three must match exactly.**

### Check 2: Star Bucket Counts (3-way)
- **1-2 Star**: Email body card == XLSX rows with Rating ≤ 2 == PDF total 1-2 Star
- **3-5 Star**: Email body card == XLSX rows with Rating ≥ 3 == PDF total 3-5 Star
- **Must match exactly.**

### Check 3: Average Rating (2-way + known divergence)
- Email body "Avg Rating" stat card
- XLSX: simple average of all Rating values, rounded to 1 decimal
- **These two MUST match** (both use simple average).
- PDF uses "average of per-location averages" — a different calculation. Flag the difference but **do NOT fail** on this. Report as: `ℹ️ KNOWN DIVERGENCE: PDF uses avg-of-avgs method`

### Check 4: Per-Location Review Counts (2-way: PDF vs XLSX)
- PDF: each location row has a review count
- XLSX: group rows by Address column, count per group
- Each location's PDF count must match XLSX address grouping count.
- Report mismatches with location, PDF count, XLSX count.

### Check 5: Location Count (2-way: PDF vs XLSX)
- PDF header: "X Locations"
- XLSX: count unique addresses with reviews
- Should match.

## Execution Steps

### Step 1: Fetch Emails

Use `mcp__universal__messages_search`:
- query: `"Monthly Customer Feedback Summary"`
- account: `vvg`
- days: 7 (adjust if user specifies a range)
- limit: N (user specifies, default 5)

Skip any "FW:" forwarded messages — those are bundles, not individual reports.

### Step 2: For Each Email

**2a. Get full message** via `mcp__universal__messages_get` with platform_message_id, account=vvg, platform=outlook.

**2b. Extract email body stats** using `scripts/parse_email_body.py`:
```bash
python3 scripts/parse_email_body.py <<< "$HTML_CONTENT"
```
This extracts: total_reviews, avg_rating, one_two_star, three_five_star, subscriber name.

**2c. List attachments** via `mcp__universal__download_attachment` with just message_id + platform=outlook + account_id=vvg (no file_id = list mode).

**2d. Download XLSX and PDF** — find the `.xlsx` and `.pdf` attachments, download each to `/tmp/eom-qa/`.

**2e. Parse XLSX** using `scripts/parse_xlsx.py`:
```bash
python3 scripts/parse_xlsx.py /tmp/eom-qa/reviews_*.xlsx
```
Returns: total_reviews, avg_rating, one_two_star, three_five_star, per_address counts, warnings.

**2f. Read PDF visually** — use the Read tool on the downloaded PDF. Claude will see the table. Extract:
- Each location row: Location, Reviews, Rating, 1-2 Star, 3-5 Star, Status
- Summary footer: total locations, avg rating, total 1-2 star, total 3-5 star
- Total reviews = sum of all location review counts

**2g. Run all 5 checks**, record PASS/FAIL.

### Step 3: Present Results

For each email:

```
📧 Email: [subscriber] — [context]
═══════════════════════════════════════════════════
| Check                  | Result  | Details                              |
|------------------------|---------|--------------------------------------|
| Total Reviews          | ✅ PASS | Email=26, XLSX=26, PDF=26            |
| 1-2 Star Count         | ✅ PASS | Email=4, XLSX=4, PDF=4               |
| 3-5 Star Count         | ✅ PASS | Email=22, XLSX=22, PDF=22            |
| Avg Rating             | ✅ PASS | Email=4.3, XLSX=4.27→4.3             |
|                        | ℹ️ NOTE | PDF=4.5 (avg-of-avgs, known)         |
| Per-Location Counts    | ✅ PASS | All 7 locations match                |
| Location Count         | ✅ PASS | PDF=7, XLSX=7                        |
═══════════════════════════════════════════════════
```

After all emails:
```
📊 EOM QA SUMMARY: X/Y emails passed all checks
   ❌ Failures: [list any]
```

### Step 4: Cleanup

```bash
rm -rf /tmp/eom-qa/
```

## Important Notes

- Round XLSX avg rating to 1 decimal before comparing to email body.
- The PDF avg rating divergence is architectural (avg-of-avgs vs simple avg). Always flag, never fail.
- Some emails may have 0 reviews — skipEmpty should prevent this but handle gracefully.
- The XLSX "Positive" sheet should contain 3-5 star, "Negative" 1-2 star. The parse_xlsx.py script verifies this assumption and warns if violated.
- When extracting "1-2 Star" from email body, be careful: the text reads `1-2 Star43-5 Star22` — the `4` is the 1-2 star count and `3-5 Star` immediately follows. The parse_email_body.py script handles this with the pattern `1-2 Star(\d+)` which correctly captures `4` before hitting the `-` in `3-5`.
