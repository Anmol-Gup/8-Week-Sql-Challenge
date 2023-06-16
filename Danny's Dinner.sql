--Case Study #1 - Danny's Dinner
--https://8weeksqlchallenge.com/case-study-1/
-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,SUM(price) AS Amount
FROM dannys_diner.sales s JOIN dannys_diner.menu m 
ON m.product_id=s.product_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(distinct order_date) AS num_days_visited
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH first_item
AS
(
  SELECT customer_id,s.product_id,product_name,order_date,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rno 
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m
  ON m.product_id=s.product_id
) 
SELECT customer_id,product_name,order_date FROM first_item 
WHERE rno=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH most_purchased
AS
(
  SELECT product_name,COUNT(product_name) AS Total_Orders
  FROM dannys_diner.menu m JOIN dannys_diner.sales s
  ON s.product_id=m.product_id
  GROUP BY product_name
)
SELECT product_name,Total_Orders 
FROM most_purchased
ORDER BY Total_Orders DESC
LIMIT 1

-- 5. Which item was the most popular for each customer?
WITH most_popular_item
AS
(
  WITH most_popular_item_1
  AS
  (
  SELECT customer_id,product_name,COUNT(customer_id) AS orders
  FROM dannys_diner.sales s JOIN dannys_diner.menu m
  ON m.product_id=s.product_id
  GROUP BY customer_id,product_name
  ORDER BY customer_id,product_name
  )
  SELECT customer_id,product_name,orders,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY orders DESC) AS rno
  FROM most_popular_item_1
)
SELECT customer_id,product_name,orders
FROM most_popular_item WHERE rno=1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH member_first_item
AS
(
  SELECT mb.customer_id,product_name,order_date,join_date,
  ROW_NUMBER() OVER(PARTITION BY mb.customer_id ORDER BY order_date) AS rno
  FROM dannys_diner.members mb 
  JOIN dannys_diner.sales s
  ON s.customer_id=mb.customer_id
  JOIN dannys_diner.menu m
  ON m.product_id=s.product_id
  WHERE order_date>join_date
  ORDER BY mb.customer_id
)
SELECT customer_id,product_name,order_date,join_date FROM member_first_item
WHERE rno=1;

-- 7. Which item was purchased just before the customer became a member?
WITH member_first_item
AS
(
  SELECT mb.customer_id,product_name,order_date,join_date,
  ROW_NUMBER() OVER(PARTITION BY mb.customer_id ORDER BY order_date DESC) AS rno
  FROM dannys_diner.members mb 
  JOIN dannys_diner.sales s
  ON s.customer_id=mb.customer_id
  JOIN dannys_diner.menu m
  ON m.product_id=s.product_id
  WHERE order_date<join_date
  ORDER BY mb.customer_id
)
SELECT customer_id,product_name,order_date,join_date FROM member_first_item
WHERE rno=1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH member_amount_items
AS
(
  SELECT mb.customer_id,SUM(price) AS Amount, COUNT(s.product_id) AS Total_Item
  FROM dannys_diner.members mb 
  JOIN dannys_diner.sales s
  ON s.customer_id=mb.customer_id
  JOIN dannys_diner.menu m
  ON m.product_id=s.product_id
  WHERE order_date<join_date
  GROUP BY mb.customer_id
  ORDER BY mb.customer_id
)
SELECT customer_id,amount,total_item FROM member_amount_items;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte
AS
(
  SELECT 
      product_id,
      CASE
          WHEN product_name='sushi' then price*20
          ELSE price*10
      END AS points
  FROM dannys_diner.menu
)
SELECT customer_id,SUM(points) AS total_points
FROM points_cte p JOIN dannys_diner.sales s
ON s.product_id=p.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi-how many points
--do customer A and B have at the end of January?
WITH points_cte
AS
(
  SELECT 
      mb.customer_id,m.product_id,
      CASE
          WHEN product_name='sushi' OR order_date BETWEEN join_date AND join_date+6 THEN price*20
          ELSE price*10
      END AS points
  FROM dannys_diner.menu m
  JOIN dannys_diner.sales s
  ON m.product_id=s.product_id
  JOIN dannys_diner.members mb
  ON s.customer_id=mb.customer_id
  WHERE mb.customer_id in ('A','B') AND extract(month from order_date)=1
  ORDER BY mb.customer_id
)
SELECT customer_id,SUM(points) FROM points_cte
GROUP BY customer_id;
  
