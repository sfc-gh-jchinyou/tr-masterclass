# Exercise 2: AI Enrichment (Bronze → Silver)

**Duration: ~20 minutes**
**CoCo Features: SQL authoring, AI Functions, iterative refinement**

---

## Objective

Use CoCo to write SQL that enriches raw product usage metrics with AI-generated health narratives, churn risk classifications, and guide effectiveness assessments. You'll transform the Bronze table into a Silver table that tells a *story* about each account — not just numbers.

---

## The Problem

The Bronze table has **metrics** — events, time, visitors, NPS scores — but lacks **meaning**:
- Is a PES score of 45 good or bad?
- Is an account with 3 active days in 30 days at risk, or is that normal for their product?
- Are guides being dismissed because they're irrelevant, or because users already know the product?

AI Functions will generate these interpretations automatically at scale.

---

## Step 1: Generate Health Narratives with AI_COMPLETE

Ask CoCo to write SQL that produces human-readable account health summaries.

### Prompt 1:

```
Write a SQL query that takes 10 rows from PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT 
and uses SNOWFLAKE.CORTEX.COMPLETE with 'mistral-large2' to generate a 2-sentence 
health narrative for each account.

The prompt to the model should include:
- App name and BU segment
- PES score, adoption, stickiness, and growth values
- Visitors in last 30 days and total days active
- NPS score

The narrative should describe the account's health in plain business English.
```

> **What to expect:** CoCo generates a SELECT with `SNOWFLAKE.CORTEX.COMPLETE` that feeds metrics into a prompt template. Review the SQL, then run it.

### Refine if needed:

```
The narratives are too generic. Update the prompt to make the model compare the 
account's metrics against what "good" looks like (PES > 60 is healthy, NPS > 50 is 
strong, active days > 15 shows regular usage). Have it flag specific concerns.
```

---

## Step 2: Classify Churn Risk with AI_CLASSIFY

Ask CoCo to classify each account into a risk tier.

### Prompt 2:

```
Write a query that uses SNOWFLAKE.CORTEX.COMPLETE to classify each account into 
exactly one risk category based on these rules:

- Healthy: PES > 60, NPS > 30, active days > 15
- At-Risk: PES between 30-60, OR declining visitors, OR guides mostly dismissed
- Churning: PES < 30, active days < 5, OR NPS < 0

The model should return ONLY one word: Healthy, At-Risk, or Churning.
Use the same 10-row sample from PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT.
Include the PES_SCORE, NPS_SCORE, TOTAL_DAYS_ACTIVE_LAST_30_DAYS, and guide metrics 
as context for the classification.
```

> **Note:** We use `AI_COMPLETE` with a constrained output format rather than `CLASSIFY_TEXT` because we want the model to reason over multiple numeric signals, not just classify text.

---

## Step 3: Assess Guide Effectiveness

Add a guide effectiveness assessment to the enrichment pipeline.

### Prompt 3:

```
Add a guide effectiveness score to the query. Use SNOWFLAKE.CORTEX.COMPLETE to 
assess guide engagement based on:
- GUIDES_SEEN_LAST_30_DAYS vs GUIDES_DISMISSED_LAST_30_DAYS
- GUIDES_ADVANCED_LAST_30_DAYS (positive signal - users engaging)
- GUIDES_SNOOZED_LAST_30_DAYS (neutral signal)

Have the model return one of: Effective, Underperforming, Ignored, No Data
Also generate a one-sentence explanation of why.
```

---

## Step 4: Create the Silver Table

Bring it all together into a persistent Silver table.

### Prompt 4:

```
Now combine all of this into a CREATE TABLE AS SELECT statement that creates 
SILVER_ACCOUNT_HEALTH in the COCO_WORKSHOP schema with:
- Key columns from the source: APP_NAME, ACCOUNT_ID, SUBSCRIPTION_NAME, 
  BU_SEGMENT_C, DATE_RECORDED, PES_SCORE, NPS_SCORE, ADOPTION, STICKINESS, GROWTH,
  VISITORS_TO_APP_LAST_30_DAYS, TOTAL_DAYS_ACTIVE_LAST_30_DAYS
- health_narrative (AI-generated summary)
- risk_classification (Healthy/At-Risk/Churning)
- guide_effectiveness (Effective/Underperforming/Ignored/No Data)
- guide_explanation (one-sentence reason)
- enriched_at (current timestamp)

Process 50 rows to start (we'll scale up later). Use the most recent DATE_RECORDED 
per account to avoid duplicates.
```

Run the generated SQL. Then verify:

```
Show me the distribution of risk_classification in SILVER_ACCOUNT_HEALTH. 
How many accounts are in each bucket?
```

---

## What You Built

```
ACCOUNT_USAGE_BY_PRODUCT             SILVER_ACCOUNT_HEALTH
┌─────────────────────────┐          ┌──────────────────────────────┐
│ PES_SCORE               │          │ APP_NAME                     │
│ NPS_SCORE               │   AI     │ PES_SCORE                    │
│ ADOPTION/STICKINESS     │ ──────►  │ NPS_SCORE                    │
│ VISITORS_LAST_30        │          │ health_narrative        [NEW] │
│ DAYS_ACTIVE_LAST_30     │          │ risk_classification     [NEW] │
│ GUIDES_SEEN/DISMISSED   │          │ guide_effectiveness     [NEW] │
│                         │          │ guide_explanation       [NEW] │
│                         │          │ enriched_at             [NEW] │
└─────────────────────────┘          └──────────────────────────────┘
```

---

## Key Takeaways

1. **AI Functions run inside Snowflake** — no data leaves your security perimeter
2. **CoCo writes the SQL** — you describe intent, it handles the CORTEX.COMPLETE syntax
3. **Iterative refinement works** — ask CoCo to adjust prompts, change thresholds, or restructure
4. **LLMs reason over numbers** — they can synthesize multiple metrics into plain-English assessments
5. **Start small, scale up** — test on 10-50 rows, then run on the full dataset

---

## AI Functions Used

| Function | Purpose |
|----------|---------|
| `SNOWFLAKE.CORTEX.COMPLETE` | Generate health narratives from metric context |
| `SNOWFLAKE.CORTEX.COMPLETE` | Classify risk tier based on multi-signal reasoning |
| `SNOWFLAKE.CORTEX.COMPLETE` | Assess guide effectiveness with explanation |

---

## Next: [Exercise 3 — Gold Layer + Semantic View](03_gold_and_semantic_view.md)
