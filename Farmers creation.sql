create schema if not exists farmers ;
use farmers ;

create table Farmers (farmer_id int auto_increment primary key,
farmer_name varchar(20),farmer_village varchar(20),phone varchar(10));
create table crops(crop_id int auto_increment primary key,
crop_name varchar(20),category varchar(20));
create table production( production_id int auto_increment primary key,
farmer_id int , crop_id int,harvest_date date, quantity_kg decimal(10,2), expiry_date date,
foreign key(farmer_id) references Farmers(farmer_id),
foreign key(crop_id) references crops(crop_id));
create table customers(customer_id int auto_increment primary key,
name varchar(20),
type enum('individual','retailers','wholesalers'),
phone varchar(10));
create table sales(sale_id int auto_increment primary key,
production_id int,customer_id int, sale_date date,quantity_kg decimal(10,2),
price_per_kg decimal(10,2),
foreign key(production_id) references production (production_id),
foreign key(customer_id) references customers (customer_id)); 

insert into farmers (farmer_name,farmer_village,phone) values
('ramraju','penagalur','789583950'),('venu','penaglur','9887646730'),
('gopinaidu','ramapuram','683743595'),('harinaidu','kambalkunta',997734574),
('krishnamraju','penagalur','9087545434');
insert into crops(crop_name,category) values
('Rice', 'Grain'),('Wheat', 'Grain'),('Tomato', 'Vegetable'),
('Potato', 'Vegetable'),('Mango', 'Fruit'),('Carrot','Vegetables');
insert into production(farmer_id,crop_id,harvest_date,quantity_kg,expiry_date) values
(2,1,'2019-04-02',600,null),(5,5,'2019-04-24',100,'2019-05-10'),
(3,4,'2019-05-06',20.50,'2019-05-26'),(2,3,'2019-04-07',60,'2019-04-29');

insert into customers(name,type,phone) values ('sita','individual',98537357),
('ramayya','wholesalers',84775395),('laxman','retailers',905848347),
('sita','retailers',887374558),('gopi','retailers',793857538);
                         
insert into sales(production_id,customer_id,sale_date,quantity_kg,price_per_kg) values
(1, 1, '2019-04-05', 200.00, 25.00), (1, 2, '2019-04-10', 150.00, 26.00),   
(2, 3, '2019-04-26', 50.00, 40.00), (3, 4, '2019-05-08', 10.00, 55.00),    
(3, 5, '2019-05-12', 5.50, 60.00),(4, 2, '2019-04-15', 30.00, 35.00);  


# 1 all crops from crop table
select * from crops;
# showing all farmers and their village(locations)
select farmer_name,farmer_village
from farmers;
-- Display all customers with their type.
select name,type
from customers;
-- Find all produce harvested after 2025-08-01.
select production_id,quantity_kg
from production 
where harvest_date > '2019-04-07';
-- Show crops that belong to the category Vegetable.
select crop_name,category
from crops
where category like '%vegetable%';
-- List all customers of type Retailer.
select name, type
from customers 
where lower(type) like '%retailer%';
-- show production  that has no expiry date (expiry_date IS NULL). 
select c.crop_name , p.expiry_date
from crops c
join production p
on p.production_id=c.crop_id
where p.expiry_date is null;
-- Find the farmer with farmer_id = 1.
select farmer_name
from farmers 
where farmer_id=1;
# INTERMEDIATE QUERIES
-- Find the total number of farmers in the database.
select count(*)as totall_farmers
from farmers;

-- How many farmers are there in each village? List each village along with the total number of farmers living there
select farmer_village, count(*) as totall_village_farmers
from farmers
group by farmer_village;
-- Count how many crops are in each category.
select category,count(*) as total_crop_category
from crops
group by category;
-- Get the total harvested quantity per crop.
select crop_id, sum(quantity_kg) as total_harvested_crop 
from production
group by crop_id;

