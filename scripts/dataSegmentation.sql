/* group customers into segments based on their spending behavior:
- VIP : customer with at least 12 months of history but spending more than €5,000.
- Regural: customer with at least 12 months of history but spending €5,000 or less.
- New: customer with a lifespan less than 12 months.
And find the total number of customers by each group */

WITH "customerSpending" AS (
		SELECT
			C."customerKey",
			SUM(F."salesAmount") AS "totalSpending",
			MIN("orderDate") AS "firstOrder",
			MAX("orderDate") AS "lastOrder",
			(EXTRACT(YEAR FROM AGE (MAX(F."orderDate"), MIN(F."orderDate"))) * 12 +
			 EXTRACT(MONTH FROM AGE (MAX(F."orderDate"), MIN(F."orderDate")))) AS "lifeSpanMonths"
		FROM GOLD."factSales" F
			LEFT JOIN GOLD."dimCustomers" C 
			ON F."customerKey" = C."customerKey"
		GROUP BY C."customerKey")
SELECT
"customerSegment",
COUNT("customerKey") AS "totalCustomers"
FROM( 
SELECT
	"customerKey",
	--"totalSpending",
	--"lifeSpanMonths",
	CASE
		WHEN "lifeSpanMonths" >= 12 AND "totalSpending" > 5000 THEN 'VIP'
		WHEN "lifeSpanMonths" >= 12 AND "totalSpending" <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS "customerSegment"
FROM "customerSpending")t
GROUP BY "customerSegment"
ORDER BY "totalCustomers" DESC