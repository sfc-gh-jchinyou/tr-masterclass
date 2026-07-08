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
- [ ] Verify source table has data: `SELECT COUNT(*) FROM PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT`
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

### Exercise 2: AI Enrichment
- **Key message:** AI Functions run IN Snowflake. Data never leaves the security perimeter. These models interpret your metrics and generate business-readable intelligence.
- **Demo opportunity:** Show iterative refinement — "make the narrative more specific" or "use a different classification threshold"
- **Common issue:** Large result sets can be slow — have participants use `LIMIT 10` for testing, then scale to 50
- **Model note:** `mistral-large2` is the safest default. If Claude is available via cross-region, it produces better narratives.
- **Talking point:** "Think about what this means at scale — you just classified hundreds of accounts in seconds, something that would take a human analyst days."

### Exercise 3: Gold + Semantic View
- **Key message:** This is what powers CoWork. When business users ask questions, the semantic view translates intent to SQL. You're building that translation layer.
- **Demo opportunity:** After creating the semantic view, ask a natural language question and show it working
- **Common issue:** Semantic view might need column type adjustments — CoCo will help debug
- **Talking point:** "Remember in the CoWork session when you asked 'which accounts are at risk?' — someone had to build this layer first. Now you know how."

### Exercise 4: Streamlit Dashboard
- **Key message:** One prompt → full app. No context-switching to another tool. Build, deploy, iterate — all in CoCo.
- **Demo opportunity:** Ask someone to suggest a customization live, then prompt CoCo to implement it
- **Common issue:** CREATE STREAMLIT permission — verify grants were applied
- **Talking point:** "You just built an entire analytics application — data pipeline, AI enrichment, semantic layer, and interactive dashboard — without writing a single line of code by hand."

---

## Troubleshooting Quick Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| CoCo panel not visible | Feature not enabled or icon hidden | Click diamond icon top-right; check with admin |
| "Insufficient privileges" on CREATE | Missing grants on COCO_WORKSHOP | Re-run the GRANT statements from admin_setup.sql |
| AI function returns NULL | Input too long or model context exceeded | Use `LIMIT 10` or shorten the prompt template |
| "Model not available" | Model not in allowlist or region | Switch to `mistral-large2` (most widely available) |
| AI response includes extra text | Model didn't follow "one word only" instruction | Ask CoCo to add TRIM() and handle edge cases |
| Semantic view won't create | Missing CORTEX_USER role | Run: `GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE` |
| Streamlit deploy fails | Missing CREATE STREAMLIT grant | Re-run grant from admin_setup.sql |
| Slow AI enrichment | Processing too many rows | Use LIMIT 50 for workshop; mention production would batch |

---

## Fallback SQL

Use **only** if a participant is blocked and you need to keep the group moving. Don't share proactively.

### Exercise 2 — Silver Table (reference)

```sql
CREATE OR REPLACE TABLE MASTERCLASS_DB.COCO_WORKSHOP.SILVER_ACCOUNT_HEALTH AS
WITH recent_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ACCOUNT_ID, APP_NAME ORDER BY DATE_RECORDED DESC) AS rn
    FROM PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT
    WHERE DATE_RECORDED >= DATEADD('day', -30, CURRENT_DATE())
    QUALIFY rn = 1
    LIMIT 50
)
SELECT
    APP_NAME,
    ACCOUNT_ID,
    SUBSCRIPTION_NAME,
    BU_SEGMENT_C,
    DATE_RECORDED,
    PES_SCORE,
    NPS_SCORE,
    ADOPTION,
    STICKINESS,
    GROWTH,
    VISITORS_TO_APP_LAST_30_DAYS,
    TOTAL_DAYS_ACTIVE_LAST_30_DAYS,
    GUIDES_SEEN_LAST_30_DAYS,
    GUIDES_DISMISSED_LAST_30_DAYS,
    GUIDES_ADVANCED_LAST_30_DAYS,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        CONCAT(
            'You are a product analytics expert. Write a 2-sentence health summary for this account.\n\n',
            'App: ', APP_NAME, '\nBU: ', COALESCE(BU_SEGMENT_C, 'Unknown'), '\n',
            'PES Score: ', COALESCE(PES_SCORE::STRING, 'N/A'),
            ' (Adoption: ', COALESCE(ADOPTION::STRING, 'N/A'),
            ', Stickiness: ', COALESCE(STICKINESS::STRING, 'N/A'),
            ', Growth: ', COALESCE(GROWTH::STRING, 'N/A'), ')\n',
            'Visitors (30d): ', COALESCE(VISITORS_TO_APP_LAST_30_DAYS::STRING, 'N/A'), '\n',
            'Days Active (30d): ', COALESCE(TOTAL_DAYS_ACTIVE_LAST_30_DAYS::STRING, 'N/A'), '\n',
            'NPS Score: ', COALESCE(NPS_SCORE::STRING, 'N/A'), '\n\n',
            'Healthy benchmarks: PES > 60, NPS > 30, Active days > 15.\n',
            'Summary:'
        )
    ) AS health_narrative,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        CONCAT(
            'Classify this account as exactly one of: Healthy, At-Risk, Churning.\n',
            'PES: ', COALESCE(PES_SCORE::STRING, '0'),
            ', NPS: ', COALESCE(NPS_SCORE::STRING, '0'),
            ', Days Active: ', COALESCE(TOTAL_DAYS_ACTIVE_LAST_30_DAYS::STRING, '0'),
            ', Guides Dismissed: ', COALESCE(GUIDES_DISMISSED_LAST_30_DAYS::STRING, '0'),
            '\nRules: Healthy=PES>60+NPS>30+Active>15. Churning=PES<30 OR Active<5. At-Risk=everything else.\n',
            'Answer (one word only):'
        )
    ) AS risk_classification,
    CASE
        WHEN COALESCE(GUIDES_SEEN_LAST_30_DAYS, 0) = 0 THEN 'No Data'
        WHEN GUIDES_ADVANCED_LAST_30_DAYS::FLOAT / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0) > 0.5 THEN 'Effective'
        WHEN GUIDES_DISMISSED_LAST_30_DAYS::FLOAT / NULLIF(GUIDES_SEEN_LAST_30_DAYS, 0) > 0.5 THEN 'Ignored'
        ELSE 'Underperforming'
    END AS guide_effectiveness,
    CURRENT_TIMESTAMP() AS enriched_at
FROM recent_data;
```

