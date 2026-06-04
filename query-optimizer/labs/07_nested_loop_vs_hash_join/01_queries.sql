/* ============================================================
   0) Gather Statistics
   ============================================================ */

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    USER,
    'OPT_CUSTOMERS',
    cascade => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO'
  );

  DBMS_STATS.GATHER_TABLE_STATS(
    USER,
    'OPT_ORDERS',
    cascade => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO'
  );
END;
/


/* ============================================================
   1) Default Plan
   ============================================================ */

SELECT /*+ gather_plan_statistics */ /* LAB08_DEFAULT */
       COUNT(*) AS joined_rows
FROM opt_customers c
JOIN opt_orders o
  ON o.customer_id = c.customer_id
WHERE c.city = 'Cairo'
  AND o.status = 'PAID';


WITH s AS (
    SELECT sql_id, child_number
    FROM v$sql
    WHERE sql_text LIKE '%LAB08_DEFAULT%'
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

     ## Forced nested loops

     SELECT /*+ gather_plan_statistics leading(c o) use_nl(o) */ /* LAB08_FORCE_NL */
            COUNT(*) AS joined_rows
     FROM opt_customers c
     JOIN opt_orders o
       ON o.customer_id = c.customer_id
     WHERE c.city = 'Cairo'
       AND o.status = 'PAID';


     WITH s AS (
         SELECT sql_id, child_number
         FROM v$sql
         WHERE sql_text LIKE '%LAB08_FORCE_NL%'
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


      ## forced sort join

          SELECT /*+ gather_plan_statistics leading(c o) use_merge(o) */ /* LAB08_FORCE_MERGE */
                 COUNT(*) AS joined_rows
          FROM opt_customers c
          JOIN opt_orders o
            ON o.customer_id = c.customer_id
          WHERE c.city = 'Cairo'
            AND o.status = 'PAID';

          WITH s AS (
              SELECT sql_id, child_number
              FROM v$sql
              WHERE sql_text LIKE '%LAB08_FORCE_MERGE%'
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