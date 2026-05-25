

USE WAREHOUSE ECOMMERCE_WH;
USE DATABASE ECOMM_DB;
USE SCHEMA MART;



CREATE OR REPLACE DYNAMIC TABLE DIM_CUSTOMER
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT
    customer_id,
    customer_name,
    city,
    email

FROM CORE.CORE_CUSTOMER;

CREATE OR REPLACE DYNAMIC TABLE DIM_PRODUCT
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT
    product_id,
    product_name,
    category,
    price

FROM CORE.CORE_PRODUCT;


CREATE OR REPLACE DYNAMIC TABLE DIM_DATE
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT DISTINCT
    order_date AS DATE,
    YEAR(order_date) AS YEAR,
    MONTH(order_date) AS MONTH,
    DAY(order_date) AS DAY,
    DAYNAME(order_date) AS DAY_NAME

FROM CORE.CORE_ORDERS;



CREATE OR REPLACE DYNAMIC TABLE FACT_ORDERS
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT
    o.order_id,
    c.customer_id,
    p.payment_id,
    d.DATE,
    o.order_amount,
    p.payment_amount,
    p.payment_method,
    p.payment_status,
    o.order_status

FROM CORE.CORE_ORDERS o

LEFT JOIN DIM_CUSTOMER c
ON o.customer_id = c.customer_id

LEFT JOIN CORE.CORE_PAYMENT p
ON o.order_id = p.order_id

LEFT JOIN DIM_DATE d
ON o.order_date = d.DATE;


CREATE OR REPLACE DYNAMIC TABLE FACT_CART
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT
    cart_id,
    customer_id,
    created_at,
    status

FROM CORE.CORE_CART;



CREATE OR REPLACE DYNAMIC TABLE FACT_CUSTOMER_EVENTS
TARGET_LAG = '1 MINUTE'
WAREHOUSE = ECOMMERCE_WH
AS

SELECT
    event_type,
    product_id,
    event_time

FROM CORE.CORE_CUSTOMER_EVENTS;


-- VIEWS


-- TOTAL SALES VIEW

CREATE OR REPLACE VIEW VW_TOTAL_SALES
AS

SELECT
    DATE,
    SUM(order_amount) AS total_sales

FROM FACT_ORDERS

GROUP BY DATE;


-- TOP CUSTOMERS VIEW


CREATE OR REPLACE VIEW VW_TOP_CUSTOMERS
AS

SELECT
    customer_id,
    SUM(order_amount) AS total_spent

FROM FACT_ORDERS

GROUP BY customer_id

ORDER BY total_spent DESC;


-- FAILED PAYMENTS VIEW

CREATE OR REPLACE VIEW VW_FAILED_PAYMENTS
AS

SELECT
    payment_id,
    order_id,
    payment_amount,
    payment_status

FROM CORE.CORE_PAYMENT

WHERE payment_status = 'Failed';


-- CART ABANDONMENT VIEW


CREATE OR REPLACE VIEW VW_CART_ABANDONMENT
AS

SELECT
    cart_id,
    customer_id,
    status

FROM FACT_CART

WHERE status = 'Abandoned';


-- EVENT ANALYTICS VIEW


CREATE OR REPLACE VIEW VW_EVENT_ANALYTICS
AS

SELECT
    event_type,
    COUNT(product_id) AS total_events

FROM FACT_CUSTOMER_EVENTS

GROUP BY event_type;

-- MATERIALIZED VIEW : MONTHLY REVENUE


CREATE OR REPLACE MATERIALIZED VIEW MV_MONTHLY_REVENUE
AS

SELECT
    YEAR(order_date) AS YEAR,
    MONTH(order_date) AS MONTH,
    SUM(order_amount) AS monthly_revenue

FROM CORE.CORE_ORDERS

GROUP BY YEAR(order_date), MONTH(order_date);


-- TIME TRAVEL RECOVERY


CREATE OR REPLACE TABLE FACT_ORDERS_RECOVERY
AS

SELECT *
FROM FACT_ORDERS;


-- ZERO COPY CLONING


CREATE OR REPLACE SCHEMA MART_RECOVERY
CLONE MART;


-- VERIFY OBJECTS


SHOW DYNAMIC TABLES;

SHOW VIEWS;

SHOW MATERIALIZED VIEWS;


-- VERIFY DATA


SELECT * FROM FACT_ORDERS;

SELECT * FROM VW_TOTAL_SALES;

SELECT * FROM VW_TOP_CUSTOMERS;

SELECT * FROM VW_FAILED_PAYMENTS;

SELECT * FROM MV_MONTHLY_REVENUE;