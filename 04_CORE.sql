

USE WAREHOUSE ECOMMERCE_WH;
USE DATABASE ECOMM_DB;
USE SCHEMA CORE;

-- CREATE CORE TABLES

CREATE OR REPLACE TABLE CORE_CUSTOMER
LIKE RAW.CUSTOMER;

CREATE OR REPLACE TABLE CORE_PRODUCT
LIKE RAW.PRODUCT;

CREATE OR REPLACE TABLE CORE_CART
LIKE RAW.CART;

CREATE OR REPLACE TABLE CORE_ORDERS
LIKE RAW.ORDERS;

CREATE OR REPLACE TABLE CORE_PAYMENT
LIKE RAW.PAYMENT;

-- JSON EVENTS TABLE

CREATE OR REPLACE TABLE CORE_CUSTOMER_EVENTS (
    event_type STRING,
    product_id INT,
    event_time TIMESTAMP
);

SHOW TABLES;


-- CREATE TASK


CREATE OR REPLACE TASK RAW_TO_CORE
WAREHOUSE = ECOMMERCE_WH
SCHEDULE = '1 MINUTE'
AS

BEGIN

    -- CUSTOMER

    INSERT INTO CORE_CUSTOMER
    SELECT
        customer_id,
        customer_name,
        city,
        email
    FROM RAW.customer_stream
    WHERE customer_id IS NOT NULL;

    -- PRODUCT

    INSERT INTO CORE_PRODUCT
    SELECT
        product_id,
        product_name,
        category,
        price
    FROM RAW.product_stream
    WHERE product_id IS NOT NULL
    AND price > 0;

    -- CART

    INSERT INTO CORE_CART
    SELECT
        cart_id,
        customer_id,
        created_at,
        status
    FROM RAW.cart_stream
    WHERE cart_id IS NOT NULL;

    -- ORDERS

    INSERT INTO CORE_ORDERS
    SELECT
        order_id,
        customer_id,
        order_amount,
        order_date,
        order_status
    FROM RAW.orders_stream
    WHERE order_id IS NOT NULL
    AND order_amount > 0;

    -- PAYMENT

    INSERT INTO CORE_PAYMENT
    SELECT
        payment_id,
        order_id,
        payment_amount,
        payment_method,
        payment_status
    FROM RAW.payment_stream
    WHERE payment_id IS NOT NULL;

    -- JSON EVENTS

    INSERT INTO CORE_CUSTOMER_EVENTS

    SELECT
        value:event_type::STRING AS event_type,
        value:product_id::INT AS product_id,
        value:timestamp::TIMESTAMP AS event_time

    FROM RAW.customer_events,
    LATERAL FLATTEN(input => data:events);

END;

-- VERIFY TASK


SHOW TASKS;


-- START TASK


ALTER TASK RAW_TO_CORE SUSPEND;


-- VERIFY CORE TABLES


SELECT * FROM CORE_CUSTOMER;

SELECT * FROM CORE_PRODUCT;

SELECT * FROM CORE_CART;

SELECT * FROM CORE_ORDERS;

SELECT * FROM CORE_PAYMENT;

SELECT * FROM CORE_CUSTOMER_EVENTS;