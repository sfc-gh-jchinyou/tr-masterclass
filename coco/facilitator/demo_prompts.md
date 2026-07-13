# Demo Prompts

Exact prompts for live demonstrations. Copy-paste ready.

---

## Pre-Workshop Demo (2 min wow moment)

Show the end-to-end capability before participants start:

```
Describe MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT and show me 3 sample rows.
```

Then immediately:

```
Take 5 accounts from that table and use SNOWFLAKE.CORTEX.COMPLETE with mistral-large2 
to generate a one-sentence health assessment for each based on their PES score, 
NPS score, and days active in the last 30 days.
```

---

## Exercise 1 Demos

### Show data discovery:
```
What tables are in MASTERCLASS_DB.COCO_WORKSHOP? Describe the columns in ACCOUNT_USAGE_BY_PRODUCT.
```

### Show analytical query generation:
```
How many unique apps and BU segments are in ACCOUNT_USAGE_BY_PRODUCT? 
Which BU segment has the most accounts?
```

### Show instant insights:
```
What's the average PES score across all accounts? Which 5 apps have the lowest 
average PES score in the last 30 days?
```

---

## Exercise 2 Demos

### Dedup and clean:
```
Write a query that deduplicates MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT to get 
the most recent record per ACCOUNT_ID and APP_NAME using ROW_NUMBER and QUALIFY. 
Replace NULLs in PES_SCORE, NPS_SCORE, TOTAL_DAYS_ACTIVE_LAST_30_DAYS with 0. 
Show 10 rows.
```

### Risk classification:
```
Add a risk_classification column using CASE:
- 'Churning' if PES_SCORE < 30 OR TOTAL_DAYS_ACTIVE_LAST_30_DAYS < 5
- 'Healthy' if PES_SCORE > 60 AND NPS_SCORE > 30 AND TOTAL_DAYS_ACTIVE > 15
- 'At-Risk' otherwise
Churning takes priority. Show the count per category.
```

### Iterative refinement:
```
The Churning threshold feels too aggressive. Change it from PES < 30 to PES < 20 
and add a condition that NPS < 0 should also trigger Churning.
```

### Full Silver creation:
```
Combine into a CREATE TABLE for SILVER_ACCOUNT_HEALTH in my database.
Read from MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT. Include 
key dimensions, cleaned metrics, risk_classification, guide_effectiveness_rate 
(advanced/seen), guide_status (Effective/Ignored/Underperforming/No Data), 
engagement_intensity (events/visitors), visitor_retention_rate (app visitors / 
all app visitors), dq_completeness_score (non-null count / 8), dq_freshness_flag 
(Fresh/Stale/Outdated based on days since DATE_RECORDED), and enriched_at timestamp.
```

---

## Exercise 3 Demos

### Gold views:
```
Create four Gold views in my database over SILVER_ACCOUNT_HEALTH:
1. GOLD_BU_ADOPTION - avg PES, adoption, stickiness, growth, pct healthy by BU
2. GOLD_AT_RISK_ACCOUNTS - all At-Risk/Churning accounts with guide status and engagement scores
3. GOLD_NPS_SUMMARY - NPS trends by BU and date from the source table
4. GOLD_GUIDE_ROI - guide seen/advanced/dismissed rates by BU
```

### Semantic view:
```
Create a semantic view called PRODUCT_INTELLIGENCE_SV over GOLD_BU_ADOPTION, 
GOLD_AT_RISK_ACCOUNTS, GOLD_NPS_SUMMARY, GOLD_GUIDE_ROI, and SILVER_ACCOUNT_HEALTH. 
It should answer questions like "which BU has lowest adoption", "show at-risk accounts", 
"NPS trend over time", and "guide effectiveness by segment".
```

### Test the semantic view:
```
Using PRODUCT_INTELLIGENCE_SV, which business unit has the most at-risk accounts?
```

---

## Exercise 4 Demos

### The big prompt:
```
Build a Streamlit in Snowflake app called "Product Intelligence Dashboard" in 
my database with three pages:
1. Adoption Overview - bar chart of avg PES by BU from GOLD_BU_ADOPTION, 
   metric cards for total accounts and avg PES
2. Account Health - pie chart of risk distribution from SILVER_ACCOUNT_HEALTH, 
   filterable table of GOLD_AT_RISK_ACCOUNTS with engagement metrics
3. NPS & Guides - line chart of NPS over time from GOLD_NPS_SUMMARY, 
   bar chart of advancement vs dismissal rate from GOLD_GUIDE_ROI
Use Snowflake theme with sidebar navigation.
```

### Live customization (audience suggestion):
```
Add a BU segment dropdown to the sidebar that filters all three pages.
```

### Deploy:
```
Deploy this Streamlit app to Snowflake in my database.
```

---

## Bonus Demos (if time)

### Cortex Agent:
```
Create a Cortex Agent called PRODUCT_HEALTH_AGENT that uses PRODUCT_INTELLIGENCE_SV 
as an analyst tool to answer natural language questions about product engagement.
```

### Executive summary:
```
Use SNOWFLAKE.CORTEX.COMPLETE to generate a 3-paragraph executive summary of our 
product health posture based on the data in GOLD_BU_ADOPTION and GOLD_AT_RISK_ACCOUNTS. 
Write it as if presenting to the VP of Product.
```
