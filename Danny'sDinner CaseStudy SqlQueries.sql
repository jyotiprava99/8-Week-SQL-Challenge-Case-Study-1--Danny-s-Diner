CREATE DATABASE dannys_diner;

USE [dannys_diner];

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

  CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


  select * from sales
  select * from menu
  select * from members


  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
   SELECT s.customer_id, 
  SUM(m.price) AS total_sales
  FROM sales s
 INNER JOIN menu m
  ON s.product_id = m.product_id
 GROUP BY s.customer_id
 ORDER BY s.customer_id ASC; 

-- 2. How many days has each customer visited the restaurant?
   SELECT customer_id, 
   COUNT(DISTINCT(order_date)) AS visit_count
   from sales
   GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?
     WITH cte AS
	 (
	 SELECT 
	 customer_id, 
	 m.product_name,
	 ROW_NUMBER() OVER (PARTITION BY s.customer_id 
	 ORDER BY s.order_date) rownum
	 FROM sales s
	 INNER JOIN menu m
	 ON s.product_id = m.product_id
	 )
	 SELECT customer_id, product_name
	 FROM cte WHERE rownum = 1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
     SELECT TOP 1 m.product_name,
	 COUNT(m.product_name)AS prod_count
	 FROM sales s
	 INNER JOIN menu m
	 ON s.product_id = m.product_id
	 GROUP BY m.product_name
	 ORDER BY COUNT(m.product_name) DESC
	 

-- 5. Which item was the most popular for each customer?
       WITH item_count AS(
	   SELECT s.customer_id, m.product_name,
	   COUNT(*) AS order_count,
	   DENSE_RANK() OVER(PARTITION BY s.customer_id
	   ORDER BY COUNT(*) DESC) AS rn
	   FROM sales s
	   INNER JOIN menu m
	   ON s.product_id = m.product_id
	   GROUP BY s.customer_id, m.product_name
	   )
	   SELECT customer_id, product_name,
	   order_count
	   FROM item_count
	   WHERE rn =1

-- 6. Which item was purchased first by the customer after they became a member?
      WITH orders AS (
	  SELECT s.customer_id,m.product_name, s.order_date,
	  mb.join_date,
	  DENSE_RANK()OVER(PARTITION BY s.customer_id
	  ORDER BY order_date)AS rn
	  FROM menu m
	  INNER JOIN sales s
	  ON m.product_id = s.product_id
	  INNER JOIN members mb
	  ON s.customer_id = mb.customer_id
	  WHERE s.order_date > mb.join_date
	  )

	  SELECT customer_id,product_name
	  FROM orders
	  WHERE rn=1



-- 7. Which item was purchased just before the customer became a member?

      WITH orders AS (
	  SELECT s.customer_id,m.product_name, s.order_date,
	  mb.join_date,
	  DENSE_RANK()OVER(PARTITION BY s.customer_id
	  ORDER BY order_date DESC)AS rn
	  FROM menu m
	  INNER JOIN sales s
	  ON m.product_id = s.product_id
	  INNER JOIN members mb
	  ON s.customer_id = mb.customer_id
	  WHERE s.order_date < mb.join_date
	  )

	  SELECT customer_id,product_name
	  FROM orders
	  WHERE rn=1




-- 8. What is the total items and amount spent for each member before they became a member?
     SELECT s.customer_id,
	 COUNT(m.product_id) AS total_items_ordered,
	 SUM(price)AS total_amount_spent
	 FROM menu m
	 INNER JOIN sales s
	 ON m.product_id=s.product_id
	 INNER JOIN members mb
	 ON s.customer_id = mb.customer_id
	 WHERE s.order_date < mb.join_date
	 GROUP BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
       WITH points_cte AS (
  SELECT 
    m.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10 END AS points
  FROM menu m
)

SELECT 
  s.customer_id, 
  SUM(points_cte.points) AS total_points
FROM sales s
INNER JOIN points_cte
  ON s.product_id = points_cte.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
     WITH dates_cte AS (
  SELECT 
    customer_id, 
      join_date, 
      join_date + 6 AS valid_date, 
      DATE_TRUNC(
        'month', '2021-01-31':DATE)
        + interval '1 month' 
        - interval '1 day' AS last_date
  FROM members 
)

SELECT 
  s.customer_id, 
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * m.price
    ELSE 10 * m.price END) AS points
FROM sales s
INNER JOIN dates_cte AS dates
  ON s.customer_id = dates.customer_id
  AND dates.join_date <= s.order_date
  AND s.order_date <= dates.last_date
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;   



--BONUS QUESTIONS

--Join All The Things**

--Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)**

--sql
SELECT 
  s.customer_id, 
  s.order_date,  
  m.product_name, 
  m.price,
  CASE
    WHEN mb.join_date > s.order_date THEN 'N'
    WHEN mb.join_date <= s.order_date THEN 'Y'
    ELSE 'N' END AS member_status
FROM sales s
LEFT JOIN members mb
  ON s.customer_id = mb.customer_id
INNER JOIN menu m
  ON s.product_id = m.product_id
ORDER BY mb.customer_id, s.order_date

 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |



--Rank All The Things**

--Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.**

--sql
WITH customers_data AS (
  SELECT 
    s.customer_id, 
    s.order_date,  
    m.product_name, 
    m.price,
    CASE
      WHEN mb.join_date > s.order_date THEN 'N'
      WHEN mb.join_date <= s.order_date THEN 'Y'
      ELSE 'N' END AS member_status
  FROM sales s
  LEFT JOIN members mb
    ON s.customer_id = mb.customer_id
  INNER JOIN menu m
    ON s.product_id = m.product_id
)

SELECT 
  *, 
  CASE
    WHEN member_status = 'N' then NULL
    ELSE RANK () OVER (
      PARTITION BY customer_id, member_status
      ORDER BY order_date
  ) END AS ranking
FROM customers_data;
