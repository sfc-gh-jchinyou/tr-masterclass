/*
=============================================================================
  Cortex Code Workshop - Admin Setup Script
  Thomson Reuters | July 2026
  
  Run this BEFORE the workshop as an ACCOUNTADMIN or equivalent.
  This script:
    1. Creates the shared workshop schema + seeds data (or verifies existing)
    2. Creates per-attendee databases
    3. Grants permissions
    4. Verifies access
=============================================================================
*/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- 1. SHARED SOURCE TABLE
-- ============================================================================

-- The base table lives in a shared schema that all participants can read from.
-- Either it already exists (real Pendo data) or run seed_data.sql to generate it.
CREATE SCHEMA IF NOT EXISTS MASTERCLASS_DB.COCO_WORKSHOP;

-- Verify source table exists
SELECT COUNT(*) AS source_row_count
FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT;

-- ============================================================================
-- 2. PER-ATTENDEE DATABASES
-- ============================================================================

-- Each participant gets their own database for creating Silver/Gold tables,
-- Semantic Views, and Streamlit apps. This keeps work isolated and avoids
-- naming conflicts.
--
-- Naming convention: COCO_WORKSHOP_<USERNAME>
-- Replace <USERNAME> placeholders below with actual attendee usernames.

-- === COPY THIS BLOCK FOR EACH ATTENDEE ===
-- Attendee 1
CREATE DATABASE IF NOT EXISTS COCO_WORKSHOP_JSMITH;
GRANT OWNERSHIP ON DATABASE COCO_WORKSHOP_JSMITH TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT ALL ON DATABASE COCO_WORKSHOP_JSMITH TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- Attendee 2
CREATE DATABASE IF NOT EXISTS COCO_WORKSHOP_JDOE;
GRANT OWNERSHIP ON DATABASE COCO_WORKSHOP_JDOE TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT ALL ON DATABASE COCO_WORKSHOP_JDOE TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- (Add more attendees as needed...)
-- === END ATTENDEE BLOCK ===

-- ============================================================================
-- 3. SHARED READ ACCESS
-- ============================================================================

-- Grant read access to the shared source table
GRANT USAGE ON DATABASE MASTERCLASS_DB TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT USAGE ON SCHEMA MASTERCLASS_DB.COCO_WORKSHOP TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
GRANT SELECT ON TABLE MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT
    TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- Grant CORTEX_USER for AI functions (bonus exercises)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- Warehouse access
GRANT USAGE ON WAREHOUSE WORKSHOP_WH TO ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;

-- ============================================================================
-- 4. VERIFY ACCESS
-- ============================================================================

USE ROLE SNFL_INTL_MASTERCLASS_LEARNER_ROLE;
USE WAREHOUSE WORKSHOP_WH;

-- Can read source table?
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT APP_NAME) AS unique_apps,
       COUNT(DISTINCT BU_SEGMENT_C) AS unique_bus
FROM MASTERCLASS_DB.COCO_WORKSHOP.ACCOUNT_USAGE_BY_PRODUCT;

-- Can create objects in personal DB? (test with first attendee DB)
USE DATABASE COCO_WORKSHOP_JSMITH;
USE SCHEMA PUBLIC;
CREATE OR REPLACE TEMPORARY TABLE _VERIFY_CREATE (x INT);
DROP TABLE _VERIFY_CREATE;

-- ============================================================================
-- 5. CROSS-REGION INFERENCE (if not already enabled)
-- ============================================================================

-- Uncomment if needed for Claude/Llama model access in bonus exercises
-- USE ROLE ACCOUNTADMIN;
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

-- ============================================================================
-- VERIFICATION CHECKLIST
-- ============================================================================
/*
After running this script, verify:
  [ ] Source table has 10,000+ rows in MASTERCLASS_DB.COCO_WORKSHOP
  [ ] Each attendee's COCO_WORKSHOP_<USERNAME> database exists
  [ ] Learner role can SELECT from the shared source table
  [ ] Learner role can CREATE TABLE/VIEW/STREAMLIT/SEMANTIC VIEW in personal DBs
  [ ] Warehouse is accessible
  [ ] (Optional) AI function test passes for bonus exercises
*/
