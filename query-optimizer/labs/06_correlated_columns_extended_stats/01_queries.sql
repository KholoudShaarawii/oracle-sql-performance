-- Drop extension if exists.
DECLARE
  v_ext_name VARCHAR2(128);
BEGIN
  SELECT extension_name
  INTO v_ext_name
  FROM user_stat_extensions
  WHERE table_name = 'OPT_CUSTOMERS'
    AND extension = '("COUNTRY","CITY")';

  DBMS_STATS.DROP_EXTENDED_STATS(USER, 'OPT_CUSTOMERS', '(country, city)');
EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
END;
/

-- Gather normal stats with no histograms.
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );
END;
/

-- Check actual impossible combination.
SELECT COUNT(*) AS actual_rows
FROM opt_customers
WHERE country = 'UK'
  AND city = 'Cairo';

-- Before extended stats.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name
FROM opt_customers
WHERE country = 'UK'
  AND city = 'Cairo';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));

-- Create extended stats on correlated columns.
DECLARE
  v_name VARCHAR2(128);
BEGIN
  v_name := DBMS_STATS.CREATE_EXTENDED_STATS(
    ownname   => USER,
    tabname   => 'OPT_CUSTOMERS',
    extension => '(country, city)'
  );
END;
/

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );
END;
/

SELECT extension_name, extension
FROM user_stat_extensions
WHERE table_name = 'OPT_CUSTOMERS';

-- After extended stats.
SELECT /*+ gather_plan_statistics */
       customer_id, full_name
FROM opt_customers
WHERE country = 'UK'
  AND city = 'Cairo';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST +PREDICATE +COST'));
