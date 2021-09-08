/* Find the number of events that occur for each day for each channel*/

SELECT DATE_TRUNC('day', occurred_at), channel, COUNT(*) channel_count
FROM web_events
GROUP BY DATE_TRUNC('day', occurred_at), channel
ORDER BY 1

/* Find the average number of events for each channel*/

SELECT channel, AVG(channel_count)
FROM (
	SELECT DATE_TRUNC('day', occurred_at) occurred_date, channel, COUNT(*) channel_count
	FROM web_events
	GROUP BY DATE_TRUNC('day', occurred_at), channel
) t1
GROUP BY channel
ORDER BY 2 DESC

/* Use DATE_TRUNC to pull month level information about the first order ever placed 
in the orders table*/

SELECT MIN(occurred_at), DATE_TRUNC('month',MIN(occurred_at))
FROM orders

/* Use the result of the previous query to find only the orders that took place in
the same month and year as the first order, and then pull the average for each type
of paper in this month.*/
SELECT AVG(standard_qty) average_standard, AVG(gloss_qty) average_gloss, AVG(poster_qty) average_poster
FROM orders
JOIN (
	SELECT MIN(occurred_at), DATE_TRUNC('month',MIN(occurred_at)) first_order
	FROM orders
) t1
ON DATE_TRUNC('month',orders.occurred_at) = t1.first_order 
	
/* Provide the name of the sales_rep in each region with the largest amount
of total_amt_usd sales. */
-- Notice the question is a bit misleading as the author asked for the cummulative
-- total_amt_usd by each sales_rep (as shown in his solution). The solution provided below
-- is rather for sales_rep with an order with the largest total_amt_usd

SELECT r.name, s.name, o.total_amt_usd
FROM sales_reps s
JOIN (
	SELECT r.name, r.id, MAX(o.total_amt_usd) max_usd
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY r.name, r.id
) t1
ON s.region_id = t1.id
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.total_amt_usd = t1.max_usd


/* For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders
were placed? */

SELECT r.name, COUNT(o.total)
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY r.name
HAVING r.name = (SELECT name
FROM (
	SELECT r.name, r.id, SUM(o.total_amt_usd) sum_usd
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY r.name, r.id
	ORDER BY 3 DESC
	LIMIT 1
) t1)

/*How many accounts had more total purchases than the account name which has bought the most
standard_qty paper throughout their lifetime as a customer? */
SELECT COUNT(*)
FROM (
	SELECT account_id, SUM(total)
	FROM orders
	GROUP By account_id
	HAVING SUM(total) >	(SELECT sum_total
					 	FROM (
						 SELECT a.name, o.account_id, SUM(standard_qty) sum_standard_qty, SUM(total) sum_total
							FROM accounts a
							JOIN orders o
							ON o.account_id = a.id
							GROUP BY a.name, o.account_id
							ORDER BY 3 DESC
							LIMIT 1) t1)) t2
						 

/*For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel?*/

SELECT w.account_id, a.name, channel, COUNT(*)
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.account_id, a.name, channel
HAVING account_id = (SELECT account_id
FROM (
 	SELECT o.account_id, SUM(o.total_amt_usd)
	FROM orders o
	GROUP BY o.account_id
	ORDER BY 2 DESC
	LIMIT 1) t1)


/*What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total
spending accounts?*/

SELECT AVG(total_usd)
FROM (
  	SELECT account_id, SUM(total_amt_usd) total_usd
	  FROM orders
	  GROUP BY account_id
	  ORDER BY 2 DESC
	  LIMIT 10) t1


/*What is the lifetime average amount spent in terms of total_amt_usd, including only the
companies that spent more per order, on average, than the average of all orders.*/

/* Notice that this is different from the author’s solution which calculates the average 
amount spent per order rather than the “lifetime average amount spent in terms of total_amt_usd“.
The avg_spending_per_company and avg_per_order are included for creditability.*/

SELECT AVG(avg_usd) avg_per_order, AVG(total_usd) avg_spending_per_company
FROM (
  SELECT account_id com_id, AVG(total_amt_usd) avg_usd, SUM(total_amt_usd) total_usd
  FROM orders
  GROUP BY account_id
  HAVING AVG(total_amt_usd) > ( SELECT AVG(total_amt_usd)
  FROM orders)) t1


/* Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/

WITH t1 AS (
	SELECT s.name s_name, r.name r_name, SUM(o.total_amt_usd) total_usd
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY s.name, r.name
),
t2 AS (
	SELECT r_name t2_r_name, MAX(total_usd)max_usd
	FROM t1
	GROUP BY r_name
)
SELECT r_name, s_name, total_usd
FROM t1
WHERE total_usd IN (SELECT max_usd
                   FROM t2)


/* For the region with the largest sales total_amt_usd, how many total orders were placed? */

WITH t1 AS (
	SELECT r.name r_name, SUM(o.total_amt_usd)
	FROM orders o
	JOIN accounts a
	on o.account_id = a.id
	JOIN sales_reps s
	ON a.sales_rep_id = s.id
	JOIN region r
	ON s.region_id = r.id
	GROUP BY r.name
	ORDER BY 2 DESC
	LIMIT 1
)
SELECT r.name, COUNT(o.total_amt_usd)
FROM orders o
JOIN accounts a
on o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
WHERE r.name = ( SELECT r_name
				FROM t1)
GROUP BY r.name

/* How many accounts had more total purchases than the account name which has bought
the most standard_qty paper throughout their lifetime as a customer? */

WITH t1 AS (
	SELECT a.name a_name, SUM(o.standard_qty) o_standard_qty, SUM(o.total) o_total
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	GROUP BY a.name
	ORDER BY 2 DESC
)
SELECT a_name, o_total
FROM t1
WHERE o_total > (SELECT o_total
				FROM t1
				LIMIT 1)


/* For the customer that spent the most (in total over their lifetime as a customer)
total_amt_usd, how many web_events did they have for each channel? */

WITH t1 AS (
	SELECT w.account_id w_account_id, SUM(total_amt_usd) total_usd
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	JOIN web_events w
	ON w.account_id = a.id
	GROUP BY w_account_id
	ORDER BY 2 DESC
)
SELECT channel, COUNT(*)
FROM web_events
WHERE account_id = (SELECT w_account_id
				FROM t1
				LIMIT 1)
GROUP BY channel


/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10
total spending accounts? */

WITH t1 AS (
	SELECT a.id a_id, SUM(total_amt_usd) total_usd
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY a_id
	ORDER BY 2 DESC
	LIMIT 10
)
SELECT AVG(total_usd)
FROM t1


/* What is the lifetime average amount spent in terms of total_amt_usd, including only
the companies that spent more per order, on average, than the average of all orders.*/

WITH t1 AS (
	SELECT account_id, AVG(total_amt_usd)
	FROM orders
	GROUP BY account_id
	HAVING AVG(total_amt_usd) > ( SELECT AVG(total_amt_usd)
								 FROM orders)
	),
t2 AS (
	SELECT account_id, SUM(total_amt_usd) total_usd, AVG(total_amt_usd) avg_usd
	FROM orders
	GROUP BY account_id
	HAVING account_id IN (SELECT account_id
						 FROM t1)
	)
SELECT AVG(total_usd) average_lifetime_spending, AVG(avg_usd) average_per_order
FROM t2
							
