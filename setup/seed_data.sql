/*
=============================================================================
  Cortex Code Workshop - Synthetic Data Generation
  Thomson Reuters | July 2026
  
  Generates ~10,000+ rows of realistic Pendo product usage data.
  Table created in MASTERCLASS_DB.COCO_WORKSHOP (same as admin_setup.sql).
  Run AFTER admin_setup.sql.
=============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WORKSHOP_WH;
USE SCHEMA MASTERCLASS_DB.COCO_WORKSHOP;

-- Create the table
CREATE OR REPLACE TABLE MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT (
    SUBSCRIPTION_NAME VARCHAR(22),
    APP_ID VARCHAR(256),
    APP_NAME VARCHAR(256),
    ACCOUNT_ID VARCHAR(1024),
    TOTAL_EVENTS_BY_DAY NUMBER(38,0),
    AVG_EVENTS_BY_VISITOR_BY_DAY NUMBER(38,6),
    TOTAL_TIME_ON_APP_BY_DAY NUMBER(38,0),
    AVG_TIME_ON_APP_BY_VISITOR_BY_DAY NUMBER(38,6),
    VISITORS_TO_APP_BY_DAY NUMBER(18,0),
    VISITORS_TO_ALL_APPS_OF_ACCOUNT_BY_DAY NUMBER(18,0),
    GUIDES_SEEN_BY_DAY NUMBER(18,0),
    GUIDES_SNOOZED_BY_DAY NUMBER(18,0),
    GUIDES_ADVANCED_BY_DAY NUMBER(18,0),
    GUIDES_DISMISSED_BY_DAY NUMBER(18,0),
    TOTAL_DAYS_ACTIVE_LAST_30_DAYS NUMBER(18,0),
    AVG_DAYS_ACTIVE_BY_VISITOR_LAST_30_DAYS NUMBER(24,6),
    TOTAL_EVENTS_LAST_30_DAYS NUMBER(38,0),
    AVG_EVENTS_BY_VISITOR_LAST_30_DAYS NUMBER(38,6),
    TOTAL_TIME_ON_APP_LAST_30_DAYS NUMBER(38,0),
    AVG_TIME_ON_APP_BY_VISITOR_LAST_30_DAYS NUMBER(38,6),
    VISITORS_TO_APP_LAST_30_DAYS NUMBER(18,0),
    VISITORS_TO_ALL_APPS_OF_ACCOUNT_LAST_30_DAYS NUMBER(18,0),
    GUIDES_SEEN_LAST_30_DAYS NUMBER(18,0),
    GUIDES_SNOOZED_LAST_30_DAYS NUMBER(18,0),
    GUIDES_ADVANCED_LAST_30_DAYS NUMBER(18,0),
    GUIDES_DISMISSED_LAST_30_DAYS NUMBER(18,0),
    FIRST_VISIT_AT DATE,
    PNPS_SUBMISSION_COUNT NUMBER(18,0),
    PNPS_VISITOR_SUBMISSION_COUNT NUMBER(18,0),
    PNPS_AVERAGE NUMBER(38,6),
    PNPS_MAX NUMBER(38,0),
    PNPS_MIN NUMBER(38,0),
    PNPS_GUIDE_ID VARCHAR(256),
    PNPS_NUMBER_OF_RESPONSES NUMBER(18,0),
    PNPS_NUMBER_OF_PROMOTERS NUMBER(13,0),
    PNPS_NUMBER_OF_DETRACTERS NUMBER(13,0),
    PNPS_NUMBER_OF_PASSIVES NUMBER(13,0),
    PNPS_AVERAGE_RATING FLOAT,
    PNPS_SCORE NUMBER(20,6),
    NPS_SUBMISSION_COUNT NUMBER(18,0),
    NPS_VISITOR_SUBMISSION_COUNT NUMBER(18,0),
    NPS_AVERAGE NUMBER(38,6),
    NPS_MAX NUMBER(38,0),
    NPS_MIN NUMBER(38,0),
    NPS_NUMBER_OF_RESPONSES NUMBER(18,0),
    NPS_NUMBER_OF_PROMOTERS NUMBER(13,0),
    NPS_NUMBER_OF_DETRACTERS NUMBER(13,0),
    NPS_NUMBER_OF_PASSIVES NUMBER(13,0),
    NPS_AVERAGE_RATING FLOAT,
    NPS_SCORE NUMBER(20,6),
    PES_SCORE NUMBER(7,4),
    ADOPTION NUMBER(7,4),
    STICKINESS NUMBER(7,4),
    GROWTH NUMBER(7,4),
    SUBSCRIPTION_ID VARCHAR(16),
    BU_SEGMENT_C VARCHAR(256),
    BU_SEGMENT_LEVEL_2_C VARCHAR(256),
    BU_SEGMENT_LEVEL_3_C VARCHAR(256),
    DATE_RECORDED DATE,
    ACCOUNT_DATE_RANGE_FROM DATE,
    ACCOUNT_DATE_RANGE_TO DATE,
    DATA_DISPLAY_DATE_RANGE_LAST_30_DAYS VARCHAR(256)
);

-- Generate 10,000+ rows of synthetic data
INSERT INTO MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
WITH
-- 12 TR apps
apps AS (
    SELECT column1 AS app_id, column2 AS app_name FROM VALUES
        ('APP-001', 'Westlaw Edge'),
        ('APP-002', 'Practical Law'),
        ('APP-003', 'Checkpoint Edge'),
        ('APP-004', 'ONESOURCE Tax'),
        ('APP-005', 'Eikon'),
        ('APP-006', 'Workspace'),
        ('APP-007', 'HighQ'),
        ('APP-008', 'Legal Tracker'),
        ('APP-009', 'Contract Express'),
        ('APP-010', 'CLEAR'),
        ('APP-011', 'Confirma'),
        ('APP-012', 'Panoramic')
),
-- 50 accounts across tiers
accounts AS (
    SELECT
        'ACCT-' || LPAD(seq4()::STRING, 5, '0') AS account_id,
        'SUB-TR-' || LPAD((seq4() / 5 + 1)::STRING, 3, '0') AS subscription_id,
        CASE
            WHEN seq4() < 15 THEN 'Enterprise'
            WHEN seq4() < 35 THEN 'Mid-Market'
            ELSE 'Small Business'
        END AS tier
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
),
-- BU segments (9 combinations)
bus AS (
    SELECT column1 AS bu_segment_c, column2 AS bu_segment_level_2_c, column3 AS bu_segment_level_3_c FROM VALUES
        ('Legal Professionals', 'Legal Research', 'Westlaw'),
        ('Legal Professionals', 'Legal Research', 'Practical Law'),
        ('Legal Professionals', 'Legal Operations', 'Legal Tracker'),
        ('Tax & Accounting', 'Tax Compliance', 'ONESOURCE'),
        ('Tax & Accounting', 'Tax Research', 'Checkpoint'),
        ('Corporates', 'Legal', 'Contract Management'),
        ('Corporates', 'Risk & Compliance', 'CLEAR'),
        ('Reuters News', 'Financial Data', 'Eikon'),
        ('Reuters News', 'Financial Data', 'Workspace')
),
-- 90 days of records
dates AS (
    SELECT DATEADD('day', -seq4(), CURRENT_DATE()) AS date_recorded
    FROM TABLE(GENERATOR(ROWCOUNT => 90))
),
-- Cross join with filtering to get ~10,000+ rows
-- 50 accounts × 12 apps × 9 BUs × 90 days = 486,000 possible combos
-- Filter to ~0.25% = ~12,000 rows
base AS (
    SELECT
        a.account_id,
        a.subscription_id,
        a.tier,
        ap.app_id,
        ap.app_name,
        b.bu_segment_c,
        b.bu_segment_level_2_c,
        b.bu_segment_level_3_c,
        d.date_recorded,
        ABS(HASH(a.account_id || ap.app_id || d.date_recorded::STRING || b.bu_segment_c)) AS seed
    FROM accounts a
    CROSS JOIN apps ap
    CROSS JOIN bus b
    CROSS JOIN dates d
    -- Each account uses 2-3 apps in 1-2 BU segments across most days
    WHERE MOD(ABS(HASH(a.account_id || ap.app_id)), 100) < 25
      AND MOD(ABS(HASH(a.account_id || b.bu_segment_c)), 100) < 20
      AND MOD(ABS(HASH(a.account_id || ap.app_id || d.date_recorded::STRING)), 100) < 70
),
-- Assign health profiles
profiled AS (
    SELECT *,
        CASE
            WHEN MOD(ABS(HASH(account_id || app_id)), 100) < 45 THEN 'healthy'
            WHEN MOD(ABS(HASH(account_id || app_id)), 100) < 80 THEN 'at_risk'
            ELSE 'churning'
        END AS health_profile
    FROM base
)
SELECT
    LEFT(subscription_id, 22) AS SUBSCRIPTION_NAME,
    app_id AS APP_ID,
    app_name AS APP_NAME,
    account_id AS ACCOUNT_ID,

    -- Daily metrics
    CASE health_profile
        WHEN 'healthy' THEN 50 + MOD(seed, 200)
        WHEN 'at_risk' THEN 10 + MOD(seed, 50)
        ELSE MOD(seed, 15)
    END AS TOTAL_EVENTS_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN 8.0 + MOD(seed, 20) / 10.0
        WHEN 'at_risk' THEN 3.0 + MOD(seed, 10) / 10.0
        ELSE 1.0 + MOD(seed, 5) / 10.0
    END AS AVG_EVENTS_BY_VISITOR_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN 1200 + MOD(seed, 3600)
        WHEN 'at_risk' THEN 300 + MOD(seed, 900)
        ELSE MOD(seed, 300)
    END AS TOTAL_TIME_ON_APP_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN 180.0 + MOD(seed, 600) / 10.0
        WHEN 'at_risk' THEN 60.0 + MOD(seed, 300) / 10.0
        ELSE 10.0 + MOD(seed, 100) / 10.0
    END AS AVG_TIME_ON_APP_BY_VISITOR_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN 10 + MOD(seed, 40)
        WHEN 'at_risk' THEN 3 + MOD(seed, 12)
        ELSE MOD(seed, 4)
    END AS VISITORS_TO_APP_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN 20 + MOD(seed, 80)
        WHEN 'at_risk' THEN 8 + MOD(seed, 25)
        ELSE 2 + MOD(seed, 8)
    END AS VISITORS_TO_ALL_APPS_OF_ACCOUNT_BY_DAY,

    -- Guides daily
    CASE health_profile
        WHEN 'healthy' THEN MOD(seed, 5)
        WHEN 'at_risk' THEN MOD(seed, 8)
        ELSE MOD(seed, 3)
    END AS GUIDES_SEEN_BY_DAY,

    MOD(seed + 1, 2) AS GUIDES_SNOOZED_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN MOD(seed, 4)
        WHEN 'at_risk' THEN MOD(seed, 2)
        ELSE 0
    END AS GUIDES_ADVANCED_BY_DAY,

    CASE health_profile
        WHEN 'healthy' THEN MOD(seed, 2)
        WHEN 'at_risk' THEN MOD(seed, 4)
        ELSE MOD(seed, 3)
    END AS GUIDES_DISMISSED_BY_DAY,

    -- 30-day rollups
    CASE health_profile
        WHEN 'healthy' THEN 18 + MOD(seed, 12)
        WHEN 'at_risk' THEN 8 + MOD(seed, 10)
        ELSE MOD(seed, 5)
    END AS TOTAL_DAYS_ACTIVE_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 12.0 + MOD(seed, 80) / 10.0
        WHEN 'at_risk' THEN 5.0 + MOD(seed, 50) / 10.0
        ELSE 1.0 + MOD(seed, 20) / 10.0
    END AS AVG_DAYS_ACTIVE_BY_VISITOR_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 1500 + MOD(seed, 5000)
        WHEN 'at_risk' THEN 300 + MOD(seed, 1500)
        ELSE MOD(seed, 200)
    END AS TOTAL_EVENTS_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 120.0 + MOD(seed, 500) / 10.0
        WHEN 'at_risk' THEN 30.0 + MOD(seed, 200) / 10.0
        ELSE 5.0 + MOD(seed, 50) / 10.0
    END AS AVG_EVENTS_BY_VISITOR_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 36000 + MOD(seed, 100000)
        WHEN 'at_risk' THEN 9000 + MOD(seed, 27000)
        ELSE MOD(seed, 5000)
    END AS TOTAL_TIME_ON_APP_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 2400.0 + MOD(seed, 6000) / 10.0
        WHEN 'at_risk' THEN 600.0 + MOD(seed, 3000) / 10.0
        ELSE 50.0 + MOD(seed, 500) / 10.0
    END AS AVG_TIME_ON_APP_BY_VISITOR_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 25 + MOD(seed, 100)
        WHEN 'at_risk' THEN 8 + MOD(seed, 30)
        ELSE MOD(seed, 6)
    END AS VISITORS_TO_APP_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 50 + MOD(seed, 150)
        WHEN 'at_risk' THEN 15 + MOD(seed, 50)
        ELSE 3 + MOD(seed, 10)
    END AS VISITORS_TO_ALL_APPS_OF_ACCOUNT_LAST_30_DAYS,

    -- Guides 30-day
    CASE health_profile
        WHEN 'healthy' THEN 15 + MOD(seed, 40)
        WHEN 'at_risk' THEN 20 + MOD(seed, 50)
        ELSE MOD(seed, 10)
    END AS GUIDES_SEEN_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 2 + MOD(seed, 5)
        WHEN 'at_risk' THEN 5 + MOD(seed, 10)
        ELSE MOD(seed, 3)
    END AS GUIDES_SNOOZED_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 10 + MOD(seed, 25)
        WHEN 'at_risk' THEN 3 + MOD(seed, 8)
        ELSE MOD(seed, 2)
    END AS GUIDES_ADVANCED_LAST_30_DAYS,

    CASE health_profile
        WHEN 'healthy' THEN 2 + MOD(seed, 5)
        WHEN 'at_risk' THEN 10 + MOD(seed, 20)
        ELSE 5 + MOD(seed, 8)
    END AS GUIDES_DISMISSED_LAST_30_DAYS,

    -- First visit
    DATEADD('day', -180 - MOD(seed, 720), CURRENT_DATE()) AS FIRST_VISIT_AT,

    -- PNPS
    CASE WHEN MOD(seed, 3) = 0 THEN MOD(seed, 10) ELSE NULL END AS PNPS_SUBMISSION_COUNT,
    CASE WHEN MOD(seed, 3) = 0 THEN MOD(seed, 8) ELSE NULL END AS PNPS_VISITOR_SUBMISSION_COUNT,
    CASE health_profile
        WHEN 'healthy' THEN 7.5 + MOD(seed, 20) / 10.0
        WHEN 'at_risk' THEN 5.0 + MOD(seed, 20) / 10.0
        ELSE 2.0 + MOD(seed, 30) / 10.0
    END AS PNPS_AVERAGE,
    CASE health_profile WHEN 'healthy' THEN 10 WHEN 'at_risk' THEN 8 ELSE 6 END AS PNPS_MAX,
    CASE health_profile WHEN 'healthy' THEN 5 WHEN 'at_risk' THEN 2 ELSE 0 END AS PNPS_MIN,
    'guide-pnps-' || MOD(seed, 5)::STRING AS PNPS_GUIDE_ID,
    CASE WHEN MOD(seed, 3) = 0 THEN 5 + MOD(seed, 20) ELSE NULL END AS PNPS_NUMBER_OF_RESPONSES,
    CASE WHEN MOD(seed, 3) = 0 THEN
        CASE health_profile WHEN 'healthy' THEN 3 + MOD(seed, 5) WHEN 'at_risk' THEN 1 + MOD(seed, 3) ELSE MOD(seed, 2) END
    ELSE NULL END AS PNPS_NUMBER_OF_PROMOTERS,
    CASE WHEN MOD(seed, 3) = 0 THEN
        CASE health_profile WHEN 'healthy' THEN MOD(seed, 2) WHEN 'at_risk' THEN 2 + MOD(seed, 3) ELSE 3 + MOD(seed, 4) END
    ELSE NULL END AS PNPS_NUMBER_OF_DETRACTERS,
    CASE WHEN MOD(seed, 3) = 0 THEN 2 + MOD(seed, 5) ELSE NULL END AS PNPS_NUMBER_OF_PASSIVES,
    CASE health_profile
        WHEN 'healthy' THEN 8.0 + MOD(seed, 15) / 10.0
        WHEN 'at_risk' THEN 5.5 + MOD(seed, 20) / 10.0
        ELSE 3.0 + MOD(seed, 20) / 10.0
    END AS PNPS_AVERAGE_RATING,
    CASE health_profile
        WHEN 'healthy' THEN 40.0 + MOD(seed, 40)
        WHEN 'at_risk' THEN -10.0 + MOD(seed, 30)
        ELSE -50.0 + MOD(seed, 30)
    END AS PNPS_SCORE,

    -- NPS
    CASE WHEN MOD(seed, 2) = 0 THEN MOD(seed, 15) ELSE NULL END AS NPS_SUBMISSION_COUNT,
    CASE WHEN MOD(seed, 2) = 0 THEN MOD(seed, 12) ELSE NULL END AS NPS_VISITOR_SUBMISSION_COUNT,
    CASE health_profile
        WHEN 'healthy' THEN 7.0 + MOD(seed, 25) / 10.0
        WHEN 'at_risk' THEN 4.5 + MOD(seed, 25) / 10.0
        ELSE 2.0 + MOD(seed, 25) / 10.0
    END AS NPS_AVERAGE,
    CASE health_profile WHEN 'healthy' THEN 10 WHEN 'at_risk' THEN 8 ELSE 5 END AS NPS_MAX,
    CASE health_profile WHEN 'healthy' THEN 4 WHEN 'at_risk' THEN 1 ELSE 0 END AS NPS_MIN,
    CASE WHEN MOD(seed, 2) = 0 THEN 8 + MOD(seed, 25) ELSE NULL END AS NPS_NUMBER_OF_RESPONSES,
    CASE WHEN MOD(seed, 2) = 0 THEN
        CASE health_profile WHEN 'healthy' THEN 5 + MOD(seed, 8) WHEN 'at_risk' THEN 2 + MOD(seed, 4) ELSE MOD(seed, 2) END
    ELSE NULL END AS NPS_NUMBER_OF_PROMOTERS,
    CASE WHEN MOD(seed, 2) = 0 THEN
        CASE health_profile WHEN 'healthy' THEN MOD(seed, 2) WHEN 'at_risk' THEN 3 + MOD(seed, 4) ELSE 5 + MOD(seed, 5) END
    ELSE NULL END AS NPS_NUMBER_OF_DETRACTERS,
    CASE WHEN MOD(seed, 2) = 0 THEN 3 + MOD(seed, 6) ELSE NULL END AS NPS_NUMBER_OF_PASSIVES,
    CASE health_profile
        WHEN 'healthy' THEN 7.5 + MOD(seed, 20) / 10.0
        WHEN 'at_risk' THEN 5.0 + MOD(seed, 20) / 10.0
        ELSE 3.0 + MOD(seed, 15) / 10.0
    END AS NPS_AVERAGE_RATING,
    CASE health_profile
        WHEN 'healthy' THEN 35.0 + MOD(seed, 45)
        WHEN 'at_risk' THEN -5.0 + MOD(seed, 25)
        ELSE -40.0 + MOD(seed, 20)
    END AS NPS_SCORE,

    -- PES Score (0-100 scale)
    CASE health_profile
        WHEN 'healthy' THEN 62.0 + MOD(seed, 30) / 10.0
        WHEN 'at_risk' THEN 32.0 + MOD(seed, 28) / 10.0
        ELSE 8.0 + MOD(seed, 20) / 10.0
    END AS PES_SCORE,

    CASE health_profile
        WHEN 'healthy' THEN 65.0 + MOD(seed, 25) / 10.0
        WHEN 'at_risk' THEN 35.0 + MOD(seed, 25) / 10.0
        ELSE 10.0 + MOD(seed, 20) / 10.0
    END AS ADOPTION,

    CASE health_profile
        WHEN 'healthy' THEN 60.0 + MOD(seed, 30) / 10.0
        WHEN 'at_risk' THEN 30.0 + MOD(seed, 25) / 10.0
        ELSE 5.0 + MOD(seed, 20) / 10.0
    END AS STICKINESS,

    CASE health_profile
        WHEN 'healthy' THEN 55.0 + MOD(seed, 35) / 10.0
        WHEN 'at_risk' THEN 25.0 + MOD(seed, 30) / 10.0
        ELSE -5.0 + MOD(seed, 20) / 10.0
    END AS GROWTH,

    -- Subscription & BU
    subscription_id AS SUBSCRIPTION_ID,
    bu_segment_c AS BU_SEGMENT_C,
    bu_segment_level_2_c AS BU_SEGMENT_LEVEL_2_C,
    bu_segment_level_3_c AS BU_SEGMENT_LEVEL_3_C,

    -- Dates
    date_recorded AS DATE_RECORDED,
    DATEADD('day', -30, date_recorded) AS ACCOUNT_DATE_RANGE_FROM,
    date_recorded AS ACCOUNT_DATE_RANGE_TO,
    TO_CHAR(DATEADD('day', -30, date_recorded), 'YYYY-MM-DD') || ' to ' || TO_CHAR(date_recorded, 'YYYY-MM-DD')
        AS DATA_DISPLAY_DATE_RANGE_LAST_30_DAYS

FROM profiled;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ACCOUNT_ID) AS unique_accounts,
    COUNT(DISTINCT APP_NAME) AS unique_apps,
    COUNT(DISTINCT BU_SEGMENT_C) AS unique_bus,
    MIN(DATE_RECORDED) AS earliest_date,
    MAX(DATE_RECORDED) AS latest_date,
    ROUND(AVG(PES_SCORE), 1) AS avg_pes,
    ROUND(AVG(NPS_SCORE), 1) AS avg_nps
FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT;

-- Verify health distribution matches workshop expectations
SELECT
    CASE
        WHEN PES_SCORE < 30 OR TOTAL_DAYS_ACTIVE_LAST_30_DAYS < 5 THEN 'Churning'
        WHEN PES_SCORE > 60 AND NPS_SCORE > 30 AND TOTAL_DAYS_ACTIVE_LAST_30_DAYS > 15 THEN 'Healthy'
        ELSE 'At-Risk'
    END AS expected_risk_tier,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct,
    ROUND(AVG(PES_SCORE), 1) AS avg_pes,
    ROUND(AVG(NPS_SCORE), 1) AS avg_nps,
    ROUND(AVG(TOTAL_DAYS_ACTIVE_LAST_30_DAYS), 1) AS avg_days_active
FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
GROUP BY 1
ORDER BY 1;

-- Grant SELECT to workshop role
GRANT SELECT ON TABLE MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
