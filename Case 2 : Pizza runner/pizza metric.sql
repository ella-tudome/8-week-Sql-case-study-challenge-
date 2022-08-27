
---question 1-------- How many pizza were ordere?
SELECT 
	count(order_id) AS no_of_orders 
FROM customer_orders_cleaned 

-- question 2------- How many uniue customer orders were made? 
SELECT
	count (DISTINCT order_id) AS Unique_orders  
FROM customer_orders_cleaned 


--question 3----How namy sucessful orders were delivered?
SELECT
	  runner_id,
	  count(order_id)AS no_of_sucessful_orders
FROM  runner_orders_cleaned
WHERE cancelation ISNULL 
GROUP BY runner_id 

--question 4------- How many of each type of pizza were delivered? 
SELECT
	 pn.pizza_name,
	 count(c.order_id) AS pizza_delivered
FROM
     customer_orders_cleaned c 
	 JOIN runner_orders_cleaned r 
	 ON c.order_id=r.order_id 
	 JOIN pizza_names pn 
	 ON c.pizza_id=pn.pizza_id
WHERE r.cancelation ISNULL
GROUP BY pn.pizza_name
ORDER BY pizza_name


--question 5--- How many Vegertian and Meatlovers were ordered by each customer?
SELECT 
	  customer_id,
	  pn.pizza_name, 
	  count(c.order_id) AS pizza_ordered 
FROM 
      customer_orders_cleaned c 
	  JOIN runner_orders_cleaned r 
	  ON c.order_id=r.order_id 
	  JOIN pizza_names pn
	  ON c.pizza_id=pn.pizza_id
GROUP BY pn.pizza_name,customer_id 
ORDER BY customer_id 


--question 6---- What was the maximum number of pizzas delivered in a single order?
SELECT  
	  c.order_id ,
	  count(pizza_id) AS pizza_ordered  
FROM 
	  customer_orders_cleaned c
	  JOIN runner_orders_cleaned r
	  ON c.order_id =r.order_id 
GROUP BY c.order_id 
ORDER BY pizza_ordered DESC
LIMIT 1 

--question 7 ------ for each customer, how many deliered pizzas had at least 1 chnage and how many had no change?
SELECT customer_id,
	   SUM(CASE WHEN exclusions ISNULL OR extras ISNULL THEN 1 ELSE 0 END) AS no_change,
	   SUM(CASE WHEN exclusions IS NOT NULL AND  extras IS NOT NULL THEN 1 ELSE 0 END) AS num_of_changes_made
FROM 
       customer_orders_cleaned c
	   JOIN runner_orders_cleaned r
       ON c.order_id = r.order_id 
WHERE  cancelation ISNULL
GROUP BY customer_id 
ORDER BY customer_id 

--question 8---- how many pizzas were delivered that had both exclusions and extras?
SELECT 
	   SUM(CASE WHEN exclusions IS NOT NULL AND  extras IS NOT NULL THEN 1 ELSE 0 END) AS had_exclusions_and_extras
FROM 
		customer_orders_cleaned c
        JOIN runner_orders_cleaned r
        ON c.order_id = r.order_id 
WHERE   cancelation ISNULL

--question 9----- What was te totla volumme of pizzas ordered by each hour of the day ? 
SELECT 
	   EXTRACT(HOUR  FROM order_time) AS time_of_day, 
	   count(order_id )
FROM   customer_orders_cleaned 
GROUP BY time_of_day

---question 10--- whatwas the volume of orders for each day if the week?
SELECT  
	   to_char(order_time,'dy') AS day_of_week,
	   count(order_id) AS pizza_ordered 
FROM   customer_orders_cleaned c
GROUP BY day_of_week 
ORDER BY 2 desc
