select * from customer limit 20

--- what is the renvenue by gender
SELECT gender,
SUM(purchase_amount)
FROM customer
GROUP BY gender
--- which customer paid more than avg even after discount
SELECT *
FROM customer
WHERE discount_applied = 'Yes' AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer)
--- which are the top 5 products with highest average review rating
SELECT item_purchased, AVG(review_rating) AS "Average review rating"
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5
--- comapre avg purchase amounts b/w standard and express
SELECT shipping_type,
ROUND(AVG(purchase_amount),2)
FROM customer
WHERE shipping_type IN ('Standard','Express')
GROUP BY shipping_type
--- Compare avg spend and total revenue b/w subs and non subs
SELECT subscription_status,
COUNT(customer_id) AS total_customers,
ROUND(AVG(purchase_amount),2) AS avg_spend,
ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC
--- which 5 products have highest percentage of purchases with discounts
SELECT item_purchased, 
ROUND(100* SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS per
FROM customer
GROUP BY item_purchased
ORDER BY per DESC
LIMIT 5
---segment loyal,new , returning customer
with customer_type AS (
SELECT customer_id, previous_purchases,
CASE 
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	WHEN previous_purchases > 10 THEN 'Loyal'
	END AS customer_segment
FROM customer
)
SELECT customer_segment, 
COUNT(*) AS "Num. of customers"
FROM customer_type
GROUP BY customer_segment
--- top 3 in each category
WITH item_count AS (
SELECT category,
item_purchased,
COUNT(customer_id) AS total_orders,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
FROM customer
GROUP BY category, item_purchased
)
SELECT item_rank, category, item_purchased, total_orders
FROM item_count
WHERE item_rank <= 3

--- Are customers who repeat orders likely subscribe?
SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status 

--- What is the revenue by each age
SELECT age_group,
SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC
