USE `dataretrieval` ;


-- -----------------------------------------------------
-- ---------------------QUERY 1.------------------------
-- -----------------------------------------------------
-- Query is supposed to get full name of the customer, item name that have dates (timestamps) in range of minimum 2 years
-- Optimization was done by first making the plan and then rewriting the queries and testing them
-- Final verdict was that query number 1. was fastest meaning the query using JOIN with WHERE for defining the range of date
-- Query number 2. came in second place (JOIN with HAVING for defining the range of the timestamp)
-- In last place was just using WHERE to join the tables (since it needed many more searces it was much slower. It would slow down even more on bigger data)
-- -----------------------------------------------------

/* 1. */
SELECT c.first_name as 'First Name', c.last_name as 'Last Name', i.`name` as 'Item Name', i.units as 'Units', o.`date` 'Date of the Purchase'
FROM customer c
	INNER JOIN `order` o
	ON c.customer_taxpayer_id = o.customer_taxpayer_id
    INNER JOIN item i 
    ON o.order_id = i.order_id
    WHERE o.`date` > '2013-04-18 18:30:00' 
	AND o.`date` < '2018-04-20 18:30:00';
 
 /* 2. 
SELECT c.first_name as 'First Name', c.last_name as 'Last Name', i.`name` as 'Item Name', i.units as 'Units', o.`date` 'Date of the Purchase'
FROM customer c
	INNER JOIN `order` o
	ON c.customer_taxpayer_id = o.customer_taxpayer_id
	INNER JOIN item i 
    ON o.order_id = i.order_id
    HAVING o.`date` > '2013-04-18 18:30:00'
	AND o.`date` < '2018-04-20 18:30:00';
*/   

 /* 3.
SELECT c.first_name as 'First Name', c.last_name as 'Last Name', i.`name` as 'Item Name', i.units as 'Units', o.`date` 'Date of the Purchase'
FROM customer c, `order` o, item i 
	WHERE c.customer_taxpayer_id = o.customer_taxpayer_id 
		AND o.order_id = i.order_id 
        AND o.`date` > '2013-04-18 18:30:00' 
        AND o.`date` < '2018-04-20 18:30:00';
*/

-- -----------------------------------------------------
-- ------------------QUERY 1. EXPLAIN-------------------
-- -----------------------------------------------------
-- In the table order there is no key (index) and it needs to filter every row for the dates, which means that every row needs to be searched and matched
-- Hence out of 20 rows, all 20 needed to be read, also two indexes were taken into consideration
-- Tables customer and item both have keys (index) so only one search was needed
-- -----------------------------------------------------

EXPLAIN SELECT c.first_name as 'First Name', c.last_name as 'Last Name', i.`name` as 'Item Name', i.units as 'Units', o.`date` 'Date of the Purchase'
FROM customer c
	INNER JOIN `order` o
	ON c.customer_taxpayer_id = o.customer_taxpayer_id
    INNER JOIN item i 
    ON o.order_id = i.order_id
    WHERE o.`date` > '2013-04-18 18:30:00' 
	AND o.`date` < '2018-04-20 18:30:00';






-- -----------------------------------------------------
-- ---------------------QUERY 2.------------------------
-- -----------------------------------------------------
-- Query is supposed to get three best selling items (defined as most units sold)
-- There was only one attempt at the query since it is done on a single table, and just using group by
-- -----------------------------------------------------

/* 1. */
SELECT SUM(i.units) AS 'Numbers Sold', `name` AS 'Item' 
FROM item i
    GROUP BY i.`name` 
    ORDER BY SUM(i.units) DESC 
    LIMIT 3;



-- -----------------------------------------------------
-- ----------------QUERY 2. EXPLAIN---------------------
-- -----------------------------------------------------
-- Query is poorly optimized since it has no index (key is null), and it needed 28 rows which is very slow
-- Using temporary means that temporary table was created (happened because both group by and order by were used)
-- Using filesort means that it is not possible to preform sort from an index
-- -----------------------------------------------------

