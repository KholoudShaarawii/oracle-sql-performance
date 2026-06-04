--------------------------------------------------------------------------------
-- Lab 09: Pagination Strategy
-- OFFSET Pagination vs Keyset Pagination
--
-- Goal:
-- Compare a deep OFFSET page with Keyset pagination.
--
-- Ordering:
-- ORDER BY created_at DESC, order_id DESC
--
-- Important:
-- In DBeaver, run the SELECT query first, fetch the result rows,
-- then run the DISPLAY_CURSOR block directly after it.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Step 1: Create index for pagination ordering
--------------------------------------------------------------------------------

BEGIN
  EXECUTE IMMEDIATE '
    CREATE INDEX ix_opt_orders_created_id
    ON opt_orders(created_at DESC, order_id DESC)
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN
      RAISE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- Step 2: Gather optimizer statistics
--------------------------------------------------------------------------------

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_ORDERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO'
  );
END;
/


--------------------------------------------------------------------------------
-- Step 3: Check the index
--------------------------------------------------------------------------------

SELECT index_name,
       status,
       num_rows,
       leaf_blocks,
       clustering_factor,
       last_analyzed
FROM user_indexes
WHERE table_name = 'OPT_ORDERS'
  AND index_name = 'IX_OPT_ORDERS_CREATED_ID';


--------------------------------------------------------------------------------
-- Step 4: Check index columns
--------------------------------------------------------------------------------

SELECT index_name,
       column_name,
       column_position,
       descend
FROM user_ind_columns
WHERE table_name = 'OPT_ORDERS'
  AND index_name = 'IX_OPT_ORDERS_CREATED_ID'
ORDER BY column_position;


--------------------------------------------------------------------------------
-- Step 5: OFFSET pagination
-- Deep page: skip 30000 rows, then return 20 rows
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_09', 'OFFSET_DEEP_PAGE');

SELECT /*+ gather_plan_statistics */ /* LAB09_OFFSET_DEEP_PAGE */
       order_id,
       customer_id,
       created_at,
       status,
       order_total
FROM opt_orders
ORDER BY created_at DESC, order_id DESC
OFFSET 30000 ROWS FETCH NEXT 20 ROWS ONLY;


--------------------------------------------------------------------------------
-- Step 6: Display actual plan for OFFSET query
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_09'
    AND action = 'OFFSET_DEEP_PAGE'
    AND UPPER(sql_text) LIKE '%LAB09_OFFSET_DEEP_PAGE%'
    AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
    AND UPPER(sql_text) NOT LIKE '%V$SQL%'
  ORDER BY last_active_time DESC
  FETCH FIRST 1 ROW ONLY
)
SELECT p.*
FROM target_sql t
CROSS APPLY TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  t.sql_id,
  t.child_number,
  'ALLSTATS LAST +PREDICATE +COST +NOTE'
)) p;


--------------------------------------------------------------------------------
-- Step 7: Get the last seen key for Keyset pagination
--
-- OFFSET 30000 starts after row number 30000.
-- So we get row number 30000 and use it as the cursor.
--
-- Copy these two values from the result:
-- 1. CURSOR_CREATED_AT
-- 2. CURSOR_ORDER_ID
--------------------------------------------------------------------------------

SELECT cursor_created_at,
       cursor_order_id
FROM (
  SELECT TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') AS cursor_created_at,
         order_id AS cursor_order_id,
         ROW_NUMBER() OVER (
           ORDER BY created_at DESC, order_id DESC
         ) AS rn
  FROM opt_orders
)
WHERE rn = 30000;


--------------------------------------------------------------------------------
-- Step 8: Keyset pagination
--
-- IMPORTANT:
-- Replace:
-- PASTE_CURSOR_CREATED_AT_HERE
-- PASTE_CURSOR_ORDER_ID_HERE
--
-- With the values returned from Step 7.
--
-- Example:
-- TO_DATE('2025-09-01 14:23:10', 'YYYY-MM-DD HH24:MI:SS')
-- order_id < 30000
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_09', 'KEYSET_PAGE');

SELECT /*+ gather_plan_statistics */ /* LAB09_KEYSET_PAGE */
       order_id,
       customer_id,
       created_at,
       status,
       order_total
FROM opt_orders
WHERE created_at < TO_DATE('PASTE_CURSOR_CREATED_AT_HERE', 'YYYY-MM-DD HH24:MI:SS')
   OR (
        created_at = TO_DATE('PASTE_CURSOR_CREATED_AT_HERE', 'YYYY-MM-DD HH24:MI:SS')
        AND order_id < PASTE_CURSOR_ORDER_ID_HERE
      )
ORDER BY created_at DESC, order_id DESC
FETCH NEXT 20 ROWS ONLY;


--------------------------------------------------------------------------------
-- Step 9: Display actual plan for Keyset query
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_09'
    AND action = 'KEYSET_PAGE'
    AND UPPER(sql_text) LIKE '%LAB09_KEYSET_PAGE%'
    AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
    AND UPPER(sql_text) NOT LIKE '%V$SQL%'
  ORDER BY last_active_time DESC
  FETCH FIRST 1 ROW ONLY
)
SELECT p.*
FROM target_sql t
CROSS APPLY TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  t.sql_id,
  t.child_number,
  'ALLSTATS LAST +PREDICATE +COST +NOTE'
)) p;


--------------------------------------------------------------------------------
-- Optional Step 10: Compare OFFSET page and Keyset page
--
-- Replace the same cursor values here too.
-- This is only to check that both methods return the same logical page.
--------------------------------------------------------------------------------

WITH offset_page AS (
  SELECT order_id,
         created_at
  FROM opt_orders
  ORDER BY created_at DESC, order_id DESC
  OFFSET 30000 ROWS FETCH NEXT 20 ROWS ONLY
),
keyset_page AS (
  SELECT order_id,
         created_at
  FROM opt_orders
  WHERE created_at < TO_DATE('PASTE_CURSOR_CREATED_AT_HERE', 'YYYY-MM-DD HH24:MI:SS')
     OR (
          created_at = TO_DATE('PASTE_CURSOR_CREATED_AT_HERE', 'YYYY-MM-DD HH24:MI:SS')
          AND order_id < PASTE_CURSOR_ORDER_ID_HERE
        )
  ORDER BY created_at DESC, order_id DESC
  FETCH NEXT 20 ROWS ONLY
)
SELECT 'OFFSET' AS source_name,
       order_id,
       created_at
FROM offset_page
UNION ALL
SELECT 'KEYSET' AS source_name,
       order_id,
       created_at
FROM keyset_page
ORDER BY created_at DESC, order_id DESC, source_name;