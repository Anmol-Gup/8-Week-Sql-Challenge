--Case Study #1 - Danny's Dinner
--https://8weeksqlchallenge.com/case-study-1/
-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,SUM(price) AS Amount
FROM dannys_diner.sales s JOIN dannys_diner.menu m 
ON m.product_id=s.product_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(join_date) AS num_days_visited
FROM dannys_diner.members
GROUP BY customer_id;
