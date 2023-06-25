--Pizza Metrics
SET search_path = pizza_runner;

--1. How many pizzas were ordered?
SELECT COUNT(*) AS Total_Pizza_Ordered FROM customer_orders;

--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS Unique_Orders FROM customer_orders;

--3. How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(order_id) AS Total_Orders FROM runner_orders
WHERE cancellation IS NULL OR cancellation IN ('null','')
GROUP BY runner_id;

--4. How many of each type of pizza was delivered?
SELECT pizza_name,COUNT(*) AS Pizza_Ordered FROM customer_orders orders
JOIN pizza_names pizza 
ON pizza.pizza_id=orders.pizza_id
JOIN runner_orders runners
ON runners.order_id=orders.order_id
WHERE cancellation IS NULL OR cancellation IN ('null','')
GROUP BY pizza_name;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	customer_id,
	SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian_Orders,
    SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Meatlovers_Orders
FROM customer_orders orders
JOIN pizza_names pizza 
ON pizza.pizza_id=orders.pizza_id
GROUP BY customer_id
ORDER BY customer_id;

--6. What was the maximum number of pizzas delivered in a single order?
WITH max_pizza
AS
(
  SELECT order_id,COUNT(pizza_id) AS Pizza_Ordered 
  FROM customer_orders orders
  GROUP BY order_id
  ORDER BY Pizza_Ordered DESC
  LIMIT 1
)
SELECT order_id,Pizza_Ordered FROM max_pizza;

--7. For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?
WITH pizza_changes
AS
(
  SELECT customer_id,
  CASE
      WHEN exclusions IS NULL OR exclusions='' OR exclusions='null' 
      THEN 'NA' ELSE exclusions END exclusions,
  CASE
      WHEN extras IS NULL OR extras='' OR extras='null' 
      THEN 'NA' ELSE extras END AS extras
  FROM customer_orders orders 
  JOIN runner_orders runners
  ON orders.order_id =runners.order_id
)
SELECT customer_id,
	SUM(CASE WHEN exclusions='NA' AND extras='NA' THEN 1 ELSE 0 END) AS No_Changes,
	SUM(CASE WHEN exclusions<>'NA' OR extras<>'NA' THEN 1 ELSE 0 END) AS Changes
FROM pizza_changes
GROUP BY customer_id
ORDER BY customer_id;

--8. How many pizzas were delivered that had both exclusions and extras?
WITH pizza_exclusions_extras
AS
(
  SELECT customer_id,
  CASE
      WHEN exclusions IS NULL OR exclusions='' OR exclusions='null' 
      THEN 'NA' ELSE exclusions END exclusions,
  CASE
      WHEN extras IS NULL OR extras='' OR extras='null' 
      THEN 'NA' ELSE extras END AS extras
  FROM customer_orders orders 
  JOIN runner_orders runners
  ON orders.order_id =runners.order_id
  WHERE duration IS NOT NULL
)
SELECT COUNT(customer_id) AS Total_Pizza_Delivered
FROM pizza_exclusions_extras
WHERE exclusions<>'NA' AND extras<>'NA';

