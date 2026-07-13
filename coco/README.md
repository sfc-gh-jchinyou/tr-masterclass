# Cortex Code Workshop: Build a Product Intelligence Platform

**Thomson Reuters | July 2026**

Transform raw product engagement data into an AI-powered analytics platform — using nothing but natural language prompts in Cortex Code.

---

## What You'll Build

A complete medallion architecture over daily Pendo product usage data:

```
Bronze (Raw)       →  Silver (Scored & Clean)   →  Gold (Analytics)       →  Streamlit App
──────────────────────────────────────────────────────────────────────────────────────────
Daily engagement      + Risk classification      Adoption by BU           Product
metrics per app       + Engagement scores        At-risk accounts         Intelligence
& account             + DQ metrics               NPS/PES trending         Dashboard
(Pendo data)          + Guide effectiveness      Guide ROI
```

By the end of this workshop, you will have:
- A Silver table with business-rule risk classifications, computed engagement scores, and DQ metrics
- Gold analytics views summarizing product adoption and account health
- A semantic view enabling natural language queries over product metrics
- A live Streamlit product intelligence dashboard deployed to Snowflake

---

## Narrative: From Consumer to Creator

In the CoWork workshop, you **asked questions** and got AI-generated answers. Now you'll build the intelligence layer that powers those experiences:

| As a CoWork consumer, you... | As a CoCo builder, you'll... |
|------------------------------|------------------------------|
| Asked "which accounts are at risk?" | Write the business rules that classify risk |
| Got engagement summaries | Build the data quality layer that scores health |
| Viewed product dashboards | Build a dashboard from a single prompt |

---

## Prerequisites

- [ ] Access to Snowsight with CoCo panel enabled (right-side chat)
- [ ] Your personal database created: `COCO_WORKSHOP_<YOUR_USERNAME>`
- [ ] Read access to shared source: `MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT`
- [ ] CREATE privileges in your personal database (provided by facilitator)

---

## Workshop Structure

| # | Exercise | Duration | Key CoCo Features |
|---|----------|----------|-------------------|
| 1 | [Connect and Discover](exercises/01_connect_and_discover.md) | ~10 min | Data Discovery, SQL execution, catalog search |
| 2 | [Data Quality & Business Rules (Bronze → Silver)](exercises/02_data_quality.md) | ~20 min | SQL authoring, Data Engineering, iterative refinement |
| 3 | [Gold Layer + Semantic View](exercises/03_gold_and_semantic_view.md) | ~15 min | Semantic View creation, Analyst integration |
| 4 | [Streamlit Product Dashboard](exercises/04_streamlit_dashboard.md) | ~15 min | BI & Apps, Streamlit generation, deployment |

**Total: ~60 minutes**

---

## The Data

You'll work with `MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT` — daily Pendo engagement metrics including:

| Category | Metrics |
|----------|---------|
| **Engagement** | Events, time on app, visitors (daily & 30-day) |
| **Guides** | Seen, snoozed, advanced, dismissed |
| **Satisfaction** | NPS score, PNPS score, promoters/detractors/passives |
| **Health** | PES score (Adoption + Stickiness + Growth) |
| **Segmentation** | BU segment (3 levels), subscription, app name |

---

## Quick Start

1. Open Snowsight and locate the CoCo panel (right side)
2. Set your context: `USE DATABASE COCO_WORKSHOP_<YOUR_USERNAME>;`
3. Verify you can read shared data: ask CoCo "Select 1 row from MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT"
4. Start with [Exercise 1](exercises/01_connect_and_discover.md)

---

## Cortex Code Capabilities Demonstrated

| Capability | Where Used |
|-----------|-----------|
| Data Discovery | Exercise 1 — explore tables with natural language |
| Data Engineering | Exercise 2 — DQ scoring, business rules, Silver pipeline |
| AI & Agents | Exercise 3 — Semantic Views; Bonus — AI Functions & Cortex Agent |
| Advanced Analytics | Exercise 3 — Gold aggregations |
| BI & Apps | Exercise 4 — Streamlit dashboard |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| CoCo panel not visible | Click the Snowflake diamond icon in top-right of Snowsight |
| "Insufficient privileges" | Ask facilitator to verify role grants |
| AI functions return errors | Verify `CORTEX_USER` database role is granted |
| CoCo generates wrong table name | Specify fully-qualified: `MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT` |
| Slow AI enrichment | Use `LIMIT 50` for testing, scale up after confirming results |

---

## Files in This Repo

```
TR_Coco_Workshop/
├── README.md                              ← You are here
├── setup/
│   ├── admin_setup.sql                    ← Admin: run before workshop
│   └── connections.toml.template          ← Connection template (if using Desktop)
├── exercises/
│   ├── 01_connect_and_discover.md         ← Exercise 1
│   ├── 02_data_quality.md                ← Exercise 2
│   ├── 03_gold_and_semantic_view.md       ← Exercise 3
│   └── 04_streamlit_dashboard.md          ← Exercise 4
└── facilitator/
    ├── facilitator_notes.md               ← Timing, talking points, fallbacks
    └── demo_prompts.md                    ← Exact prompts for live demos
```
