# Exercise 1: Connect and Discover

**Duration: ~10 minutes**
**CoCo Features: Data Discovery, SQL execution, catalog search**

---

## Objective

Explore the product usage dataset using natural language in CoCo. By the end of this exercise, you'll understand the data model — what metrics are captured, how accounts and apps are segmented, and what time ranges are available.

---

## Step 1: Open CoCo

In Snowsight, locate the CoCo panel on the right side of the screen. You should see "Hi [name], How can I help?" with a chat input at the bottom.

If you don't see the CoCo panel:
- Look for the Snowflake diamond icon in the top-right corner
- Click it to open the CoCo assistant

---

## Step 2: Discover the Data

Type these prompts into CoCo's chat panel:

### Prompt 1: What's in the table?

```
Describe the table PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT. 
What columns does it have and what kind of data does it contain?
```

> CoCo will show you the column list. Notice the four metric categories: daily engagement, 30-day rollups, guide interactions, and satisfaction scores (NPS/PNPS/PES).

### Prompt 2: Understand the dimensions

```
How many unique apps, subscriptions, and BU segments are in 
PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT? Also show me the 
distinct values of BU_SEGMENT_C.
```

> This reveals the segmentation structure — you'll see Thomson Reuters business units.

### Prompt 3: Time range

```
What's the date range of data in ACCOUNT_USAGE_BY_PRODUCT? 
Show me the earliest and latest DATE_RECORDED values.
```

---

## Step 3: Ask Analytical Questions

Now let CoCo write more complex queries for you:

### Prompt 4: Most active apps

```
What are the top 10 apps by total visitors in the last 30 days? 
Show app name, total visitors, and the BU segment they belong to.
Use VISITORS_TO_APP_LAST_30_DAYS from PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT.
```

### Prompt 5: Satisfaction overview

```
What's the average NPS score and PES score across all accounts? 
Break it down by BU_SEGMENT_C. Which segment has the highest and lowest scores?
```

### Prompt 6: Engagement health check

```
How many accounts have fewer than 5 total days active in the last 30 days? 
What percentage of all accounts is that?
```

---

## What Just Happened?

You used CoCo to:
- **Discover** table structure without navigating Snowsight's object browser
- **Understand** data dimensions and time ranges through natural language
- **Analyze** engagement patterns — CoCo wrote the SQL, you just asked the questions

This is the **Data Discovery** capability. CoCo is aware of your Snowflake objects and can query them directly from the chat panel.

---

## Key Takeaway

> The raw table has **metrics** (engagement counts, scores, time spent) but lacks **interpretation**: Which accounts are healthy? Which are at risk? What does a PES score of 45 actually *mean* in business terms?
>
> In the next exercise, you'll use AI functions to generate that interpretation automatically.

---

## Next: [Exercise 2 — AI Enrichment (Bronze → Silver)](02_ai_enrichment.md)
