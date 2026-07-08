/*
=============================================================================
  Cortex Code Workshop - Admin Setup Script
  Thomson Reuters | July 2026
  
  Run this BEFORE the workshop as an ACCOUNTADMIN or equivalent.
  This script:
    1. Creates the workshop schema
    2. Extends the existing learner role with CREATE grants
    3. Grants access to the source data table
    4. Verifies AI function access
=============================================================================
*/

-- ============================================================================
-- 1. SCHEMA SETUP
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Create workshop schema for participant-created objects
CREATE SCHEMA IF NOT EXISTS MASTERCLASS_DB.COCO_WORKSHOP;

-- ============================================================================
-- 2. ROLE & PERMISSIONS
-- ============================================================================

-- Extend existing CoWork learner role with CREATE privileges for CoCo exercises
GRANT USAGE ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

GRANT CREATE TABLE ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

GRANT CREATE VIEW ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

GRANT CREATE SEMANTIC VIEW ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

GRANT CREATE STREAMLIT ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- ============================================================================
-- 3. SOURCE DATA ACCESS
-- ============================================================================

-- Grant read access to the Pendo product usage table
GRANT USAGE ON DATABASE PROD TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT USAGE ON SCHEMA PROD.PRODUCT_USAGE TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT SELECT ON TABLE PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- ============================================================================
-- 4. VERIFY ACCESS
-- ============================================================================

USE ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
USE WAREHOUSE WORKSHOP_WH;

-- Verify source table access
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT APP_NAME) AS unique_apps,
       COUNT(DISTINCT BU_SEGMENT_C) AS unique_bus,
       MIN(DATE_RECORDED) AS earliest_date,
       MAX(DATE_RECORDED) AS latest_date
FROM PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT;

-- Verify workshop schema access
USE SCHEMA MASTERCLASS_DB.COCO_WORKSHOP;
CREATE OR REPLACE TEMPORARY TABLE _VERIFY_CREATE (x INT);
DROP TABLE _VERIFY_CREATE;

-- ============================================================================
-- 5. VERIFY AI FUNCTION ACCESS
-- ============================================================================

-- Test that participants can call AI functions
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Say hello in exactly 3 words'
) AS ai_test;

-- ============================================================================
-- 6. CROSS-REGION INFERENCE (if not already enabled)
-- ============================================================================

-- Uncomment if cross-region inference needs to be enabled for Claude/Llama access
-- USE ROLE ACCOUNTADMIN;
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

-- ============================================================================
-- VERIFICATION CHECKLIST
-- ============================================================================
/*
After running this script, verify:
  [ ] MASTERCLASS_DB.COCO_WORKSHOP schema exists
  [ ] Learner role can SELECT from PROD.PRODUCT_USAGE.ACCOUNT_USAGE_BY_PRODUCT
  [ ] Learner role can CREATE TABLE/VIEW/STREAMLIT/SEMANTIC VIEW in COCO_WORKSHOP
  [ ] AI function test returns a response
  [ ] Source table has data (check row count and date range)
*/
