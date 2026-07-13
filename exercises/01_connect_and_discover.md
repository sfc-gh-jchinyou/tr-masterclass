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

## Step 2: Set Up Your Personal Database

Each participant has their own database for creating tables and views. Confirm yours exists:

```
USE DATABASE COCO_WORKSHOP_<YOUR_USERNAME>;
USE SCHEMA PUBLIC;
```

> Replace `<YOUR_USERNAME>` with your Snowflake username (e.g., `COCO_WORKSHOP_JSMITH`). Your facilitator will confirm the exact name.

---

## Step 3: Discover the Data

Type these prompts into CoCo's chat panel:

### Prompt 1: What data do I have access to?

```
What databases and schemas can I access? Are there any tables related to 
product usage or account engagement?
```

> CoCo will search your available objects and surface the ACCOUNT_USAGE_BY_PRODUCT table. This is how discovery works — you don't need to know the path upfront.

### Prompt 2: Tell me about that table

```
Describe that account usage table. What columns does it have and what kind 
of data is in it?
```

> CoCo will show you the column list. Notice the four metric categories: daily engagement, 30-day rollups, guide interactions, and satisfaction scores (NPS/PNPS/PES).

### Prompt 3: Understand the dimensions

```
How many unique apps, subscriptions, and BU segments are in that table? 
Show me the distinct BU segment values.
```

> This reveals the segmentation structure — you'll see Thomson Reuters business units.

### Prompt 4: Time range

```
What's the date range of data? Show me the earliest and latest recorded dates.
```

---

## Step 4: Ask Analytical Questions

Now let CoCo write more complex queries for you:

### Prompt 5: Most active apps

```
What are the top 10 apps by total visitors in the last 30 days? 
Show the app name, total visitors, and which BU segment they belong to.
```

### Prompt 6: Satisfaction overview

```
What's the average NPS score and PES score across all accounts? 
Break it down by business unit. Which segment scores highest and lowest?
```

### Prompt 7: Engagement health check

```
How many accounts have fewer than 5 active days in the last 30 days? 
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
> In the next exercise, you'll build business rules and DQ scoring to add that interpretation.

---

## Next: [Exercise 2 — Data Quality & Business Rules (Bronze → Silver)](02_data_quality.md)
