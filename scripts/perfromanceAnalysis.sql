/* analyze the yrarly performance of prducts by comparing their sales
to both the average sales performance of the prduct and the previous year's sales */

WITH "yearlyProductSales" AS(
SELECT 
EXTRACT( YEAR FROM f."orderDate") AS "orderYear",
p."productName",
SUM(f."salesAmount") AS "currentSales"
FROM gold."factSales" f
LEFT JOIN gold."dimProducts" p
ON f."productKey" = p."productKey"
Where f."orderDate" IS NOT NULL
GROUP BY EXTRACT (YEAR FROM f."orderDate"),
p."productName"
)
SELECT 
"orderYear",
"productName",
"currentSales",
round(AVG("currentSales") over (partition by "productName")) As "avgSales",
"currentSales" - round(AVG("currentSales") over (partition by "productName")) AS "diffAvg",
CASE WHEN "currentSales" - round(AVG("currentSales") over (partition by "productName")) > 0 THEN 'aboveAvg'
	 WHEN "currentSales" - round(AVG("currentSales") over (partition by "productName")) < 0 THEN 'belowAvg'
	 ELSE 'avg'
END "avgChange",
LAG("currentSales") over (partition by "productName" order by "orderYear") AS "pYSales",
"currentSales" - LAG("currentSales") over (partition by "productName" order by "orderYear") AS "diffPY",
CASE WHEN "currentSales" - LAG("currentSales") over (partition by "productName" order by "orderYear") > 0 THEN 'increase'
	 WHEN "currentSales" - LAG("currentSales") over (partition by "productName" order by "orderYear") < 0 THEN 'decrease'
	 ELSE 'noChange'
END "pYChange"
FROM "yearlyProductSales" 
ORDER BY "productName","orderYear"

