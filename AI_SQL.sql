-- 30-second AI SQL demo: create demo table, then run AI_COMPLETE, AI_EXTRACT, and AI_CLASSIFY separately
-- Co-authored with CoCo

-- SETUP: Create demo table with sample support tickets ───────────────────
-- CREATE OR REPLACE TABLE TEMP.MWIES.AI_SQL_DEMO (
--     id          INT,
--     ticket_text VARCHAR
-- ) AS
-- SELECT * FROM (VALUES
--     (1, 'My laptop screen went black after the latest update. Order #LT-8821.'),
--     (2, 'Loving the new dashboard! Just one thing – the export button is broken.'),
--     (3, 'I was charged twice for my subscription on March 3rd. Please refund ASAP!')
-- ) AS t(id, ticket_text);

-- RAW TABLE
SELECT * FROM TEMP.MWIES.AI_SQL_DEMO;

-- ──  AI_COMPLETE — draft a one-line empathetic reply per ticket ───────
SELECT
    id,
    ticket_text,
    AI_COMPLETE(
        'llama3.1-70b',
        CONCAT('Write a one-sentence empathetic support reply to: ', ticket_text)
    ) AS suggested_reply
FROM TEMP.MWIES.AI_SQL_DEMO
ORDER BY id;


-- ── AI_EXTRACT — pull structured fields from free text ───────────────
SELECT
    id,
    ticket_text,
    AI_EXTRACT(
        ticket_text,
        ['order_number', 'issue_type', 'date_mentioned']
    ) AS extracted_fields
FROM TEMP.MWIES.AI_SQL_DEMO
ORDER BY id;


-- ── AI_CLASSIFY — route ticket to the right support team ─────────────
SELECT
    id,
    ticket_text,
    AI_CLASSIFY(
        ticket_text,
        ['Hardware', 'Billing', 'Feature Request', 'Bug Report']
    ) AS category
FROM TEMP.MWIES.AI_SQL_DEMO
ORDER BY id;
