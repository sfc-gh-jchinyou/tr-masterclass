# Demo Prompts

Exact prompts for live demonstrations. Copy-paste ready.

---

## Pre-Workshop Demo (2 min wow moment)

Show the end-to-end capability before participants start:

```
Describe PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT and show me 3 sample rows.
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
What tables are in PROD.PRODUCT_USAGE? Describe the columns in ACCOUNT_USAGE_BY_PRODUCT.
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

### Health narrative generation:
```
Write a query that uses SNOWFLAKE.CORTEX.COMPLETE with mistral-large2 to generate 
a 2-sentence health narrative for each of 5 accounts in 
PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT. Include PES score, NPS, adoption, 
stickiness, growth, and days active as context. Benchmarks: PES > 60 is healthy, 
NPS > 30 is strong.
```

### Risk classification:
```
Add a risk classification to the query. Use AI_COMPLETE to classify each account 
as Healthy, At-Risk, or Churning based on: PES > 60 + NPS > 30 + Active > 15 = Healthy. 
PES < 30 OR Active < 5 = Churning. Everything else = At-Risk. Return one word only.
```

### Iterative refinement:
```
The risk classifications have extra text. Update the query to TRIM the output and 
add a CASE statement that defaults to 'At-Risk' if the model returns anything 
other than exactly 'Healthy', 'At-Risk', or 'Churning'.
```

### Full Silver creation:
```
Combine into a CREATE TABLE for SILVER_ACCOUNT_HEALTH in COCO_WORKSHOP schema. 
Include key columns, health_narrative, risk_classification, guide_effectiveness, 
and enriched_at. Use the most recent record per account (QUALIFY ROW_NUMBER). 
Limit to 50 rows.
```

---

## Exercise 3 Demos

### Gold views:
```
Create four Gold views in COCO_WORKSHOP over SILVER_ACCOUNT_HEALTH:
1. GOLD_BU_ADOPTION - avg PES, adoption, stickiness, growth, pct healthy by BU
2. GOLD_AT_RISK_ACCOUNTS - all At-Risk/Churning accounts with health narrative
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
COCO_WORKSHOP with three pages:
1. Adoption Overview - bar chart of avg PES by BU from GOLD_BU_ADOPTION, 
   metric cards for total accounts and avg PES
2. Account Health - pie chart of risk distribution from SILVER_ACCOUNT_HEALTH, 
   filterable table of GOLD_AT_RISK_ACCOUNTS with health narratives
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
Deploy this Streamlit app to Snowflake in the COCO_WORKSHOP schema.
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