select c.crop_name,sum(p.quantity_kg)as totall_harvest_kg
from production p 
join crops c 
on p.production_id=c.crop_id
group by c.crop_name;

-- Find the average price per kg of all sales.
select sale_id, avg(price_per_kg) as avgprice
from sales
group by sale_id;

select avg(price_per_kg) as avgprice
from sales;
-- Show all production  that is already expired (expiry_date < CURDATE()).
select *
from production 
where expiry_date <CURDATE();
-- List all sales made in the last 30 days.
select sale_id
from sales 
where sale_date < curdate()-interval 30 day;
-- Get the total sales revenue from each customer.
select customer_id,
sum(quantity_kg *price_per_kg) as totalrevenuepercustomer
from sales
group by customer_id;
-- Show the total quantity sold per crop.
select crop_id,
sum(quantity_kg) as totalpercrop
from production 
group by crop_id;

select production_id as crop_name, sum(quantity_kg ) as totalcropsold
from production 
group  by production_id;

# ADVANCED QUERIES
-- Find the top 3 most profitable crops (based on sales revenue)
select c.crop_name , sum( s.quantity_kg*s.price_per_kg) as totalrevenue
from sales s
join production p on s.production_id=p.production_id
join crops c on p.production_id=c.crop_id

group by c.crop_name
order by  totalrevenue desc
limit 3;
-- Find the farmer who sold the highest quantity of produce.
select f.farmer_name,max(s.quantity_kg)
from sales s
join production p on s.production_id=p.production_id
join farmers f on p.farmer_id=f.farmer_id
group by f.farmer_name;

-- Show the monthly sales revenue trend for 2025.
select 
	MONTH(sale_date) AS month, # extracts the month
    SUM(price_per_kg*quantity_kg) AS total_revenue
FROM sales
WHERE YEAR(sale_date) =2019 # filters only 2019 data 
GROUP BY MONTH(sale_date)
ORDER BY MONTH(sale_date);
-- Find all customers who purchased more than 500 kg in total
select s.customer_id
from sales s
join customers c 
on s.customer_id=c.customer_id
where s.quantity_kg > 100
group by s.customer_id
;
-- Get the average harvest quantity per farmer.
select c.crop_name,avg(p.quantity_kg) as avgharvest
from production p
join crops c
on p.crop_id=c.crop_id
group by c.crop_name;
-- Find the crop with the longest shelf life (expiry - harvest).
select c.crop_name,p.crop_id,
DATEDIFF(p.expiry_date,p.harvest_date) as shelf_life_days
from production p
join crops c 
on p.crop_id=c.crop_id
where p.expiry_date is not null
order by shelf_life_days desc
limit 1;
-- List all farmers who haven’t sold any produce yet.
select f.farmer_name , f.farmer_id
from farmers f
left join production p 
on f.farmer_id=p.production_id
left join sales s 
on p.production_id=s.production_id
where s.production_id is null;

select f.farmer_id,f.farmer_name
from farmers f
where not exists (
select 1
from production p
join sales s on p.production_id=s.production_id
where p.farmer_id=f.farmer_id
);
-- Find crops that are harvested but not yet sold.
select c.crop_name,p.production_id as not_sold
from production p
join crops c on p.production_id=c.crop_id
left join sales s on  p.production_id=s.production_id
where s.production_id is null;
# EXPERT QUERIES
-- Create a view that shows only available (non-expired) stock.
create view availablestock as
select * 
from production
where curdate() >= harvest_date

-- Write a stored procedure to generate a sales report for a given month and year.
delimiter $$

create procedure sales_report(IN p_month INT, IN p_year INT)
begin 
    select 
        sale_id,
        sale_date,
        quantity_kg,
        price_per_kg,
        (quantity_kg * price_per_kg) AS total_sales
    from sales
    where month(sale_date) = p_month
      and year(sale_date) = p_year;
end$$

delimiter ;

call sales_report(4,2019)
  



