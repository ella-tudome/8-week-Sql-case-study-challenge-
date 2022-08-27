


--question 1  How many runners signed up for each 1 week period? 
SELECT 
       EXTRACT(week FROM registration_date) AS week,
       count(runner_id)AS sign_up 
FROM runners 
GROUP BY week
ORDER BY sign_up DESC 


--question 2--- What was the average time i minutes it took for each runner to arrive at the pizza runner HQ to pick up the order?
SELECT
	  runner_id,
      ROUND(AVG(EXTRACT(minute FROM pickup_time-order_time))) AS avg_pickup
FROM  customer_orders_cleaned c
      JOIN runner_orders_cleaned r
      ON c.order_id= r.order_id 
GROUP BY runner_id
ORDER BY runner_id 

--question 3--- is there any relationship between the number of pizza and how long the order takes to prepare? 
WITH prep_cte AS 
     (SELECT 
	  	c.order_id, 
	 	count(pizza_id)AS no_pizza,
	  	EXTRACT(minute FROM pickup_time-order_time) AS prep_time,
	    EXTRACT(minute FROM pickup_time-order_time)/count(pizza_id) AS prep_time_per_pizza
FROM  
       customer_orders_cleaned c 
	   JOIN runner_orders_cleaned r
	   ON c.order_id = r.order_id 
WHERE cancelation ISNULL 
GROUP BY c.order_id,prep_time)
SELECT 
       prep_cte.no_pizza,
       avg(prep_time)AS avg_prep_time,
       round(avg(prep_time_per_pizza))AS avg_prep_time_per_pizza 
FROM prep_cte 
GROUP BY prep_cte.no_pizza
ORDER BY no_pizza DESC

--question 4--what was the average distance travelled for each customer?
SELECT 
	  customer_id,	
	  round(avg(distance)) AS avg_distance_traveled_km
FROM  customer_orders_cleaned c 
	  JOIN runner_orders_cleaned r 
      ON c.order_id = r.order_id 
GROUP BY customer_id
ORDER BY customer_id 

--question 5-- what was the differnece between the longest and shortest delivery times for all orders?
SELECT min(duration) AS min_time, 
       max(duration) AS max_time,
       max(duration)-min(duration) AS difference 
 FROM runner_orders_cleaned
 
---question 6--- What was tha average speed for each runner for each delivery and do you notice any trend for thode values?
 SELECT 
      runner_id,
      order_id,
      round(distance/duration * 60)AS speed_hr
FROM  runner_orders_cleaned 
WHERE cancelation ISNULL 
ORDER BY runner_id, order_id 

QUESTION 7--- what was the sucessful delivery  percenatge  for each runner ?
SELECT 
      runner_id,
      count(order_id)AS orders_made,
      count(distance) AS sucessful_orders,
      count(distance)/count(order_id)::float * 100 AS percent_of_success
FROM  runner_orders_cleaned
GROUP BY runner_id 
ORDER BY runner_id
