SELECT
EXTRACT(YEAR from "orderDate") AS "orderYear",
EXTRACT(MONTH from "orderDate") AS "orderMonth",
COUNT(DISTINCT "customerKey") AS "totalCustomer",
SUM("quantity") AS "totalQuantity",
SUM("salesAmount") AS "totalSales"
FROM gold."factSales"
WHERE "orderDate" IS NOT NULL
GROUP BY ("orderMonth"), ("orderYear")
Order by ("orderMonth"), ("orderYear")


-- SELECT
-- COUNT(DISTINCT "customerKey") AS "totalCustomer",
-- DATE_TRUNC('MONTH' ,"orderDate")::DATE AS "orderDate",
-- --EXTRACT(YEAR from "orderDate") AS "orderYear",
-- SUM("salesAmount") AS "totalSales",
-- SUM("quantity") AS "totalQuantity"
-- FROM gold."factSales"
-- WHERE "orderDate" IS NOT NULL
-- GROUP BY DATE_TRUNC('MONTH' ,"orderDate")
-- Order by DATE_TRUNC('MONTH' ,"orderDate")


-- SELECT
-- TO_CHAR("orderDate",'YYYY-Mon') AS "orderDate",
-- COUNT(DISTINCT "customerKey") AS "totalCustomer",
-- SUM("salesAmount") AS "totalSales",
-- SUM("quantity") AS "totalQuantity"
-- FROM gold."factSales"
-- WHERE "orderDate" IS NOT NULL
-- GROUP BY TO_CHAR("orderDate", 'YYYY-Mon')
-- Order by MIN("orderDate");