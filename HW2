-- Set up and testing all the tables / CSV files
use hw2;
select * from baristas;
select * from employs;
select * from offers;
select * from pastries;
select * from shops;
-- ========================

-- 1) Find the average price of pastries for each category from the pastries table
Select category, avg(price)
From pastries
Group by category;

-- 2) Find the total number of baristas at each experience level from the baristas table
Select experience_level, count(*) as "# baristas"
From baristas
Group by experience_level;

-- 3) Count the total number of shops located in each city from the shops table
Select city, count(*) as "# shops"
From shops
Group by city;

-- 4) Find the maximum price among pastries for each category from the pastries table 
Select category, max(price)
From pastries
group by category;

-- 5) Count how many pastries have been added by each shop using the shopID column from the offers table
Select shopID as “shop”, count(shopID) as "# pastries"
From offers
Group by shopID;

-- 6) Find the name, category, and price of any pastry whose price matches the maximum price within its category
select name, price, category
from pastries p
where price = 
	(select max(price)
    from pastries c
    where p.category = c.category);

-- 7) Find the unique shop IDs from the offers table that have offered at least one pastry whose price is strictly greater than the overall average price of all pastries
select shopID
from offers
where offers.pastryID =
    (Select pastries.pastryID
	From pastries
	where price >
		(select avg(price)
		From pastries));
        
-- 8) Find the shop ID and pastry ID for the records in the offers table that have the earliest date_added (minimum date) 
Select *
From offers
where date_added <= all
   (select date_added
   From offers);

-- 9) Find the shop ID(s) that offer the highest number of pastries, utilizing a subquery to evaluate the maximum count per shop 
Select shopID, count(shopID) as "# pastries"
From offers
Group by shopID
Having count(*) >=
   (select count(*)
   From offers
   Group by shopID);

-- 10) Find the names of baristas who work at shops located in 'Seattle' using nested subqueries
Select name
From baristas
Where baristas.shopID = 
   (Select employs.shopID
   From employs
   Where employs.shopID = 
      (Select shop.shopID
      From shops
      Where city = “Seattle”));
