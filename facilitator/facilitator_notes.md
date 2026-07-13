# Facilitator Notes

**Cortex Code Workshop — Thomson Reuters | July 2026**

---

## Timing Guide

| Segment | Duration | Notes |
|---------|----------|-------|
| Welcome + context setting | 5 min | Connect CoWork → CoCo narrative |
| Exercise 1: Connect & Discover | 10 min | Ensure everyone can query |
| Exercise 2: AI Enrichment | 20 min | Most time here — participants explore |
| Exercise 3: Gold + Semantic View | 15 min | May need prompt refinement |
| Exercise 4: Streamlit Dashboard | 15 min | The "wow" moment |
| Bonus / Q&A | 10 min | Only if time permits |
| **Total** | **~75 min** | Buffer built into each exercise |

---

## Before the Workshop

### Day Before
- [ ] Run `setup/admin_setup.sql` as ACCOUNTADMIN
- [ ] Verify source table has data: `SELECT COUNT(*) FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT`
- [ ] Confirm each attendee's personal DB exists: `SHOW DATABASES LIKE 'COCO_WORKSHOP_%'`
- [ ] Test AI function access with the learner role
- [ ] Confirm CoCo panel is enabled in Snowsight for all participants
- [ ] Test the full Exercise 2 flow yourself to confirm model responses

### Day Of
- [ ] Arrive 15 min early
- [ ] Open Snowsight with CoCo panel visible (for live demo)
- [ ] Have the slide deck ready (pages 24-26 for reference)
- [ ] Confirm all participants can log in and see the CoCo panel

---

## Talking Points Per Exercise

### Exercise 1: Connect & Discover
- **Key message:** CoCo knows your Snowflake account — databases, tables, columns. It writes the SQL, you just ask the question.
- **Demo opportunity:** Show how CoCo explores the table structure without navigating the object browser
- **Common issue:** Participants might not see CoCo panel — click the diamond icon top-right
- **Talking point:** "Notice the data has numbers, but no interpretation. A PES score of 42 — is that good? Bad? That's what we'll solve next."

### Exercise 2: Data Quality & Business Rules
- **Key message:** CoCo writes complex SQL from business descriptions. You describe the rule, it handles window functions, CASE logic, NULL handling — and it works every time (no model variability).
- **Demo opportunity:** Show iterative refinement — "change the Churning threshold from 30 to 25" or "add a new DQ check"
- **Common issue:** Participants may get different CASE ordering — emphasize that priority matters (Churning check before At-Risk)
- **Talking point:** "Every row gets classified identically, every time. That's the difference between a production pipeline and a demo — deterministic rules you can audit and explain."

### Exercise 3: Gold + Semantic View
- **Key message:** This is what powers CoWork. When business users ask questions, the semantic view translates intent to SQL. You're building that translation layer.
- **Demo opportunity:** After creating the semantic view, ask a natural language question and show it working
- **Common issue:** Semantic view might need column type adjustments — CoCo will help debug
- **Talking point:** "Remember in the CoWork session when you asked 'which accounts are at risk?' — someone had to build this layer first. Now you know how."

### Exercise 4: Streamlit Dashboard
- **Key message:** One prompt → full app. No context-switching to another tool. Build, deploy, iterate — all in CoCo.
- **Demo opportunity:** Ask someone to suggest a customization live, then prompt CoCo to implement it
- **Common issue:** CREATE STREAMLIT permission — verify grants were applied
- **Talking point:** "You just built an entire analytics application — data pipeline, DQ scoring, semantic layer, and interactive dashboard — without writing a single line of code by hand."

---

## Troubleshooting Quick Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| CoCo panel not visible | Feature not enabled or icon hidden | Click diamond icon top-right; check with admin |
| "Insufficient privileges" on CREATE | Missing grants on COCO_WORKSHOP | Re-run the GRANT statements from admin_setup.sql |
| NULLIF returns unexpected results | Division by zero edge case | CoCo should wrap denominators in NULLIF — ask it to fix |
| Semantic view won't create | Missing CORTEX_USER role | Run: `GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE` |
| Streamlit deploy fails | Missing CREATE STREAMLIT grant | Re-run grant from admin_setup.sql |
| DQ scores all show 1.0 | No NULLs in sampled data | Normal — mention production data would have gaps |

---

## Fallback SQL

Use **only** if a participant is blocked and you need to keep the group moving. Don't share proactively.

### Exercise 2 — Silver Table (reference)

