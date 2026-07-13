# Exercise 2: Data Quality & Business Rules (Bronze → Silver)

**Duration: ~20 minutes**
**CoCo Features: SQL authoring, Data Engineering, iterative refinement**

---

## Objective

Use CoCo to write SQL that transforms raw product usage data into a clean, scored Silver table. You'll compute business-rule-based risk classifications, engagement scores, and data quality metrics — all with deterministic SQL logic. 

---

## Setup: Create Your Silver Layer Worksheet

Before starting, open a SQL worksheet to build your Silver pipeline:

1. In Snowsight, click **+ → SQL Worksheet**
2. Rename it to **"Silver Layer"** (click the title at the top)
3. Set the context at the top of the worksheet:
   ```sql
   USE DATABASE COCO_WORKSHOP_<YOUR_USERNAME>;
   USE SCHEMA PUBLIC;
   USE WAREHOUSE WORKSHOP_WH;
   ```
4. Run those three lines to set your session context

You'll use CoCo (right panel) to **generate** the SQL, then paste each step into this worksheet to **run** it. This gives you a persistent record of your Silver pipeline.

---

## The Problem

The Bronze table has raw metrics, but they're noisy:

- Some accounts have NULL values for key fields
- There are duplicate records (multiple rows per account per date)
- A PES score of 45 means nothing without a classification framework
- Guide metrics are raw counts — not rates that enable comparison
- There's no single "is this account healthy?" flag for downstream analytics

You'll fix all of this in the Silver layer.

---



## Step 1: Deduplicate and Clean

Ask CoCo to handle the most recent record per account and clean NULLs.

### Prompt 1:

```
Write a SQL query that deduplicates the account usage table to get the most 
recent record per ACCOUNT_ID and APP_NAME based on DATE_RECORDED.
Use ROW_NUMBER with QUALIFY. Also replace NULL values in PES_SCORE, NPS_SCORE, 
and TOTAL_DAYS_ACTIVE_LAST_30_DAYS with 0. Show me 10 rows.
```

> **What to expect:** CoCo generates a CTE with `ROW_NUMBER() OVER (PARTITION BY ACCOUNT_ID, APP_NAME ORDER BY DATE_RECORDED DESC) = 1` and COALESCE for NULL handling.
>
> **Copy the generated SQL into your "Silver Layer" worksheet and run it** to verify it works.

---



## Step 2: Compute Risk Classification

Ask CoCo to add business-rule-based risk tiers.

### Prompt 2:

```
Extend this query to add a risk_classification column based on these rules:
- 'Healthy': PES_SCORE > 60 AND NPS_SCORE > 30 AND TOTAL_DAYS_ACTIVE_LAST_30_DAYS > 15
- 'Churning': PES_SCORE < 30 OR TOTAL_DAYS_ACTIVE_LAST_30_DAYS < 5
- 'At-Risk': everything else

Use a CASE statement. Make sure Churning takes priority over At-Risk 
(an account with PES=20 and Active=20 should still be Churning).
```

> CoCo will generate a CASE with the correct ordering. Run it and check the distribution.



### Verify:

```
Show me the count of accounts in each risk_classification bucket.
```

---



## Step 3: Compute Engagement Scores

Add derived metrics that make the data more useful for analytics.

### Prompt 3:

```
Add these computed columns to the query:
1. guide_effectiveness_rate: GUIDES_ADVANCED_LAST_30_DAYS / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0)
   (what fraction of guides do users actually engage with?)
2. guide_status: CASE — 'Effective' if rate > 0.5, 'Ignored' if dismissal rate > 0.5, 
   'No Data' if guides_seen = 0, otherwise 'Underperforming'
3. engagement_intensity: TOTAL_EVENTS_LAST_30_DAYS / NULLIF(VISITORS_TO_APP_LAST_30_DAYS, 0)
   (events per visitor — how deeply are users engaging?)
4. visitor_retention_rate: VISITORS_TO_APP_LAST_30_DAYS / NULLIF(VISITORS_TO_ALL_APPS_OF_ACCOUNT_LAST_30_DAYS, 0)
   (what fraction of account users visit this specific app?)
```

---



## Step 4: Add Data Quality Flags

Score each row's completeness and validity.

### Prompt 4:

