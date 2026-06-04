
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE opt_order_items PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE opt_orders PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE opt_customers PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE opt_customers (
  customer_id NUMBER NOT NULL,
  full_name   VARCHAR2(100) NOT NULL,
  country     VARCHAR2(30) NOT NULL,
  city        VARCHAR2(30) NOT NULL,
  email       VARCHAR2(120) NOT NULL,
  status      VARCHAR2(20) NOT NULL,
  created_at  DATE NOT NULL,
  CONSTRAINT pk_opt_customers PRIMARY KEY (customer_id)
);

CREATE TABLE opt_orders (
  order_id    NUMBER NOT NULL,
  customer_id NUMBER NOT NULL,
  status      VARCHAR2(20) NOT NULL,
  city        VARCHAR2(30) NOT NULL,
  order_total NUMBER(10,2) NOT NULL,
  created_at  DATE NOT NULL,
  CONSTRAINT pk_opt_orders PRIMARY KEY (order_id),
  CONSTRAINT fk_opt_orders_customer
    FOREIGN KEY (customer_id) REFERENCES opt_customers(customer_id)
);

CREATE TABLE opt_order_items (
  item_id          NUMBER NOT NULL,
  order_id         NUMBER NOT NULL,
  product_category VARCHAR2(40) NOT NULL,
  quantity         NUMBER NOT NULL,
  unit_price       NUMBER(10,2) NOT NULL,
  CONSTRAINT pk_opt_order_items PRIMARY KEY (item_id),
  CONSTRAINT fk_opt_items_order
    FOREIGN KEY (order_id) REFERENCES opt_orders(order_id)
);

-- Basic indexes. Some labs will create/drop extra indexes.
CREATE INDEX ix_opt_customers_city ON opt_customers(city);
CREATE INDEX ix_opt_customers_country_city ON opt_customers(country, city);
CREATE INDEX ix_opt_customers_email ON opt_customers(email);

CREATE INDEX ix_opt_orders_customer ON opt_orders(customer_id);
CREATE INDEX ix_opt_orders_city_status ON opt_orders(city, status);
CREATE INDEX ix_opt_orders_status_city ON opt_orders(status, city);
CREATE INDEX ix_opt_orders_created_id ON opt_orders(created_at DESC, order_id DESC);

CREATE INDEX ix_opt_items_order ON opt_order_items(order_id);
