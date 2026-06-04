--------------------------------------------------------------------------------
-- Lab 10 — Endpoint DB Verdict
-- Scenario A + Scenario B
-- Goal: Decide whether the database query is the bottleneck or not.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Scenario A: Healthy Query by Primary Key
-- Expected: Fast query, low A-Time, low Buffers, accurate E-Rows vs A-Rows
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_10', 'SCENARIO_A_HEALTHY_QUERY');

SELECT /*+ gather_plan_statistics */ /* LAB10_SCENARIO_A_HEALTHY_QUERY */
       order_id,
       customer_id,
       status,
       city,
       order_total,
       created_at
FROM opt_orders
WHERE order_id = 12345;


--------------------------------------------------------------------------------
-- Scenario A: Get SQL_ID and PLAN_HASH_VALUE
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
WHERE module = 'OPT_LAB_10'
  AND action = 'SCENARIO_A_HEALTHY_QUERY'
  AND UPPER(sql_text) LIKE '%LAB10_SCENARIO_A_HEALTHY_QUERY%'
  AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
  AND UPPER(sql_text) NOT LIKE '%V$SQL%'
ORDER BY last_active_time DESC
FETCH FIRST 1 ROW ONLY;


--------------------------------------------------------------------------------
-- Scenario A: Display Actual Execution Plan
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_10'
    AND action = 'SCENARIO_A_HEALTHY_QUERY'
    AND UPPER(sql_text) LIKE '%LAB10_SCENARIO_A_HEALTHY_QUERY%'
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
-- Scenario B: Bigger / Suspicious Query
-- Expected: Check join method, sort, A-Time, Buffers, E-Rows vs A-Rows, Temp
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_10', 'SCENARIO_B_SUSPICIOUS_QUERY');

SELECT /*+ gather_plan_statistics */ /* LAB10_SCENARIO_B_SUSPICIOUS_QUERY */
       c.customer_id,
       c.full_name,
       o.order_id,
       o.status,
       o.order_total,
       o.created_at
FROM opt_customers c
JOIN opt_orders o
  ON o.customer_id = c.customer_id
WHERE c.city = 'Cairo'
  AND o.status = 'PAID'
ORDER BY o.created_at DESC;


--------------------------------------------------------------------------------
-- Scenario B: Get SQL_ID and PLAN_HASH_VALUE
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
WHERE module = 'OPT_LAB_10'
  AND action = 'SCENARIO_B_SUSPICIOUS_QUERY'
  AND UPPER(sql_text) LIKE '%LAB10_SCENARIO_B_SUSPICIOUS_QUERY%'
  AND UPPER(sql_text) LIKE '%OPT_CUSTOMERS%'
  AND UPPER(sql_text) LIKE '%OPT_ORDERS%'
  AND UPPER(sql_text) NOT LIKE '%V$SQL%'
ORDER BY last_active_time DESC
FETCH FIRST 1 ROW ONLY;


--------------------------------------------------------------------------------
-- Scenario B: Display Actual Execution Plan
--------------------------------------------------------------------------------

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_10'
    AND action = 'SCENARIO_B_SUSPICIOUS_QUERY'
    AND UPPER(sql_text) LIKE '%LAB10_SCENARIO_B_SUSPICIOUS_QUERY%'
    AND UPPER(sql_text) LIKE '%OPT_CUSTOMERS%'
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