-- BASIC QUESTIONS

--1. Retrieve the total number of orders placed.
Select Count(Order_id) as Total_orders from Orders


--2. Calculate the total revenue generated from pizza sales.
Select 
Round(Sum(order_details.quantity * pizzas.price), 2) as total_sales
From order_details
Join pizzas on pizzas.pizza_id = order_details.pizza_id


--3. Identify the highest-priced pizza.
Select Top 1 pizza_types.name, Round(pizzas.price, 2) 
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price Desc;


--4. Identify the most common pizza size ordered.

Select pizzas.size, Count(order_details.order_details_id) As Order_count
From pizzas
join
order_details on pizzas.pizza_id = order_details.pizza_id
Group by pizzas.size
Order by Order_count Desc;


--5. List the top 5 most ordered pizza types along with their quantities.

Select Top 5 pizza_types.name,pizza_types.pizza_type_id, Sum(order_details.quantity) As order_quantity
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name , pizza_types.pizza_type_id
order by order_quantity Desc;


/*    INTERMEDIATE QUESTIONS    */

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.

Select pizza_types.category, Sum(order_details.quantity) As Total_quantity
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by Total_quantity Desc;


-- 2. Determine the distribution of orders by hour of the day.

Select DATEPART(HOUR, [time]) as Hour, count(order_id) as Order_count from orders
group by DATEPART(HOUR, [time])
order by Hour Desc;


-- 3. Join relevant tables to find the category-wise distribution of pizzas.

Select category, Count(Name) As Number_Of_Category from pizza_types
group by category
order by category Desc;


--4. Group the orders by date and calculate the average number of pizzas ordered per day.
Select Avg(quant) as PizzaOrdered_perday from 
(Select orders.date, Sum(order_details.quantity) as quant
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.date) as Order_Quantity;


--5. Determine the top 3 most ordered pizza types based on revenue.

Select Top 3 pizza_types.name , Sum(order_details.quantity*pizzas.price) as Revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name  
order by  Revenue Desc;


/*        ADVANCED QUESTIONS       */

-- 1. Calculate the percentage contribution of each pizza type to total revenue.

Select pizza_types.category, 
Round(Sum(order_details.quantity*pizzas.price)/ (Select 
Round(Sum(order_details.quantity * pizzas.price), 2) as total_sales
From order_details
Join pizzas on pizzas.pizza_id = order_details.pizza_id) * 100,2)as Revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by Revenue Desc;


-- 2. Analyze the cumulative revenue generated over time.

/*Cumulative means first day earning 200, 
second day 300 then second day income will be 500, 
now third day 450 then cumulative is 950 */

select date, Round(Sum(Revenue) Over(order by date),2) as Cum_revenue
from
(Select orders.date, 
Sum(order_details.quantity*pizzas.price) As Revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) As Sales

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH PizzaRevenue AS (
    SELECT pizza_types.category, 
           pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS Revenue,
           RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS RN
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
)
SELECT category, name, Revenue, RN
FROM PizzaRevenue
WHERE RN <= 3;