```
Add data quality columns:
1. dq_completeness_score: count of non-NULL values across these 8 key columns 
   (PES_SCORE, NPS_SCORE, ADOPTION, STICKINESS, GROWTH, VISITORS_TO_APP_LAST_30_DAYS, 
   TOTAL_DAYS_ACTIVE_LAST_30_DAYS, TOTAL_EVENTS_LAST_30_DAYS) divided by 8. 
   Result is a 0-1 score.
2. dq_freshness_flag: 'Fresh' if DATE_RECORDED is within last 7 days, 
   'Stale' if 7-30 days, 'Outdated' if > 30 days
3. dq_validity_flag: 'Valid' if PES_SCORE between 0 and 100 and all date fields 
   are non-null, otherwise 'Invalid'
```

---



## Step 5: Create the Silver Table

Bring it all together.

### Prompt 5:

```
Combine everything into a CREATE TABLE AS SELECT that creates 
SILVER_ACCOUNT_HEALTH in my database. Read from the shared account usage table.
Include:
- Key dimensions: APP_NAME, ACCOUNT_ID, SUBSCRIPTION_NAME, BU_SEGMENT_C, DATE_RECORDED
- Raw metrics: PES_SCORE, NPS_SCORE, ADOPTION, STICKINESS, GROWTH, 
  VISITORS_TO_APP_LAST_30_DAYS, TOTAL_DAYS_ACTIVE_LAST_30_DAYS
- Guides: GUIDES_SEEN/ADVANCED/DISMISSED/SNOOZED_LAST_30_DAYS
- Computed: risk_classification, guide_effectiveness_rate, guide_status, 
  engagement_intensity, visitor_retention_rate
- DQ: dq_completeness_score, dq_freshness_flag, dq_validity_flag
- Metadata: CURRENT_TIMESTAMP() as enriched_at
```

**Copy the final CREATE TABLE statement into your "Silver Layer" worksheet and run it.** This is the full pipeline — it reads from the shared source and writes to your personal database.

Then verify in CoCo:

```
How many rows are in SILVER_ACCOUNT_HEALTH? Show me the distribution of 
risk_classification and the average dq_completeness_score per risk tier.
```

---



## Bonus: Attach a Data Metric Function

If time permits, ask CoCo to create a DMF for ongoing monitoring:

```
Create a Data Metric Function that checks the NULL rate of PES_SCORE in 
SILVER_ACCOUNT_HEALTH. Then show me how to attach it as a scheduled DQ monitor.
```

---



## What You Built

```
ACCOUNT_USAGE_BY_PRODUCT             SILVER_ACCOUNT_HEALTH
┌─────────────────────────┐          ┌──────────────────────────────────┐
│ PES_SCORE (nullable)    │          │ PES_SCORE (coalesced)            │
│ NPS_SCORE (nullable)    │  CLEAN   │ NPS_SCORE (coalesced)            │
│ Duplicate rows          │ ──────►  │ Deduplicated (latest per acct)   │
│ Raw guide counts        │  SCORE   │ risk_classification         [NEW]│
│ No derived metrics      │  DERIVE  │ guide_effectiveness_rate    [NEW]│
│                         │          │ guide_status                [NEW]│
│                         │          │ engagement_intensity        [NEW]│
│                         │          │ visitor_retention_rate      [NEW]│
│                         │          │ dq_completeness_score       [NEW]│
│                         │          │ dq_freshness_flag           [NEW]│
│                         │          │ dq_validity_flag            [NEW]│
└─────────────────────────┘          └──────────────────────────────────┘
```

---



## Key Takeaways

1. **CoCo writes complex SQL from business rules** — CASE statements, window functions, NULL handling
2. **Deterministic > probabilistic for pipelines** — business-rule classification is reliable, auditable, and fast
3. **Data quality is a first-class concern** — completeness, freshness, and validity scores surface problems early
4. **Iterative refinement works** — adjust thresholds, add columns, refine logic through conversation
5. **This scales** — the same SQL runs on 50 rows or 5 million rows identically

---



## Skills Demonstrated


| CoCo Capability      | What You Did                                           |
| -------------------- | ------------------------------------------------------ |
| SQL authoring        | Window functions, CASE, COALESCE, computed columns     |
| Data Engineering     | Dedup, NULL handling, derived metrics, DQ scoring      |
| Iterative refinement | Built complexity step by step through prompts          |
| Data Quality         | Completeness scoring, freshness flags, validity checks |


---



## Next: [Exercise 3 — Gold Layer + Semantic View](03_gold_and_semantic_view.md)

