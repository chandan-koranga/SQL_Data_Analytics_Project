-- =============================================================
-- Create Database and Schemas in PostgreSQL 
-- =============================================================
-- WARNING:
-- Running this script will DROP the 'dataWarehouseAnalytics' database if it exists.
-- All data will be permanently deleted. Ensure backups before executing.

-- Drop and recreate database
DROP DATABASE IF EXISTS "dataWarehouseAnalytics";
CREATE DATABASE "dataWarehouseAnalytics";


-- Create schema
CREATE SCHEMA IF NOT EXISTS gold;

-- Create Tables
CREATE TABLE gold."dimCustomers"(
    "customerKey" SERIAL PRIMARY KEY,
    "customerId" INT,
    "customerNumber" VARCHAR(50),
    "firstName" VARCHAR(50),
    "lastName" VARCHAR(50),
	"birthDate" DATE,
    "maritalStatus" VARCHAR(50),
    "gender" VARCHAR(50),
    "country" VARCHAR(50),
    "createDate" DATE
);

CREATE TABLE gold."dimProducts"(
    "productKey" SERIAL PRIMARY KEY,
    "productId" INT,
    "productNumber" VARCHAR(50),
    "productName" VARCHAR(50),
    "categoryId" VARCHAR(50),
    "category" VARCHAR(50),
    "subCategory" VARCHAR(50),
    "maintenance" VARCHAR(50),
    "productcost" INT,
    "productLine" VARCHAR(50),
    "productstartDate" DATE
);

CREATE TABLE gold."factSales"(
    "orderNumber" VARCHAR(50),
    "productKey" INT REFERENCES gold."dimProducts"("productKey"),
    "customerKey" INT REFERENCES gold."dimCustomers"("customerKey"),
    "orderDate" DATE,
    "shippingDate" DATE,
    "dueDate" DATE,
    "salesAmount" INT,
    "quantity" INT,
    "price" INT
);

-- Truncate tables before load
TRUNCATE TABLE gold."factSales",gold."dimCustomers",gold."dimProducts";



-- Load CSV data into PostgreSQL
-- NOTE: For Windows paths, escape backslashes (\\) or use forward slashes (/)

COPY gold."dimCustomers"("customerKey","customerId","customerNumber","firstName","lastName","birthDate","maritalStatus","gender","country","createDate")
FROM 'E:/sql_data_analytics_project/datasets/csvFile/gold.dimCustomers.csv'
DELIMITER ','
CSV HEADER;

COPY gold."dimProducts"("productKey","productId","productNumber","productName","categoryId","category","subCategory","maintenance","productcost","productLine","productstartDate")
FROM 'E:/sql_data_analytics_project/datasets/csvFile/gold.dimProducts.csv'
DELIMITER ','
CSV HEADER;

COPY gold."factSales"("orderNumber","productKey","customerKey","orderDate","shippingDate","dueDate","salesAmount","quantity","price")
FROM 'E:/sql_data_analytics_project/datasets/csvFile/gold.factSales.csv'
DELIMITER ','
CSV HEADER;

 