-- Check row counts.
SELECT 'OPT_CUSTOMERS' AS table_name, COUNT(*) AS rows_count FROM opt_customers
UNION ALL
SELECT 'OPT_ORDERS', COUNT(*) FROM opt_orders
UNION ALL
SELECT 'OPT_ORDER_ITEMS', COUNT(*) FROM opt_order_items;

-- Check customer city distribution.
SELECT city, country, COUNT(*) AS rows_count
FROM opt_customers
GROUP BY city, country
ORDER BY rows_count DESC;

-- Check order status distribution.
SELECT status, COUNT(*) AS rows_count
FROM opt_orders
GROUP BY status
ORDER BY rows_count DESC;

-- Check basic optimizer stats.
SELECT table_name, num_rows, blocks, last_analyzed
FROM user_tab_statistics
WHERE table_name IN ('OPT_CUSTOMERS', 'OPT_ORDERS', 'OPT_ORDER_ITEMS')
ORDER BY table_name;

SELECT table_name, column_name, num_distinct, histogram, density
FROM user_tab_col_statistics
WHERE table_name IN ('OPT_CUSTOMERS', 'OPT_ORDERS')
  AND column_name IN ('CITY', 'COUNTRY', 'STATUS', 'CREATED_AT', 'CUSTOMER_ID')
ORDER BY table_name, column_name;
