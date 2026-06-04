-- Normal predicate on email.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name, email
FROM opt_customers
WHERE email = 'customer100@example.com';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));

-- Function on column.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name, email
FROM opt_customers
WHERE LOWER(email) = 'customer100@example.com';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));

-- Add function-based index.
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX ix_opt_customers_lower_email ON opt_customers(LOWER(email))';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO'
  );
END;
/

-- Try again after function-based index.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name, email
FROM opt_customers
WHERE LOWER(email) = 'customer100@example.com';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));
