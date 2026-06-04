ALTER SESSION SET statistics_level = ALL;


---------------------------------------------
--query A
---------------------------------------------
SELECT index_name, column_name, column_position
FROM user_ind_columns
WHERE table_name = 'OPT_ORDERS'
  AND index_name IN ('IX_OPT_ORDERS_CITY_STATUS', 'IX_OPT_ORDERS_STATUS_CITY')
ORDER BY index_name, column_position;

SELECT COUNT(*) AS actual_rows_query_a
FROM opt_orders
WHERE city = 'Cairo'
  AND status = 'PAID';

SELECT /*+ gather_plan_statistics */ /* LAB05_QA */
       order_id, customer_id, status, city
FROM opt_orders
WHERE city = 'Cairo'
  AND status = 'PAID';

WITH s AS (
    SELECT sql_id, child_number
    FROM v$sql
    WHERE sql_text LIKE '%LAB05_QA%'
      AND sql_text NOT LIKE '%v$sql%'
      AND sql_text NOT LIKE '%DBMS_XPLAN%'
    ORDER BY last_active_time DESC
    FETCH FIRST 1 ROW ONLY
)
SELECT p.plan_table_output
FROM s,
     TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
         s.sql_id,
         s.child_number,
         'ALLSTATS LAST +PREDICATE +COST'
     )) p;


---------------------------------------------
--query B
---------------------------------------------

SELECT COUNT(*) AS actual_rows_query_b
FROM opt_orders
WHERE city = 'Cairo';

SELECT /*+ gather_plan_statistics */ /* LAB05_QB */
       order_id, customer_id, status, city
FROM opt_orders
WHERE city = 'Cairo';

WITH s AS (
    SELECT sql_id, child_number
    FROM v$sql
    WHERE sql_text LIKE '%LAB05_QB%'
      AND sql_text NOT LIKE '%v$sql%'
      AND sql_text NOT LIKE '%DBMS_XPLAN%'
    ORDER BY last_active_time DESC
    FETCH FIRST 1 ROW ONLY
)
SELECT p.plan_table_output
FROM s,
     TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
         s.sql_id,
         s.child_number,
         'ALLSTATS LAST +PREDICATE +COST'
     )) p;

---------------------------------------------
--query c
---------------------------------------------

SELECT COUNT(*) AS actual_rows_query_c
FROM opt_orders
WHERE status = 'CANCELLED';

SELECT /*+ gather_plan_statistics */ /* LAB05_QC */
       order_id, customer_id, status, city
FROM opt_orders
WHERE status = 'CANCELLED';

WITH s AS (
    SELECT sql_id, child_number
    FROM v$sql
    WHERE sql_text LIKE '%LAB05_QC%'
      AND sql_text NOT LIKE '%v$sql%'
      AND sql_text NOT LIKE '%DBMS_XPLAN%'
    ORDER BY last_active_time DESC
    FETCH FIRST 1 ROW ONLY
)
SELECT p.plan_table_output
FROM s,
     TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
         s.sql_id,
         s.child_number,
         'ALLSTATS LAST +PREDICATE +COST'
     )) p;