/* 1. */
EXPLAIN SELECT SUM(i.units) AS 'Numbers Sold', `name` AS 'Item' 
FROM item i
    GROUP BY i.`name` 
    ORDER BY SUM(i.units) DESC 
    LIMIT 3;




-- -----------------------------------------------------
-- ---------------------QUERY 3.------------------------
-- -----------------------------------------------------
-- Query is supposed to return a single row that takes in data from table order and calculates yearly and monthly averages
-- Only one iteration was done since there are no joins, because it is only one table
-- -----------------------------------------------------

/* 1. */
SELECT '1/2018 - 1/2020' AS PeriodOfSales, 
SUM(o.total_price) AS 'TotalSales (Euros)', 
ROUND(SUM(o.total_price)/2,2) AS YearlyAverage, 
ROUND(SUM(o.total_price)/24,2) AS MonthlyAverage 
FROM `order`  o
	WHERE o.`date`  < '2020-01-01 00:00:00' 
	AND o.`date`  > '2018-01-01 00:00:00';


-- -----------------------------------------------------
-- -----------------QUERY 3. EXPLAIN--------------------
-- -----------------------------------------------------
-- Table is again poorly optimized since it needed 20 searches (because it checks the dates once again with where)
-- and there is no index again
-- -----------------------------------------------------

/* 1. */
EXPLAIN SELECT '1/2018 - 1/2020' AS PeriodOfSales, 
SUM(o.total_price) AS 'TotalSales (Euros)', 
ROUND(SUM(o.total_price)/2,2) AS YearlyAverage, 
ROUND(SUM(o.total_price)/24,2) AS MonthlyAverage 
FROM `order`  o
	WHERE o.`date`  < '2020-01-01 00:00:00' 
	AND o.`date`  > '2018-01-01 00:00:00';

-- -----------------------------------------------------
-- -------------------QUERY 3. V2-----------------------
-- -----------------------------------------------------
-- This version doesn't devide flat out years and months like the previous one
-- It counts the number of days between the min and max date between the set interval, and then calculates the Yearly and Monthly Average
-- We weren't sure which version was wanted, so we kept both
-- -----------------------------------------------------

/* 2. 
SELECT CONCAT(MIN(o.`date`), ' - ', MAX(o.`date`)) AS PeriodOfSales, 
SUM((o.total_price)) AS 'TotalSales (Euros)', 
ROUND(SUM(o.total_price)/(datediff(max(o.`date`), min(o.`date`)))*365, 2) AS YearlyAverage,
ROUND(SUM(o.total_price)/(datediff(max(o.`date`), min(o.`date`)))*30, 2) AS MonthlyAverage
FROM `order` o
	WHERE o.`date`  < '2020-01-01 00:00:00' 
	AND o.`date`  > '2018-01-01 00:00:00';
*/



-- -----------------------------------------------------
-- ---------------------QUERY 4.------------------------
-- -----------------------------------------------------
-- Query is supposed to return the order total price for each of the cities
-- Same conclusion as with the queries before, JOINS outperforms WHERE in speed but you lose some readability since WHERE is much easier to understand
-- -----------------------------------------------------

/* 1. */
SELECT pc.city AS City, SUM(o.total_price) AS 'Total Sales (Euros)'
FROM `order` o
	LEFT OUTER JOIN restaurant r 
    ON r.restaurant_id = o.restaurant_id
    LEFT OUTER JOIN postal_code pc
    ON pc.postal_code_id = r.postal_code_id
	GROUP BY pc.city;
    
/*2
SELECT pc.city AS City, SUM(o.total_price) AS 'Total Price per City'
FROM `order` o, restaurant r, postal_code pc
	WHERE r.restaurant_id = o.restaurant_id
    AND pc. postal_code_id = r.postal_code_id
	GROUP BY pc.city;
*/

