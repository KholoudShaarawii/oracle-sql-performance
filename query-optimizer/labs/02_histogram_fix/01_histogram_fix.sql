


-- Step 1: Gather statistics with histogram on CITY

-- creates or updates the histogram as part of gathering column statistics.
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR COLUMNS SIZE 254 CITY' --Histogram 254 Buckets
  );
END;
/

-- Step 2: Check CITY column statistics after histogram

-- Display the Statistics
-- Check whether Oracle created a histogram on CITY.
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
-- Case A: Common value after histogram
-- Cairo is 7,000 out of 10,000 customers.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Case A.1: Estimated Plan after histogram
--------------------------------------------------------------------------------

-- Prepare the estimated plan.
-- calculate the expected execution plan using the new statistics.
EXPLAIN PLAN FOR
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Cairo';

-- Display the estimated plan.
-- Focus on E-Rows.
-- Before histogram, Cairo E-Rows was 2500.
-- After histogram, we want to see if E-Rows becomes closer to 7000.
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +ROWS +COST +PREDICATE'));


--------------------------------------------------------------------------------
-- Case A.2: Actual Plan after histogram
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB', 'CAIRO_ACTUAL');

-- Fetch all rows before displaying the actual plan.
SELECT /*+ gather_plan_statistics */ /* CAIRO_ACTUAL_QUERY */
       customer_id, full_name, city
FROM opt_customers
WHERE city = 'Cairo';

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
-- Case B: Less common value after histogram
-- Paris is 1,000 out of 10,000 customers.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Case B.1: Estimated Plan after histogram
--------------------------------------------------------------------------------

-- Prepare the estimated plan.
-- Before histogram, Paris E-Rows was also 2500.
-- After histogram, we want to see if E-Rows becomes closer to 1000.
EXPLAIN PLAN FOR
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Paris';

-- Display the estimated plan.
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +ROWS +COST +PREDICATE'));


--------------------------------------------------------------------------------
-- Case B.2: Actual Plan after histogram
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Case B.2: Actual Plan after histogram - Paris
--------------------------------------------------------------------------------

CALL DBMS_APPLICATION_INFO.SET_MODULE('OPT_LAB_03', 'PARIS_HIST_ACTUAL');

SELECT /*+ gather_plan_statistics */ /* LAB03_PARIS_HIST */
       customer_id, full_name, city
FROM opt_customers
WHERE city = 'Paris';

WITH target_sql AS (
  SELECT sql_id,
         child_number
  FROM v$sql
  WHERE module = 'OPT_LAB_03'
    AND action = 'PARIS_HIST_ACTUAL'
    AND UPPER(sql_text) LIKE '%LAB03_PARIS_HIST%'
    AND UPPER(sql_text) LIKE '%OPT_CUSTOMERS%'
    AND UPPER(sql_text) LIKE '%PARIS%'
    AND UPPER(sql_text) NOT LIKE 'SELECT COUNT(*)%'
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