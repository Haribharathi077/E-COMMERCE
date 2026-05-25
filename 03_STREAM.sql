USE WAREHOUSE ECOMMERCE_WH;
USE DATABASE ECOMM_DB;
USE SCHEMA RAW;

CREATE OR REPLACE STREAM customer_stream
ON TABLE customer;

CREATE OR REPLACE STREAM product_stream
ON TABLE product;

CREATE OR REPLACE STREAM orders_stream
ON TABLE orders;

CREATE OR REPLACE STREAM payment_stream
ON TABLE payment;

CREATE OR REPLACE STREAM cart_stream
ON TABLE cart;

SHOW STREAMS;

SELECT COUNT(*) FROM customer_stream;

SELECT COUNT(*) FROM product;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM payment;

SELECT COUNT(*) FROM cart;