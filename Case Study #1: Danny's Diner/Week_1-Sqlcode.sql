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
select 
  customer_id, 
  sum(price) 
from 
  sales s 
  join menu m on s.product_id = m.product_id 
group by 
  customer_id 
order by 
  customer_id 
  ---------------------------------------------------------------------------------
  --2. How many days has each customer visited the restaurant?
select 
  customer_id, 
  count(distinct order_date) 
from 
  sales 
group by 
  customer_id 
  --------------------------------------------------------
  --3 What was the first item from the menu purchased by each customer?
  with f_order as(
    select 
      customer_id, 
      product_name, 
      rank() over (
        partition by customer_id 
        order by 
          order_date
      ) as rank_no 
    from 
      sales s 
      join menu m on s.product_id = m.product_id
  ) 
select 
  distinct customer_id, 
  product_name 
from 
  f_order 
where 
  rank_no = 1
  ----------------------------------------------------------
  --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select 
  product_name, 
  count(product_name) 
from 
  sales s 
  join menu m on s.product_id = m.product_id 
group by 
  product_name 
limit 1 
  -------------------------------------------------------
  --5. Which item was the most popular for each customer?
select 
  customer_id, 
  string_agg(product_name, ',') 
from 
  (
    with prod_name as (
      select 
        distinct customer_id, 
        product_name, 
        count(m.product_id) over (
          partition by customer_id, product_name
        ) as cou_nt 
      from 
        sales s 
        join menu m on s.product_id = m.product_id
    ) 
    select 
      *, 
      dense_rank() over (
        partition by customer_id 
        order by 
          cou_nt
      ) as rank 
    from 
      prod_name
  ) sub 
where 
  sub.rank = 1 
group by 
  sub.customer_id -----------------------------------------------------
  
  --6. Which item was purchased first by the customer after they became a member?
select 
  customer_id, 
  product_name 
from 
  (
    with mem_date as (
      select 
        s.customer_id, 
        order_date, 
        product_name, 
        join_date 
      from 
        sales s 
        join menu m on s.product_id = m.product_id 
        join members mb on s.customer_id = mb.customer_id 
      where 
        order_date >= join_date 
      order by 
        customer_id, 
        order_date
    ) 
    select 
      *, 
      row_number() over (partition by customer_id) as r_num 
    from 
      mem_date
  ) sub 
where 
  r_num = 1 
  
  ------------------------------------------------
  -- 7. Which item was purchased just before the customer became a member? 
select 
  customer_id, 
  product_name 
from 
  (
    with b_mem as(
      select 
        s.customer_id, 
        order_date, 
        product_name, 
        join_date 
      from 
        sales s 
        join menu m on s.product_id = m.product_id 
        join members mb on s.customer_id = mb.customer_id 
      where 
        order_date < join_date
    ) 
    select 
      *, 
      row_number() over (
        partition by customer_id 
        order by 
          order_date desc
      ) as r_num 
    from 
      b_mem
  ) sub 
where 
  r_num = 1 
  ------------------------------------------------
  --8 What is the total items and amount spent for each member before they became a member?
  with b_mem as(
    select 
      s.customer_id, 
      order_date, 
      price 
    from 
      sales s 
      join menu m on s.product_id = m.product_id 
      join members mb on s.customer_id = mb.customer_id 
    where 
      order_date < join_date
  ) 
select 
  customer_id, 
  count(product_name), 
  sum(price) 
from 
  b_mem 
group by 
  customer_id --9   If each $1 spent equates to 10 points and sushi has a 2x points multiplier --how many points would each customer have?
  with point_sys as (
    select 
      customer_id, 
      product_name, 
      price, 
      case when product_name = 'sushi' then 20 * price else 10 * PRICE end as cond 
    from 
      sales s 
      join menu m on s.product_id = m.product_id
  ) 
select 
  customer_id, 
  SUM(cond) as point 
from 
  point_sys 
group by 
  customer_id 
order by 
  point desc
  ---------------------------------------------
  --10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  --     not just sushi - how many points do customer A and B have at the end of January?
  with mem_point as (
    select 
      s.customer_id, 
      order_date, 
      product_name, 
      price, 
      join_date, 
      case when order_date between join_date 
      and join_date + interval '6 days' then 20 * price else 10 * price end as cond 
    from 
      sales s 
      join menu m on s.product_id = m.product_id 
      join members mb on s.customer_id = mb.customer_id
  ) 
select 
  customer_id, 
  sum(cond) 
from 
  mem_point 
where 
  extract(
    month 
    from 
      order_date
  ) = 1 
group by 
  customer_id
  
  ------------------------------------
  -- BONUS QUESTION 1; Join All The Things
  create table joined as 
select 
  s.customer_id, 
  product_name, 
  price, 
  case when order_date >= join_date then 'Y' else 'N' end as member 
from 
  sales s 
  left join menu m on s.product_id = m.product_id 
  left join members mb on s.customer_id = mb.customer_id 
select 
  * 
from 
  joined 
  -- BONUS QUESTION 2; Rank All The Things
  create table ranked as with gen_table as (
    select 
      s.customer_id, 
      product_name, 
      price, 
      order_date, 
      case when order_date >= join_date then 'Y' else 'N' end as member 
    from 
      sales s 
      left join menu m on s.product_id = m.product_id 
      left join members mb on s.customer_id = mb.customer_id
  ) 
select 
  *, 
  case when member = 'Y' then RANK() over (
    partition by customer_id, 
    member 
    order by 
      order_date
  ) else null end as RANKING 
from 
  gen_table
