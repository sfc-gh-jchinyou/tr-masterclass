# Exercise 4: Streamlit Product Intelligence Dashboard

**Duration: ~15 minutes**
**CoCo Features: BI & Apps, Streamlit generation, deployment to Snowflake**

---

## Objective

Use a single prompt to generate a complete product intelligence dashboard, then deploy it to Snowflake. You'll customize it with follow-up prompts — no manual Python coding required.

---

## Step 1: Generate the Dashboard

One prompt. Full app.

### Prompt 1: The Big Ask

```
Build me a Streamlit in Snowflake app called "Product Intelligence Dashboard" that 
connects to my database (COCO_WORKSHOP_<YOUR_USERNAME>) and shows three pages:

1. **Adoption Overview** — A bar chart showing average PES score by BU segment from 
   GOLD_BU_ADOPTION. Include metric cards at the top for: total accounts, overall 
   average PES, and percentage of healthy accounts.

2. **Account Health** — A pie chart showing the distribution of risk_classification 
   (Healthy/At-Risk/Churning) from SILVER_ACCOUNT_HEALTH. Below it, a filterable 
   data table of GOLD_AT_RISK_ACCOUNTS with columns: APP_NAME, BU_SEGMENT_C, 
   PES_SCORE, NPS_SCORE, risk_classification, guide_status, engagement_intensity.

3. **NPS & Guides** — A line chart showing NPS trend over time from GOLD_NPS_SUMMARY 
   (x-axis: DATE_RECORDED, y-axis: average NPS, colored by BU segment). Below it, 
   a bar chart of guide advancement rate vs dismissal rate by BU from GOLD_GUIDE_ROI.

Use the Snowflake theme. Add a sidebar with page navigation.
```

> **What happens:** CoCo generates a complete Streamlit app. It will use `st.connection("snowflake")` or `get_active_session()` to query your views.

---

## Step 2: Review and Deploy

CoCo will present the code. Before deploying:

1. Review the structure — does it query the right views?
2. Check that metric cards reference the correct columns
3. Note how filtering works

### Deploy:

```
Deploy this Streamlit app to Snowflake in my database.
```

> You'll get a URL to view the live app in Snowsight.

---

## Step 3: Customize

Make it yours with follow-up prompts:

### Prompt 2: Add interactivity

```
Add a BU segment filter to the sidebar that applies across all three pages. 
When a segment is selected, all charts and tables should filter to that segment only.
```

### Prompt 3: Show the AI narrative

```
On the Account Health page, when I click on a row in the at-risk accounts table, 
show the guide_status and engagement_intensity in an expanded detail area below the table.
```

### Prompt 4: Add a summary metric

```
Add a metric card row at the top of the NPS & Guides page showing:
- Current average NPS score
- Guide advancement rate (as a percentage)
- Number of at-risk accounts
Use red/green coloring based on whether values are above or below target 
(NPS > 30 = green, advancement rate > 50% = green).
```

---

## Step 4: Share and Compare

Once deployed, open your dashboard URL. Compare with your neighbor — different prompts produce different layouts, and that's the point. CoCo makes it easy to iterate.

---

## What You Built (End to End)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                  YOUR PRODUCT INTELLIGENCE PLATFORM                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Pendo Data  ──►  Bronze  ──►  Silver  ──►  Gold  ──►  Streamlit App   │
│  (raw daily)     (as-is)    (AI-enriched)  (aggregated)                 │
│                                                                         │
│  Metrics only    Snapshot    + Narratives   BU adoption    ┌─────────┐  │
│                              + Risk tiers   At-risk list   │ Product │  │
│                              + Guide scores NPS trends     │ Intel   │  │
│                                             Guide ROI      │Dashboard│  │
│                                                │           └─────────┘  │
│                                                ▼                        │
│  + Semantic View  ──►  Natural Language Access (CoWork / Analyst)       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

1. **One prompt → full app** — CoCo generates production-quality Streamlit from a description
2. **Iterative customization** — follow-up prompts modify without starting over
3. **Deployed in Snowflake** — no separate hosting, inherits role-based access
4. **Full stack from natural language** — raw data to AI enrichment to analytics to live UI

---

## Bonus Challenges

If you finish early:

### Bonus 1: Add a Cortex Agent

```
Create a Cortex Agent that answers questions about product health using 
PRODUCT_INTELLIGENCE_SV as an analyst tool. Call it PRODUCT_HEALTH_AGENT.
```

### Bonus 2: Natural Language in the Dashboard

```
Add a fourth page called "Ask About Products" with a text input. When users 
type a question, use Cortex Analyst with PRODUCT_INTELLIGENCE_SV to generate 
and display the answer inline.
```

### Bonus 3: Executive Summary Generator

```
Add a button to the Adoption Overview page that uses AI_COMPLETE to generate 
a 3-paragraph executive summary of the current product health posture based 
on the data in GOLD_BU_ADOPTION and GOLD_AT_RISK_ACCOUNTS.
```

---

## Wrap-Up

You've gone from **consumer** (asking CoWork questions about product health) to **creator** (building the entire intelligence platform that powers those answers). Everything — the AI enrichment, the semantic layer, the dashboard — was built through natural language prompts in CoCo.

This is the developer workflow for Snowflake's AI era.