### Exercise 3 — Gold Views (reference)

```sql
-- BU Adoption
CREATE OR REPLACE VIEW MASTERCLASS_DB.COCO_WORKSHOP.GOLD_BU_ADOPTION AS
SELECT
    BU_SEGMENT_C,
    COUNT(*) AS total_accounts,
    AVG(PES_SCORE) AS avg_pes,
    AVG(ADOPTION) AS avg_adoption,
    AVG(STICKINESS) AS avg_stickiness,
    AVG(GROWTH) AS avg_growth,
    SUM(VISITORS_TO_APP_LAST_30_DAYS) AS total_visitors_30d,
    ROUND(SUM(CASE WHEN risk_classification = 'Healthy' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_healthy
FROM MASTERCLASS_DB.COCO_WORKSHOP.SILVER_ACCOUNT_HEALTH
GROUP BY BU_SEGMENT_C
ORDER BY avg_pes DESC;

-- At-Risk Accounts
CREATE OR REPLACE VIEW MASTERCLASS_DB.COCO_WORKSHOP.GOLD_AT_RISK_ACCOUNTS AS
SELECT APP_NAME, ACCOUNT_ID, BU_SEGMENT_C, PES_SCORE, NPS_SCORE,
       TOTAL_DAYS_ACTIVE_LAST_30_DAYS, risk_classification, health_narrative
FROM MASTERCLASS_DB.COCO_WORKSHOP.SILVER_ACCOUNT_HEALTH
WHERE TRIM(risk_classification) IN ('At-Risk', 'Churning')
ORDER BY PES_SCORE ASC;

-- NPS Summary
CREATE OR REPLACE VIEW MASTERCLASS_DB.COCO_WORKSHOP.GOLD_NPS_SUMMARY AS
SELECT
    BU_SEGMENT_C,
    DATE_RECORDED,
    AVG(NPS_SCORE) AS avg_nps,
    SUM(NPS_NUMBER_OF_PROMOTERS) AS total_promoters,
    SUM(NPS_NUMBER_OF_DETRACTERS) AS total_detractors,
    SUM(NPS_NUMBER_OF_PASSIVES) AS total_passives,
    AVG(PES_SCORE) AS avg_pes
FROM PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT
WHERE NPS_NUMBER_OF_RESPONSES > 0
GROUP BY BU_SEGMENT_C, DATE_RECORDED;

-- Guide ROI
CREATE OR REPLACE VIEW MASTERCLASS_DB.COCO_WORKSHOP.GOLD_GUIDE_ROI AS
SELECT
    BU_SEGMENT_C,
    SUM(GUIDES_SEEN_LAST_30_DAYS) AS total_seen,
    SUM(GUIDES_ADVANCED_LAST_30_DAYS) AS total_advanced,
    SUM(GUIDES_DISMISSED_LAST_30_DAYS) AS total_dismissed,
    SUM(GUIDES_SNOOZED_LAST_30_DAYS) AS total_snoozed,
    ROUND(SUM(GUIDES_ADVANCED_LAST_30_DAYS)::FLOAT / NULLIF(SUM(GUIDES_SEEN_LAST_30_DAYS), 0), 3) AS advancement_rate,
    ROUND(SUM(GUIDES_DISMISSED_LAST_30_DAYS)::FLOAT / NULLIF(SUM(GUIDES_SEEN_LAST_30_DAYS), 0), 3) AS dismissal_rate,
    SUM(CASE WHEN guide_effectiveness = 'Effective' THEN 1 ELSE 0 END) AS effective_count,
    SUM(CASE WHEN guide_effectiveness = 'Ignored' THEN 1 ELSE 0 END) AS ignored_count
FROM MASTERCLASS_DB.COCO_WORKSHOP.SILVER_ACCOUNT_HEALTH
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