```sql
-- Replace <USERNAME> with the participant's actual username
USE DATABASE COCO_WORKSHOP_<USERNAME>;
USE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE SILVER_ACCOUNT_HEALTH AS
WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ACCOUNT_ID, APP_NAME ORDER BY DATE_RECORDED DESC) AS rn
    FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
    QUALIFY rn = 1
)
SELECT
    APP_NAME,
    ACCOUNT_ID,
    SUBSCRIPTION_NAME,
    BU_SEGMENT_C,
    DATE_RECORDED,
    -- Cleaned metrics (NULL → 0)
    COALESCE(PES_SCORE, 0) AS PES_SCORE,
    COALESCE(NPS_SCORE, 0) AS NPS_SCORE,
    COALESCE(ADOPTION, 0) AS ADOPTION,
    COALESCE(STICKINESS, 0) AS STICKINESS,
    COALESCE(GROWTH, 0) AS GROWTH,
    COALESCE(VISITORS_TO_APP_LAST_30_DAYS, 0) AS VISITORS_TO_APP_LAST_30_DAYS,
    COALESCE(TOTAL_DAYS_ACTIVE_LAST_30_DAYS, 0) AS TOTAL_DAYS_ACTIVE_LAST_30_DAYS,
    COALESCE(GUIDES_SEEN_LAST_30_DAYS, 0) AS GUIDES_SEEN_LAST_30_DAYS,
    COALESCE(GUIDES_ADVANCED_LAST_30_DAYS, 0) AS GUIDES_ADVANCED_LAST_30_DAYS,
    COALESCE(GUIDES_DISMISSED_LAST_30_DAYS, 0) AS GUIDES_DISMISSED_LAST_30_DAYS,
    COALESCE(GUIDES_SNOOZED_LAST_30_DAYS, 0) AS GUIDES_SNOOZED_LAST_30_DAYS,
    -- Risk classification (business rules)
    CASE
        WHEN COALESCE(PES_SCORE, 0) < 30 OR COALESCE(TOTAL_DAYS_ACTIVE_LAST_30_DAYS, 0) < 5
            THEN 'Churning'
        WHEN COALESCE(PES_SCORE, 0) > 60
            AND COALESCE(NPS_SCORE, 0) > 30
            AND COALESCE(TOTAL_DAYS_ACTIVE_LAST_30_DAYS, 0) > 15
            THEN 'Healthy'
        ELSE 'At-Risk'
    END AS risk_classification,
    -- Guide effectiveness
    GUIDES_ADVANCED_LAST_30_DAYS::FLOAT / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0)
        AS guide_effectiveness_rate,
    CASE
        WHEN COALESCE(GUIDES_SEEN_LAST_30_DAYS, 0) = 0 THEN 'No Data'
        WHEN GUIDES_ADVANCED_LAST_30_DAYS::FLOAT / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0) > 0.5 THEN 'Effective'
        WHEN GUIDES_DISMISSED_LAST_30_DAYS::FLOAT / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0) > 0.5 THEN 'Ignored'
        ELSE 'Underperforming'
    END AS guide_status,
    -- Engagement metrics
    TOTAL_EVENTS_LAST_30_DAYS::FLOAT / NULLIF(VISITORS_TO_APP_LAST_30_DAYS, 0)
        AS engagement_intensity,
    VISITORS_TO_APP_LAST_30_DAYS::FLOAT / NULLIF(VISITORS_TO_ALL_APPS_OF_ACCOUNT_LAST_30_DAYS, 0)
        AS visitor_retention_rate,
    -- Data quality
    (IFF(PES_SCORE IS NOT NULL, 1, 0) + IFF(NPS_SCORE IS NOT NULL, 1, 0)
     + IFF(ADOPTION IS NOT NULL, 1, 0) + IFF(STICKINESS IS NOT NULL, 1, 0)
     + IFF(GROWTH IS NOT NULL, 1, 0) + IFF(VISITORS_TO_APP_LAST_30_DAYS IS NOT NULL, 1, 0)
     + IFF(TOTAL_DAYS_ACTIVE_LAST_30_DAYS IS NOT NULL, 1, 0)
     + IFF(TOTAL_EVENTS_LAST_30_DAYS IS NOT NULL, 1, 0)) / 8.0
        AS dq_completeness_score,
    CASE
        WHEN DATEDIFF('day', DATE_RECORDED, CURRENT_DATE()) <= 7 THEN 'Fresh'
        WHEN DATEDIFF('day', DATE_RECORDED, CURRENT_DATE()) <= 30 THEN 'Stale'
        ELSE 'Outdated'
    END AS dq_freshness_flag,
    CASE
        WHEN PES_SCORE BETWEEN 0 AND 100 AND DATE_RECORDED IS NOT NULL THEN 'Valid'
        ELSE 'Invalid'
    END AS dq_validity_flag,
    CURRENT_TIMESTAMP() AS enriched_at
FROM deduped;
```

