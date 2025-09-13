/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as productName, category, subCategory, and productCost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - totalOrders
       - totalSales
       - totalQuantity sold
       - totalCustomers (unique)
       - lifeSpan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - averageOrderRevenue (AOR)
       - averageMonthlyRevenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold."reportProducts"
-- =============================================================================
--DROP VIEW IF EXISTS gold."reportProducts";

CREATE VIEW gold."reportProducts" AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
SELECT
        f."orderNumber",
        f."orderDate",
        f."customerKey",
        f."salesAmount",
        f."quantity",
        p."productKey",
        p."productName",
        p."category",
        p."subCategory",
        p."productCost"
    FROM gold."factSales" f
    LEFT JOIN gold."dimProducts" p
        ON f."productKey" = p."productKey"
    WHERE f."orderDate" IS NOT NULL
),
"productAggregations" AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    "productKey",
    "productName",
    "category",
    "subCategory",
    "productCost",
    EXTRACT(MONTH FROM AGE(MAX("orderDate"), MIN("orderDate"))) AS "lifespan",
    MAX("orderDate") AS "lastSaleDate",
    COUNT(DISTINCT "orderNumber") AS "totalOrders",
    COUNT(DISTINCT "customerKey") AS "totalCustomers",
    SUM("salesAmount") AS "totalSales",
    SUM("quantity") AS "totalQuantity",
    ROUND(AVG(CAST("salesAmount" AS NUMERIC) / NULLIF("quantity", 0)), 1) AS "avgSellingPrice"
FROM base_query
GROUP BY
    "productKey", "productName", "category", "subCategory", "productCost"
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
    "productKey",
    "productName",
    "category",
    "subCategory",
    "productCost",
    "lastSaleDate",
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, "lastSaleDate")) AS "recencyInMonths",
    CASE
        WHEN "totalSales" > 50000 THEN 'High-Performer'
        WHEN "totalSales" >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS "productSegment",
    "lifespan",
    "totalOrders",
    "totalSales",
    "totalQuantity",
    "totalCustomers",
    "avgSellingPrice",
    -- Average Order Revenue (AOR)
    CASE 
        WHEN "totalOrders" = 0 THEN 0
        ELSE ROUND("totalSales"::NUMERIC / "totalOrders", 0)
    END AS "avgOrderRevenue",
    -- Average Monthly Revenue
    CASE
        WHEN "lifespan" = 0 THEN "totalSales"
        ELSE ROUND("totalSales"::NUMERIC / "lifespan", 0)
    END AS "avgMonthlyRevenue"
FROM "productAggregations";