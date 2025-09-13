/*
================================================================================
Customer Report
================================================================================
Purpose:
	- This report consolidates key customer mertics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. segements customers into categories(VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		-lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
================================================================================
*/
CREATE VIEW gold."reportCustomers" AS
WITH "baseQuery" AS (
/*-------------------------------------------------
1 base qurery: Retrievers core columns from tables
--------------------------------------------------*/
SELECT
f."orderNumber",
f."productKey",
f."orderDate",
f."salesAmount",
f."quantity",
c."customerKey",
c."customerNumber",
-- c."firstName",
-- c."lastName",
(c."firstName" || ' ' || c."lastName") AS "customerName",
EXTRACT (YEAR FROM AGE(c."birthDate")) AS "age"
FROM gold."factSales" f
LEFT JOIN gold."dimCustomers" c
ON c."customerKey" = f."customerKey"
WHERE "orderDate" IS NOT NULL )

,"customerAggregation" AS (
/*-------------------------------------------------
2 Customer Aggregations: Summarizes key metrics at the customer level 
--------------------------------------------------*/
SELECT 
	"customerKey",
	"customerNumber",
	"customerName",
	"age",
	COUNT(DISTINCT "orderNumber") AS "totalOrders",
	SUM("salesAmount") AS "totalSales",
	SUM("quantity") AS "totalQuantity",
	COUNT(DISTINCT "productKey") AS "totalProducts",
	MAX("orderDate")AS "lastOrderDate",
	(EXTRACT(YEAR FROM AGE(MAX("orderDate"), MIN("orderDate"))) * 12 +
 EXTRACT(MONTH FROM AGE(MAX("orderDate"), MIN("orderDate")))) AS "lifeSpanMonths"
FROM "baseQuery"
GROUP BY 
	"customerKey",
	"customerNumber",
	"customerName",
	"age" 
)
SELECT 
"customerKey",
"customerNumber",
"customerName",
"age",
CASE WHEN "age" < 20 THEN 'Under 20'
	 WHEN "age" between 20 and 29 THEN '20-29'
	 WHEN "age" between 30 and 39 THEN '30-39'
	 WHEN "age" between 40 and 49 THEN '40-49'
	ELSE '50 and Above'
END AS "ageGroup",
CASE 
	WHEN "lifeSpanMonths" >= 12 AND "totalSales" > 5000 THEN 'VIP'
	WHEN "lifeSpanMonths" >= 12 AND "totalSales" <= 5000 THEN 'Regular'
	ELSE 'New'
END AS "customerSegment",
"lastOrderDate",
(EXTRACT(YEAR FROM AGE(NOW(), "lastOrderDate")) * 12 +
 EXTRACT(MONTH FROM AGE(NOW(), "lastOrderDate"))) AS "recency",
"totalOrders",
"totalSales",
"totalQuantity",
"totalProducts",
"lifeSpanMonths",
-- COmpuate average order value (AVO)
CASE 
	WHEN "totalOrders" = 0 THEN 0
	ELSE ROUND("totalSales"/ "totalOrders",0)
END AS "avgOrderValue",
--Compaute average monthly Spend
CASE 
	WHEN "lifeSpanMonths" = 0 THEN "totalSales"
	ELSE ROUND("totalSales"/ "lifeSpanMonths", 0)
END AS "avgMonthlySpending"
FROM "customerAggregation"








	