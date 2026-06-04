-- Seed deterministic lab data.
-- Expected volume:
--   OPT_CUSTOMERS   = 10,000
--   OPT_ORDERS      = 60,000
--   OPT_ORDER_ITEMS = 120,000

SET DEFINE OFF;

BEGIN
  -- Customers:
  -- 7,000 Egypt/Cairo
  -- 1,000 Egypt/Alexandria
  -- 1,000 UK/London
  -- 1,000 France/Paris
  FOR i IN 1..10000 LOOP
    INSERT INTO opt_customers (
      customer_id, full_name, country, city, email, status, created_at
    ) VALUES (
      i,
      'Customer ' || i,
      CASE
        WHEN i <= 8000 THEN 'Egypt'
        WHEN i <= 9000 THEN 'UK'
        ELSE 'France'
      END,
      CASE
        WHEN i <= 7000 THEN 'Cairo'
        WHEN i <= 8000 THEN 'Alexandria'
        WHEN i <= 9000 THEN 'London'
        ELSE 'Paris'
      END,
      'customer' || i || '@example.com',
      CASE
        WHEN MOD(i, 20) = 0 THEN 'SUSPENDED'
        ELSE 'ACTIVE'
      END,
      DATE '2024-01-01' + MOD(i, 730)
    );
  END LOOP;

  -- Orders:
  -- 60,000 orders.
  -- status is skewed:
  --   PAID     ~ 80%
  --   PENDING  ~ 15%
  --   CANCELLED ~ 5%
  FOR i IN 1..60000 LOOP
    INSERT INTO opt_orders (
      order_id, customer_id, status, city, order_total, created_at
    )
    SELECT
      i,
      c.customer_id,
      CASE
        WHEN MOD(i, 20) = 0 THEN 'CANCELLED'
        WHEN MOD(i, 20) IN (1,2,3) THEN 'PENDING'
        ELSE 'PAID'
      END,
      c.city,
      ROUND(50 + MOD(i * 17, 2000) + (MOD(i, 7) * 0.75), 2),
      DATE '2025-01-01' + MOD(i, 500)
    FROM opt_customers c
    WHERE c.customer_id = MOD(i - 1, 10000) + 1;
  END LOOP;

  -- Two items per order.
  FOR i IN 1..120000 LOOP
    INSERT INTO opt_order_items (
      item_id, order_id, product_category, quantity, unit_price
    ) VALUES (
      i,
      CEIL(i / 2),
      CASE MOD(i, 6)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Books'
        WHEN 2 THEN 'Fashion'
        WHEN 3 THEN 'Home'
        WHEN 4 THEN 'Sports'
        ELSE 'Beauty'
      END,
      MOD(i, 5) + 1,
      ROUND(10 + MOD(i * 13, 300), 2)
    );
  END LOOP;

  COMMIT;
END;
/
