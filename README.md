# 8-Week-SQL-Challenge
# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-1/). 

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

***

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

***

## Question and Solution

**1. What is the total amount each customer spent at the restaurant?**

````sql
  SELECT s.customer_id, 
  SUM(m.price) AS total_sales
  FROM sales s
  INNER JOIN menu m
  ON s.product_id = m.product_id
  GROUP BY s.customer_id
  ORDER BY s.customer_id ASC; 
````

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT customer_id, 
   COUNT(DISTINCT(order_date)) AS visit_count
   from sales
   GROUP BY customer_id;
````


#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

**3. What was the first item from the menu purchased by each customer?**

````sql
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


````


#### Answer:
| customer_id | product_name | 
| ----------- | -----------  |
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first order is sushi .
- Customer B's first order is curry.
- Customer C's first order is ramen.



***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
 SELECT TOP 1 m.product_name,
	 COUNT(m.product_name)AS prod_count
	 FROM sales s
	 INNER JOIN menu m
	 ON s.product_id = m.product_id
	 GROUP BY m.product_name
	 ORDER BY COUNT(m.product_name) DESC
````


#### Answer:
| product_name | prod_count | 
| ----------- | ----------- |
| ramen       | 8           |


- Most purchased item on the menu is ramen which is 8 times.

***

**5. Which item was the most popular for each customer?**

````sql
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
````

*Each user may have more than 1 favourite item.*



#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me.

***

**6. Which item was purchased first by the customer after they became a member?**

```sql
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
 
```

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | ramen        |
| B           | sushi        |

- Customer A's first order as a member is ramen.
- Customer B's first order as a member is sushi.

***

**7. Which item was purchased just before the customer became a member?**

````sql
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
````

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | sushi        |
| B           | sushi        |

- Both customers' last order before becoming members are sushi.

***

**8. What is the total items and amount spent for each member before they became a member?**

```sql
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
```


#### Answer:
| customer_id | total_items_ordered | total_amount_spent |
| ----------- | ----------          |------------------  |
| A           | 2                   |  25                |
| B           | 3                   |  40                |

Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
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
```

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
WITH dates_cte AS (
  SELECT 
    customer_id, 
      join_date, 
      join_date + 6 AS valid_date, 
      DATE_TRUNC(
        'month', '2021-01-31'::DATE)
        + interval '1 month' 
        - interval '1 day' AS last_date
  FROM members
)

SELECT 
  s.customer_id, 
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * menu.price
    ELSE 10 * m.price END) AS points
FROM sales s
INNER JOIN dates_cte AS dates
  ON s.customer_id = dates.customer_id
  AND dates.join_date <= s.order_date
  AND s.order_date <= dates.last_date
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY sales.customer_id;
```

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1020 |
| B           | 320 |

- Total points for Customer A is 1,020.
- Total points for Customer B is 320.

***

## BONUS QUESTIONS

**Join All The Things**

**Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)**

```sql
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
```
 
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

***

**Rank All The Things**

**Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.**

```sql
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
```

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL

***