-- -----------------------------------------------------
-- -----------------QUERY 4. EXPLAIN--------------------
-- -----------------------------------------------------
-- Table order once again does not have an index, so it needed 20 searches again
-- This time there is only using temporary, which means that temporary table was created
-- Since there is no Using filesort that means that situation can be improved with the use of indexes
-- Table restaurant and postal_code have indexes (their primary keys)
-- -----------------------------------------------------

/* 1. */
EXPLAIN SELECT pc.city AS City, SUM(o.total_price) AS 'Total Sales (Euros)'
FROM `order` o
	LEFT OUTER JOIN restaurant r 
    ON r.restaurant_id = o.restaurant_id
    LEFT OUTER JOIN postal_code pc
    ON pc.postal_code_id = r.postal_code_id
	GROUP BY pc.city;


-- -----------------------------------------------------
-- ---------------------QUERY 5.------------------------
-- -----------------------------------------------------
-- Query is supposed to return a list of restaurants that have ratings (reviews) and their city, location and average rating per restaurant
-- Wierdly enough this time the best query ended up being the query using both DISTINCT and WHERE (only the case for small amounts of data, not nearly as good when dealing with huge amounts, also helped by the lack of indexes)
-- In second place was the query with DISTINCT and LEFT OUTER JOIN (becomes better then query 1. when data increases)
-- In third place was query with WHERE and GROUP BY (grouping by restaurant_id makes it so that only unique values are left)
-- -----------------------------------------------------

/* 1. */
SELECT DISTINCT r.restaurant_name AS Restaurant, pc.city AS City, r.street_address AS Location, ROUND(AVG(o.rating),2) as Rating
FROM restaurant r, `order` o, postal_code pc
	WHERE r.restaurant_id = o.restaurant_id 
    AND o.rating IS NOT NULL
    AND pc.postal_code_id = r.postal_code_id
    GROUP BY r.restaurant_name
    ORDER BY Rating DESC;

/* 2.
SELECT DISTINCT r.restaurant_name AS Restaurant, pc.city AS City, r.street_address AS Location, ROUND(AVG(o.rating),2) as Rating
FROM restaurant r
	LEFT OUTER JOIN `order` o
    ON r.restaurant_id = o.restaurant_id
    LEFT OUTER JOIN postal_code pc
    ON pc.postal_code_id = r.postal_code_id
	WHERE o.rating IS NOT NULL
    GROUP BY r.restaurant_name
    ORDER BY Rating DESC;

*/

/* 3.
SELECT r.restaurant_name AS Restaurant, pc.city AS City, r.street_address AS Location, ROUND(AVG(o.rating),2) as Rating
FROM restaurant r, `order` o, postal_code pc
	WHERE r.restaurant_id = o.restaurant_id 
    AND o.rating IS NOT NULL
    AND pc.postal_code_id = r.postal_code_id
    GROUP BY r.restaurant_id, r.restaurant_name
    ORDER BY Rating DESC;
*/


-- -----------------------------------------------------
-- -----------------QUERY 5. EXPLAIN--------------------
-- -----------------------------------------------------
-- From the get-go it can be seen that this query is just really poorly optimized
-- Not only does it use WHERE, it also uses both GROUP BY and ORDER BY, which means that order table cannot be improved with the indexes (Using filesort)
-- Since GROUP BY and ORDER BY were used, temporary table was once again created 
-- Tables restaurant and postal_code have indexes (on primary key) and they required only 1 search
-- -----------------------------------------------------

/* 1. */
EXPLAIN SELECT DISTINCT r.restaurant_name AS Restaurant, pc.city AS City, r.street_address AS Location, ROUND(AVG(o.rating),2) as Rating
FROM restaurant r, `order` o, postal_code pc
	WHERE r.restaurant_id = o.restaurant_id 
    AND o.rating IS NOT NULL
    AND pc.postal_code_id = r.postal_code_id
    GROUP BY r.restaurant_name
    ORDER BY Rating DESC;





    
    
    
 