-- which categories contribute the most to overall sales ?
WITH "categorySales" AS (
SELECT 
"category",
SUM("salesAmount") AS "totalSales"
FROM gold."factSales" f
LEFT JOIN gold."dimProducts" p
ON p."productKey" = f."productKey"
GROUP BY "category"
)

SELECT 
"category",
"totalSales",
sum("totalSales") over() "overallSales",
CONCAT(ROUND(("totalSales" / sum("totalSales") over () ) * 100, 2), '%') AS "percentageOfTotal"
FROM "categorySales"
ORDER BY "totalSales" DESC