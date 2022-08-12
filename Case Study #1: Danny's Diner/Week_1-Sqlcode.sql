-- Done with Postgres
--by Emmanuella Tudome 
CREATE SCHEMA dannys_diner;
SET 
  search_path = dannys_diner;
CREATE TABLE sales (
  "customer_id" VARCHAR(1), 
  "order_date" DATE, 
  "product_id" INTEGER
);
INSERT INTO sales (
  "customer_id", "order_date", "product_id"
) 
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
INSERT INTO menu (
  "product_id", "product_name", "price"
) 
VALUES 
  ('1', 'sushi', '10'), 
  ('2', 'curry', '15'), 
  ('3', 'ramen', '12');
CREATE TABLE members (
  "customer_id" VARCHAR(1), 
  "join_date" DATE
);
INSERT INTO members ("customer_id", "join_date") 
VALUES 
  ('A', '2021-01-07'), 
  ('B', '2021-01-09');
---------------------------------------------------------------------------------
-- 1.What is the total amount each customer spent at the restaurant?
SELECT
	customer_id,
	sum(price) AS amnt_spnt
FROM
	sales s
JOIN menu m 
ON
	s.product_id = m.product_id
GROUP BY
	customer_id
ORDER BY
	customer_id 
 
  ---------------------------------------------------------------------------------
  --2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
	count(DISTINCT order_date)
FROM
	sales s
GROUP BY
	customer_id
  --------------------------------------------------------
  --3 What was the first item from the menu purchased by each customer?
  WITH f_order AS
(
SELECT
	customer_id,
	order_date,
	m.product_name,
	ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY order_date) AS menu_o
FROM
	sales s
JOIN menu m ON
	s.product_id = m.product_id)
SELECT
	customer_id,
	product_name
FROM
	f_order
WHERE
	menu_o = 1
  ----------------------------------------------------------
  --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	product_name,
	count(product_name) AS times_purchased
FROM
	sales s
JOIN menu m ON
	s.product_id = m.product_id
GROUP BY
	product_name
LIMIT 1
 
  -------------------------------------------------------
  --5. Which item was the most popular for each customer?
WITH prod_name AS (
SELECT
		customer_id,
		product_name,
		count(m.product_id) AS cou_nt,
		DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY count(m.product_id)) AS rank
FROM
		sales s
JOIN menu m ON
		s.product_id = m.product_id
GROUP BY
	customer_id,
	m.product_name
		)
		SELECT
	customer_id,
	string_agg(product_name, ',')
FROM
		prod_name
WHERE
	prod_name.rank = 1
GROUP BY
	customer_id
	
 -----------------------------------------------------
  
  --6. Which item was purchased first by the customer after they became a member?
WITH mem_order AS (
	SELECT
		s.customer_id,
		order_date,
		join_date,
		product_name,
	    ROW_NUMBER() OVER (PARTITION BY s.customer_id)
	FROM
		sales s
	JOIN menu m ON
		s.product_id = m.product_id
	JOIN members mb ON
		s.customer_id = mb.customer_id
	WHERE
		order_date >= join_date
	ORDER BY
		s.customer_id)
		SELECT customer_id ,product_name 
		FROM
		mem_order
		where
	row_number = 1
  
  ------------------------------------------------
  -- 7. Which item was purchased just before the customer became a member? 
WITH before_mem AS (
	SELECT
		s.customer_id,
		order_date,
		join_date,
		product_name,
	ROW_NUMBER () OVER (PARTITION BY s.customer_id)
	FROM 
		sales s
	JOIN menu m ON
		s.product_id = m.product_id
	JOIN members mb ON
		s.customer_id = mb.customer_id
	WHERE
		order_date < join_date
	ORDER BY
		s.customer_id,
		order_date DESC)
	SELECT
		customer_id, 
		product_name
	FROM
		before_mem
WHERE
		ROW_NUMBER = 1
  ------------------------------------------------
  --8 What is the total items and amount spent for each member before they became a member?
  SELECT
	s.customer_id ,
	count(product_name) AS food_items_bought,
	sum(price)AS total_amount_spent
FROM
		sales s
JOIN menu m ON
		s.product_id = m.product_id
JOIN members mb ON
		s.customer_id = mb.customer_id
WHERE
		order_date < join_date
GROUP BY
	s.customer_id
ORDER BY
	customer_id
  ------------------------
  9   If each $1 spent equates to 10 points and sushi has a 2x points multiplier --how many points would each customer have?
SELECT
	customer_id,
	sum(point_earned)
FROM
		 (
	SELECT
		customer_id,
		product_name ,
		CASE
			WHEN product_name = 'sushi' THEN 20 * price
			ELSE 10 * price
		END AS point_earned
	FROM
		sales s
	JOIN menu m ON
		s.product_id = m.product_id)sub
GROUP BY
	customer_id
ORDER BY
	customer_id
  ---------------------------------------------
  --10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  --     not just sushi - how many points do customer A and B have at the end of January?
 SELECT
	customer_id,
	sum(mem_point) AS points_earn_in_JAN
FROM 
	(
	SELECT
		s.customer_id,
		order_date,
		product_name,
		price,
		join_date,
		CASE
			WHEN order_date BETWEEN join_date AND join_date + INTERVAL '7days'
			OR product_name = 'sushi' THEN 20 * price
			ELSE 10 * price
		END AS mem_point
	FROM
		sales s
	JOIN menu m ON
		s.product_id = m.product_id
	JOIN members mb ON
		s.customer_id = mb.customer_id
	ORDER BY
		s.customer_id,
		order_date)sub
WHERE
	EXTRACT(MONTH
FROM
	order_date)= 1
GROUP BY
	customer_id
  
  ------------------------------------
  -- BONUS QUESTION 1; Join All The Things
CREATE TABLE joined AS 
SELECT
	s.customer_id,
	order_date,
	product_name,
	price,
	CASE
		WHEN order_date >= join_date THEN 'Y'
		ELSE 'N'
	END AS MEMBER
FROM
	sales s
LEFT JOIN menu m ON
	s.product_id = m.product_id
LEFT JOIN members mb ON
	s.customer_id = mb.customer_id
ORDER BY
	customer_id,
	order_date  
  -- BONUS QUESTION 2; Rank All The Things
 	CREATE TABLE ranked AS WITH gen_table AS (
SELECT
	s.customer_id,
	order_date ,
	product_name,
	price,
	CASE
		WHEN order_date >= join_date THEN 'Y'
		ELSE 'N'
	END AS MEMBER
FROM
	sales s
LEFT JOIN menu m ON
	s.product_id = m.product_id
LEFT JOIN members mb ON
	s.customer_id = mb.customer_id
ORDER BY
	customer_id,
	order_date 
  ) 
SELECT
	*,
	CASE
		WHEN MEMBER = 'Y' THEN RANK() OVER
		( PARTITION BY customer_id,member ORDER BY order_date)
		ELSE NULL
	END AS RANKING
FROM
	gen_table
