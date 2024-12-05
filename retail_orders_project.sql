use testpro;
select * from df_orders order by product_id;
##q1 find top 10 highest revenue generating products 
select product_id,sum(sale_price) as sales from df_orders  group by product_id order by sales desc limit 10;
##q2 find highest selling products in each region 
desc df_orders;
select distinct region from df_orders;
with rank_region as (select product_id,sum(sale_price) as sales ,region, rank() over(partition by region order by sum(sale_price) desc) as ranks  from df_orders  group by product_id,region order by sales desc)
select * from rank_region where ranks <= 5 order by region;
##q3 find month over month growth comparison  sales for eg jan 2022 vs jan 2023 
with sale2022 as (select monthname(order_date)as s2month, sum(sale_price) as sales2022 from df_orders where year(order_date) =2022 group by s2month order by s2month),
sale2023 as (select monthname(order_date)as s3month, sum(sale_price) as sales2023 from df_orders where year(order_date) =2023 group by s3month order by s3month)
select s2.s2month as month,s2.sales2022 as sales2022,s3.sales2023 as sales2023 from sale2022 as s2 join sale2023 as s3 on s2.s2month = s3.s3month ;
##q4 for each category which month had highest sales 
select distinct category from df_orders;
with rank_category as (select category, monthname(order_date) as months,sum(sale_price) as sales,rank() over(partition by category order by sum(sale_price) desc) as ranks   from df_orders group by category,months)
select * from rank_category where ranks = 1;
##q5 which sub_category had the highest growth by profit in 2023 compared to 2022
select  sub_category,sum(profit)as pr,year(order_date) as years from df_orders group  by sub_category,years order by years;
with sub2022 as (select sub_category, year(order_date) as years,round(sum(profit),2) as pr2022 from df_orders where year(order_date) = 2022 group by sub_category,year(order_date) ),
sub2023 as (select sub_category, year(order_date) as years,round(sum(profit),2) as pr2023 from df_orders where year(order_date) = 2023 group by sub_category,year(order_date))
select s2.sub_category as sub_category,s2.pr2022 as pr2022,s3.pr2023 as pr2023, ((s3.pr2023 -s2.pr2022)/s2.pr2022)*100 as growth 
 from sub2022 as s2 join sub2023 as s3 on s2.sub_category = s3.sub_category where s3.pr2023>s2.pr2022 order by growth desc   ;