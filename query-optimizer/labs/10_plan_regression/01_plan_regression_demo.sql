--------------------------------------------------------------------------------
-- Lab 11 — Plan Regression
-- Guaranteed Demo Version
--
-- Goal:
-- Same SQL text.
-- Before: Oracle uses an index.
-- After : Oracle cannot use the index, so it switches to TABLE ACCESS FULL.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 0) Make sure Oracle does NOT use invisible indexes
--------------------------------------------------------------------------------

ALTER SESSION SET optimizer_use_invisible_indexes = FALSE;


--------------------------------------------------------------------------------
-- 1) Clean old lab index if it already exists
-- If this block gives an error in your tool, just ignore it and continue.
--------------------------------------------------------------------------------

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX ix_lab11_orders_oid_char';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1418 THEN
      RAISE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 2) Create a lab-only function-based index
-- This index supports the predicate: TO_CHAR(order_id) = '12345'
--------------------------------------------------------------------------------

CREATE INDEX ix_lab11_orders_oid_char
ON opt_orders (TO_CHAR(order_id));


--------------------------------------------------------------------------------
-- 3) Gather stats for the new lab index
--------------------------------------------------------------------------------

BEGIN
  DBMS_STATS.GATHER_INDEX_STATS(USER, 'IX_LAB11_ORDERS_OID_CHAR');
END;
/


--------------------------------------------------------------------------------
-- 4) Make sure the lab index is visible before the BEFORE test
--------------------------------------------------------------------------------

ALTER INDEX ix_lab11_orders_oid_char VISIBLE;


--------------------------------------------------------------------------------
-- 5) Check index status before starting
--------------------------------------------------------------------------------

SELECT index_name,
       visibility,
       status
FROM user_indexes
WHERE index_name = 'IX_LAB11_ORDERS_OID_CHAR';


--------------------------------------------------------------------------------
-- 6) BEFORE regression
-- Index is visible
-- Expected plan: INDEX RANGE SCAN + TABLE ACCESS BY INDEX ROWID
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_11', 'BEFORE_INDEX_VISIBLE');

SELECT /*+ gather_plan_statistics */ /* OPTLAB_REGRESSION_DEMO_GUARANTEED */
       order_id,
       customer_id,
       status,
       city,
       order_total
FROM opt_orders
WHERE TO_CHAR(order_id) = '12345';


--------------------------------------------------------------------------------
-- 7) Find SQL_ID and PLAN_HASH_VALUE for BEFORE
--------------------------------------------------------------------------------

SELECT sql_id,
       child_number,
       plan_hash_value,
       executions,
       rows_processed,
       elapsed_time,
       cpu_time,
       buffer_gets,
       disk_reads,
       last_active_time
FROM v$sql
WHERE module = 'OPT_LAB_11'
  AND action = 'BEFORE_INDEX_VISIBLE'
  AND UPPER(sql_text)
  LIKE '%OPTLAB_REGRESSION_DEMO_GUARANTEED%'
  AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
  AND UPPER(sql_text) NOT LIKE '%V$SQL%'
ORDER BY last_active_time DESC
FETCH FIRST 1 ROW ONLY;


--------------------------------------------------------------------------------
-- 8) Display actual execution plan for BEFORE
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_11'
    AND action = 'BEFORE_INDEX_VISIBLE'
    AND UPPER(sql_text) LIKE '%OPTLAB_REGRESSION_DEMO_GUARANTEED%'
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
-- 9) Make the lab index invisible
-- This simulates the access path becoming unavailable
--------------------------------------------------------------------------------

ALTER INDEX ix_lab11_orders_oid_char INVISIBLE;


--------------------------------------------------------------------------------
-- 10) Check index status after making it invisible
--------------------------------------------------------------------------------

SELECT index_name,
       visibility,
       status
FROM user_indexes
WHERE index_name = 'IX_LAB11_ORDERS_OID_CHAR';

--------------------------------------------------------------------------------
-- AFTER regression
-- Make the lab index invisible
--------------------------------------------------------------------------------

ALTER INDEX ix_lab11_orders_oid_char INVISIBLE;


--------------------------------------------------------------------------------
-- Confirm the index is invisible
--------------------------------------------------------------------------------

SELECT index_name,
       visibility,
       status
FROM user_indexes
WHERE index_name = 'IX_LAB11_ORDERS_OID_CHAR';


--------------------------------------------------------------------------------
-- Set module/action for AFTER
--------------------------------------------------------------------------------

BEGIN
  DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_11', 'AFTER_INDEX_INVISIBLE');
END;
/


--------------------------------------------------------------------------------
-- Run AFTER query
-- Same logical query, but different marker comment so we can find it easily
--------------------------------------------------------------------------------

SELECT /*+ gather_plan_statistics */ /* OPTLAB_REGRESSION_DEMO_AFTER */
       order_id,
       customer_id,
       status,
       city,
       order_total
FROM opt_orders
WHERE TO_CHAR(order_id) = '12345';


--------------------------------------------------------------------------------
-- Find SQL_ID and PLAN_HASH_VALUE for AFTER
--------------------------------------------------------------------------------

SELECT sql_id,
       child_number,
       plan_hash_value,
       executions,
       rows_processed,
       elapsed_time,
       cpu_time,
       buffer_gets,
       disk_reads,
       last_active_time
FROM v$sql
WHERE UPPER(sql_text) LIKE '%OPTLAB_REGRESSION_DEMO_AFTER%'
  AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
  AND UPPER(sql_text) NOT LIKE '%V$SQL%'
ORDER BY last_active_time DESC
FETCH FIRST 1 ROW ONLY;


--------------------------------------------------------------------------------
-- Display actual execution plan for AFTER
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE UPPER(sql_text) LIKE '%OPTLAB_REGRESSION_DEMO_AFTER%'
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
-- Restore the index after finishing the lab
--------------------------------------------------------------------------------

ALTER INDEX ix_lab11_orders_oid_char VISIBLE;