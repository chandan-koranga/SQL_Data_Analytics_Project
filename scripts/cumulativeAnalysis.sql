--calculate the total sales per month
-- and the running total of sales over time
SELECT
"orderDate",
"totalSales",
SUM("totalSales") OVER (/*PARTITION BY "orderDate"*/ ORDER BY "orderDate") AS "runningTotalSales",
ROUND(AVG("avgPrice") OVER (/*PARTITION BY "orderDate"*/ ORDER BY "orderDate")) AS "movingAveragePrice"
FROM
(
SElECT
DATE_TRUNC('Year', "orderDate")::DATE AS "orderDate",
SUM("salesAmount") AS "totalSales",
AVG("price") AS "avgPrice"
FROM gold."factSales"
WHERE "orderDate" IS NOT NULL
GROUP BY DATE_TRUNC('Year', "orderDate")
--ORDER BY DATE_TRUNC('month', "orderDate")
)t