### Exercise 3 — Gold Views (reference)

```sql
-- BU Adoption (in participant's personal DB)
CREATE OR REPLACE VIEW GOLD_BU_ADOPTION AS
SELECT
    BU_SEGMENT_C,
    COUNT(*) AS total_accounts,
    AVG(PES_SCORE) AS avg_pes,
    AVG(ADOPTION) AS avg_adoption,
    AVG(STICKINESS) AS avg_stickiness,
    AVG(GROWTH) AS avg_growth,
    SUM(VISITORS_TO_APP_LAST_30_DAYS) AS total_visitors_30d,
    ROUND(SUM(CASE WHEN risk_classification = 'Healthy' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_healthy
FROM SILVER_ACCOUNT_HEALTH
GROUP BY BU_SEGMENT_C
ORDER BY avg_pes DESC;

-- At-Risk Accounts
CREATE OR REPLACE VIEW GOLD_AT_RISK_ACCOUNTS AS
SELECT APP_NAME, ACCOUNT_ID, BU_SEGMENT_C, PES_SCORE, NPS_SCORE,
       TOTAL_DAYS_ACTIVE_LAST_30_DAYS, risk_classification, guide_status,
       engagement_intensity, dq_completeness_score
FROM SILVER_ACCOUNT_HEALTH
WHERE TRIM(risk_classification) IN ('At-Risk', 'Churning')
ORDER BY PES_SCORE ASC;

-- NPS Summary (reads from shared source)
CREATE OR REPLACE VIEW GOLD_NPS_SUMMARY AS
SELECT
    BU_SEGMENT_C,
    DATE_RECORDED,
    AVG(NPS_SCORE) AS avg_nps,
    SUM(NPS_NUMBER_OF_PROMOTERS) AS total_promoters,
    SUM(NPS_NUMBER_OF_DETRACTERS) AS total_detractors,
    SUM(NPS_NUMBER_OF_PASSIVES) AS total_passives,
    AVG(PES_SCORE) AS avg_pes
FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
WHERE NPS_NUMBER_OF_RESPONSES > 0
GROUP BY BU_SEGMENT_C, DATE_RECORDED;

-- Guide ROI
CREATE OR REPLACE VIEW GOLD_GUIDE_ROI AS
SELECT
    BU_SEGMENT_C,
    SUM(GUIDES_SEEN_LAST_30_DAYS) AS total_seen,
    SUM(GUIDES_ADVANCED_LAST_30_DAYS) AS total_advanced,
    SUM(GUIDES_DISMISSED_LAST_30_DAYS) AS total_dismissed,
    SUM(GUIDES_SNOOZED_LAST_30_DAYS) AS total_snoozed,
    ROUND(SUM(GUIDES_ADVANCED_LAST_30_DAYS)::FLOAT / NULLIF(SUM(GUIDES_SEEN_LAST_30_DAYS), 0), 3) AS advancement_rate,
    ROUND(SUM(GUIDES_DISMISSED_LAST_30_DAYS)::FLOAT / NULLIF(SUM(GUIDES_SEEN_LAST_30_DAYS), 0), 3) AS dismissal_rate,
    SUM(CASE WHEN guide_status = 'Effective' THEN 1 ELSE 0 END) AS effective_count,
    SUM(CASE WHEN guide_status = 'Ignored' THEN 1 ELSE 0 END) AS ignored_count
FROM SILVER_ACCOUNT_HEALTH
GROUP BY BU_SEGMENT_C;
```

---

## CoCo Differentiators to Highlight

When participants ask "how is this different from Copilot/Cursor?":

1. **Snowflake-aware metadata** — CoCo sees your databases, tables, columns, roles. Generic tools don't.
2. **Built-in skills** — Semantic View creation, Streamlit deployment, Agent building are first-class workflows.
3. **Security-first** — code and prompts stay within Snowflake's security perimeter.
4. **Runs SQL natively** — executes against your warehouse, shows results inline. No copy-paste.
5. **Context persistence** — CoCo remembers what you built earlier in the session.
