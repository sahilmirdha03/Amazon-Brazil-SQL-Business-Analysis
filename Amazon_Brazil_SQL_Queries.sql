#Q1. Find the total number of orders fulfilled by each seller state?
select sellers.seller_state ,count(orders.order_id) total_orders
from sellers join order_items
using(seller_id)
join orders
using(order_id)
where orders.order_status="delivered"
group by 1;

#Q2. For each product category, calculate the cumulative revenue generated as orders come in over time.?
with cte as(select products.product_category_name,sum(order_items.price) revenue 
,date(orders.order_purchase_timestamp) order_date
from products join order_items
using(product_id)
join orders
using(order_id)
group by 1,3)
select product_category_name , revenue, order_date,
sum(revenue)over(partition by product_category_name order by order_date) running_total from cte;

#Q3. Which payment method do customers use the most, and what is the average order value for each payment type? 

 select payment_type,count(order_id) total_payments,round(avg(payment_value),2) avg_order_value
 from order_payments
 group by 1
;

#Q4.Find the customer who has spent the most money across all their orders.    
select customers.customer_id,sum(order_payments.payment_value ) total_spent
from customers join orders
using(customer_id)
join order_payments
using(order_id)
group by 1
order by total_spent desc     
limit 1;

#Q5.Find the average review score for each product category.?
select products.product_category_name ,avg(order_reviews.review_score) as avg_score
from products join order_items
using(product_id)
JOIN order_reviews
using(order_id)
group by 1;


#Q6. Find the total number of orders placed by each customer, broken down by the state they live in. 

select customers.customer_unique_id, customers.customer_state,count(orders.order_id) total_orders
from customers join orders
using(customer_id)
group by 1,2 ;

#Q7.Identify sellers who registered on the platform but have never fulfilled a single order. 

select sellers.seller_id,count(distinct case when
orders.order_status="delivered"
then orders.order_id end) as count
from sellers left join order_items
using(seller_id)
left join orders
using(order_id)
group by 1
having count=0;

#Q8.Find the top 5 product categories by total revenue. 
select products.product_category_name,round(sum(order_items.price),2) total_revenue
from products join order_items
using(product_id)
group by 1
order by total_revenue desc
limit 5 ;

#Q9.Find the median delivery time (in days) between order placement and actual delivery.
with cte as(select order_status, datediff(order_delivered_customer_date,order_purchase_timestamp)  as dayss
from orders
where  order_status="delivered"),
cte1 as(select *,
row_number()over( order by dayss) pos,
count(dayss) over() n from cte)
select avg(dayss) median_delivery_time  from cte1
where pos in(ceil(n/2),ceil((n+1)/2))
;

#Q10. Find all products that have never been ordered. 

select products.product_category_name,products.product_id
from products left join order_items
using(product_id)
where order_items.product_id is null;

#Q11.Find sellers who have fulfilled more orders than the average seller on the platform. 

with cte as(SELECT sellers.seller_id,count( distinct orders.order_id ) orders
from sellers left join order_items
using(seller_id)
left join orders
using(order_id)
group by 1)
select * from(select *,
avg(orders)over () as avgg from cte) as a
where orders>avgg;

#Q12. Find which Brazilian states have the highest average customer review score for orders delivered there. 

select customers.customer_state,avg(order_reviews.review_score) avgg
from customers join orders
using(customer_id)
join order_reviews
using(order_id)
group by 1
order by avgg desc;

#Q13. Identify customers who have placed orders but never left a review. 

select customers.customer_id,order_reviews.review_id
from customers left join orders
using(customer_id)
left join order_reviews
using(order_id)
where order_reviews.review_id is null;

#Q14. Find the month with the highest number of orders placed across the entire platform. 
select date_format(order_purchase_timestamp,"%M") months, count(order_id) orders
from orders
group by 1
order by orders desc
limit 1;
