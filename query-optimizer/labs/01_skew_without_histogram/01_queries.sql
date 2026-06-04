
--------------------------------------------------------------------------------
-- Case A: Common value
-- Cairo is 7,000 out of 10,000 customers.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Case A.1: Estimated Plan
--------------------------------------------------------------------------------

-- Prepare the estimated plan.
-- This does NOT return data.
-- It only asks Oracle to calculate the expected execution plan and store it in the plan table.
EXPLAIN PLAN FOR
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Cairo';

-- Display the estimated plan.
-- First NULL  = use the default PLAN_TABLE
-- Second NULL = use the latest/default stored plan
-- Third value = choose what details to show
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +ROWS +COST +PREDICATE'));

--Estimation Statistics
SELECT table_name,
       column_name,
       num_distinct,
       density,
       num_nulls,
       num_buckets,
       histogram,
       sample_size,
       last_analyzed
FROM user_tab_col_statistics
WHERE table_name = 'OPT_CUSTOMERS'
  AND column_name = 'CITY';

--------------------------------------------------------------------------------
-- Case A.2: Actual Plan
--------------------------------------------------------------------------------

--It is simply a marker that helps in finding the query later in in V$SQL.
--DBeaver may execute internal SQL statements after our query 'MetaData about the Queries '
--V$SQL = a dynamic performance view that shows SQL statements stored temporarily in Oracle cursor cache.
--Oracle stores many SQL statements temporarily in the cursor cache.
--Because the last executed SQL may not be our query, we need to get the correct SQL_ID and use it to display the actual plan.
--Mark the SQL statements executed in this session with:
--MODULE = OPT_LAB
--ACTION = CAIRO_ACTUAL
CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB', 'CAIRO_ACTUAL');

--/*+ The hint collects runtime statistics, such as A-Rows, A-Time, and Buffers.*/
--So that when we search in V$SQL we can easily find the query.
--/* */ a marker to find the query later in V$SQL.
SELECT /*+ gather_plan_statistics */ /* CAIRO_ACTUAL_QUERY */
       customer_id, full_name, city
FROM opt_customers
WHERE city = 'Cairo';

--The first part searches in V$SQL and returns: sql_id, child_number
--The second part to display the actual execution plan for that specific SQL_ID.
WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB'
    AND action = 'CAIRO_ACTUAL'
    AND UPPER(sql_text) LIKE '%CAIRO_ACTUAL_QUERY%'
    AND UPPER(sql_text) LIKE '%OPT_CUSTOMERS%'
    AND UPPER(sql_text) LIKE '%CAIRO%'
    AND UPPER(sql_text) NOT LIKE '%V$SQL%'
  ORDER BY last_active_time DESC
  FETCH FIRST 1 ROW ONLY
)
SELECT p.*
FROM target_sql t
CROSS APPLY TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  t.sql_id,
  t.child_number,
  'ALLSTATS LAST +PREDICATE +COST'
)) p;



--------------------------------------------------------------------------------
-- Case B: Less common value
-- Paris is 1,000 out of 10,000 customers.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Case B.1: Estimated Plan
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Paris';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(
  NULL,
  NULL,
  'BASIC +ROWS +COST +PREDICATE'
));


--------------------------------------------------------------------------------
-- Case B.2: Actual Plan
--------------------------------------------------------------------------------

-- Mark this execution so we can find it later in V$SQL.
BEGIN
  DBMS_APPLICATION_INFO.SET_MODULE(
    module_name => 'OPT_LAB',
    action_name => 'PARIS_ACTUAL'
  );
END;
/

-- Run the query for real.
-- In DBeaver: fetch all rows if you want A-Rows to show the full count.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name, city
FROM opt_customers
WHERE city = 'Paris';

-- Find the SQL_ID for the executed Paris query.
SELECT sql_id,
       child_number,
       executions,
       last_active_time,
       sql_text
FROM v$sql
WHERE module = 'OPT_LAB'
  AND action = 'PARIS_ACTUAL'
  AND UPPER(sql_text) LIKE 'SELECT /*+ GATHER_PLAN_STATISTICS */%'
  AND UPPER(sql_text) LIKE '%FROM OPT_CUSTOMERS%'
  AND UPPER(sql_text) LIKE '%PARIS%'
ORDER BY last_active_time DESC
FETCH FIRST 5 ROWS ONLY;

-- Display the actual execution plan.
-- Replace the SQL_ID and CHILD_NUMBER with the values from the previous query.
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  'PASTE_SQL_ID_HERE',
  0,
  'ALLSTATS LAST +PREDICATE +COST'
));