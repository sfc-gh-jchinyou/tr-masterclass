# Exercise 3: Gold Layer + Semantic View

**Duration: ~15 minutes**
**CoCo Features: Semantic View creation, Analyst integration, analytics SQL**

---

## Objective

Create Gold-layer analytics views that answer key product questions at a glance, then build a semantic view that enables natural language queries. This is the layer that powers CoWork-style experiences.

---

## The Connection to CoWork

When you asked CoWork "which accounts are at risk?" — it didn't search raw Pendo data. It queried a semantic layer that maps business questions to pre-computed analytics.

**You're about to build that layer.**

---

## Step 1: Create Gold Aggregation Views

Ask CoCo to build analytics-ready views over the Silver table.

### Prompt 1: Adoption by Business Unit

```
Create a view called GOLD_BU_ADOPTION in the COCO_WORKSHOP schema that shows 
per-BU-segment metrics from SILVER_ACCOUNT_HEALTH:
- Total accounts
- Average PES score
- Average adoption, stickiness, and growth
- Total visitors in last 30 days
- Percentage of accounts classified as Healthy

Group by BU_SEGMENT_C. Order by average PES score descending.
```

### Prompt 2: At-Risk Account List

```
Create a view called GOLD_AT_RISK_ACCOUNTS that shows all accounts from 
SILVER_ACCOUNT_HEALTH where risk_classification is 'At-Risk' or 'Churning'.

Include: APP_NAME, ACCOUNT_ID, BU_SEGMENT_C, PES_SCORE, NPS_SCORE, 
TOTAL_DAYS_ACTIVE_LAST_30_DAYS, risk_classification, health_narrative.

Order by PES_SCORE ascending (worst first).
```

### Prompt 3: NPS Trending

```
Create a view called GOLD_NPS_SUMMARY that aggregates NPS metrics from the source 
table PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT grouped by BU_SEGMENT_C and 
DATE_RECORDED:
- Average NPS score
- Total promoters, detractors, passives
- Calculated NPS (promoters - detractors) / total responses * 100
- Average PES score for context

Only include rows where NPS_NUMBER_OF_RESPONSES > 0.
```

### Prompt 4: Guide ROI

```
Create a view called GOLD_GUIDE_ROI from SILVER_ACCOUNT_HEALTH that shows 
guide engagement by BU segment:
- Total guides seen, advanced, dismissed, snoozed
- Advancement rate (advanced / seen)
- Dismissal rate (dismissed / seen)
- Count of accounts where guide_effectiveness = 'Effective' vs 'Ignored'

Group by BU_SEGMENT_C.
```

---

## Step 2: Verify the Gold Views

```
Show me 5 rows from each of my Gold views: GOLD_BU_ADOPTION, GOLD_AT_RISK_ACCOUNTS, 
GOLD_NPS_SUMMARY, and GOLD_GUIDE_ROI.
```

---

## Step 3: Create a Semantic View

Now build the semantic layer that makes all of this queryable in natural language.

### Prompt 5: Build the Semantic View

```
Create a semantic view called PRODUCT_INTELLIGENCE_SV over my Gold views 
(GOLD_BU_ADOPTION, GOLD_AT_RISK_ACCOUNTS, GOLD_NPS_SUMMARY, GOLD_GUIDE_ROI) 
and SILVER_ACCOUNT_HEALTH.

It should support questions like:
- "Which BU has the lowest product adoption?"
- "Show me all at-risk accounts in the Legal segment"
- "What's the NPS trend over the last 90 days?"
- "Which apps have the highest guide dismissal rate?"
- "How many accounts are churning?"
```

> **What happens:** CoCo uses its semantic-view skill to generate DDL with entities, metrics, dimensions, and relationships. Review it before running.

---

## Step 4: Test the Semantic View

Once created, test it with natural language:

### Prompt 6:

```
Using PRODUCT_INTELLIGENCE_SV, which business unit has the most at-risk accounts 
and what's their average PES score?
```

### Prompt 7:

```
Using the semantic view, compare guide effectiveness across BU segments. 
Which segment has the highest dismissal rate?
```

---

## What You Built

```
SILVER_ACCOUNT_HEALTH
         │
         ├──► GOLD_BU_ADOPTION         ──┐
         │                                │
         ├──► GOLD_AT_RISK_ACCOUNTS      ├──► PRODUCT_INTELLIGENCE_SV
         │                                │      (Semantic View)
         ├──► GOLD_NPS_SUMMARY           │
         │                                │
         └──► GOLD_GUIDE_ROI            ──┘
                                                    │
                                                    ▼
                                          Natural Language Access
                                          (CoWork / Cortex Analyst)
```

---

## Key Takeaways

1. **Gold views answer specific business questions** — they're pre-aggregated for speed and clarity
2. **Semantic views map concepts to SQL** — business users don't need to know table names or join paths
3. **CoCo's semantic-view skill handles the complexity** — entities, metrics, dimensions, time grains
4. **This is what powers CoWork** — the "magic" behind natural language answers is a well-designed semantic layer

---

## Next: [Exercise 4 — Streamlit Product Dashboard](04_streamlit_dashboard.md)
