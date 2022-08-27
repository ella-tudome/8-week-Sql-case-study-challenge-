-- CLEANING RUNNER_ORDER TABLE 
SELECT 
	order_id,
	runner_id,
	CASE
		WHEN pickup_time ='null' THEN NULL 
		ELSE pickup_time 
	 END AS pickup_time,
	CASE WHEN distance = 'null' THEN NULL 
		 WHEN distance LIKE '%km' THEN TRIM ('km' FROM distance)
		  ELSE distance 
	 END AS distance,
	CASE WHEN duration LIKE 'null'THEN NULL 
		ELSE substring(duration,1,2)
	END AS duration,
	CASE  WHEN cancellation IN ('null','') THEN NULL 
		  ELSE cancellation 
	 END AS cancelation 
	 INTO runner_orders_cleaned 
FROM runner_orders

---- CLEANING CUSTOMER_ORDER TABLE

SELECT 
	order_id,
	customer_id,
	pizza_id,
	CASE 
		WHEN exclusions IN ('null','') THEN NULL 
		ELSE exclusions END AS exclusions,  
	CASE 
		WHEN extras  IN ('null','') THEN NULL
		ELSE extras  END AS extras,
		order_time 
INTO customer_orders_cleaned
FROM customer_orders

---- ALTERING DATA TYPE OF CUSTOMER ORDER TABLE 
ALTER TABLE runner_orders_cleaned 
	ALTER COLUMN pickup_time TYPE timestamp USING pickup_time::timestamp without time zone,
	ALTER COLUMN distance TYPE  float USING distance::double precision,
	ALTER COLUMN duration TYPE  int USING duration::integer
