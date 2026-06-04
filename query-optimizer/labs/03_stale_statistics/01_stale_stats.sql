
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );
END;
/

SELECT table_name, num_rows, last_analyzed
FROM user_tab_statistics
WHERE table_name = 'OPT_CUSTOMERS';

-- Add many new Cairo customers AFTER stats were gathered.
BEGIN
  FOR i IN 10001..30000 LOOP
    INSERT INTO opt_customers (
      customer_id, full_name, country, city, email, status, created_at
    ) VALUES (
      i,
      'New Cairo Customer ' || i,
      'Egypt',
      'Cairo',
      'new_customer' || i || '@example.com',
      'ACTIVE',
      DATE '2026-01-01' + MOD(i, 30)
    );
  END LOOP;
  COMMIT;
END;
/

SELECT COUNT(*) AS actual_customers
FROM opt_customers;

SELECT city, COUNT(*) AS actual_rows
FROM opt_customers
GROUP BY city
ORDER BY actual_rows DESC;

SELECT table_name, num_rows, stale_stats, last_analyzed
FROM user_tab_statistics
WHERE table_name = 'OPT_CUSTOMERS'; --10000

SELECT /*+ gather_plan_statistics */
       customer_id, full_name
FROM opt_customers
WHERE city = 'Cairo';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));

--  refresh stats.
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR COLUMNS SIZE 254 CITY'
  );
END;
/

SELECT /*+ gather_plan_statistics */
       customer_id, full_name
FROM opt_customers
WHERE city = 'Cairo';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));
