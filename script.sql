-- creating the database
DROP DATABASE IF EXISTS SQL_Retail_Analysis_db;
create database SQL_Retail_Analysis_db;

-- creating a table inside the database onto which to load data into 
USE  SQL_Retail_Analysis_db;

CREATE TABLE retail (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
    sale_time TIME,
    customer_id	INT,
    gender	VARCHAR(10),
    age	INT,
    category VARCHAR(40),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
    );
    
show variables like 'secure_file_priv'; -- to check the directory in which MySQL is allowed to read/write files 
 
 -- loading data inside the table filling in empty strings as null 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Retail_Sales_Analysis_cleaned.csv'
INTO TABLE retail
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@transactions_id,@sale_date,@sale_time,@customer_id,@gender,@age,@category,@quantity,@price_per_unit,@cogs,@total_sale)
SET
transactions_id=nullif(@transactions_id,''),	
sale_date=nullif(@sale_date,''),	
sale_time=nullif(@sale_time,''),	
customer_id=nullif(@customer_id,''),	
gender=nullif(@gender,''),	
age=nullif(@age,''),
category=nullif(@category,''),	
quantity=nullif(@quantity,''),	
price_per_unit=nullif(@price_per_unit,''),
cogs=nullif(@cogs,''),	
total_sale=nullif(@total_sale,'');

-- now solving business problems 

-- Q1) Find the total number of sales made 
SELECT
	COUNT(*) as total_sales
FROM retail;

-- Q2) How many customers does the business have 
SELECT
	COUNT(DISTINCT customer_id) as total_no_of_customers
FROM retail;

-- Q2) which sales were made on '2023-12-14'
SELECT*FROM retail
WHERE sale_date='2023-12-14';

-- Q3) which sales from the clothing category have quantity > 3 for the month of DEC-2022
SELECT*FROM RETAIL
WHERE category='clothing'
AND quantity>3
AND DATE_FORMAT(sale_date,'%Y-%m')='2022-12';

-- Q4) calculate the total sales for each category 
SELECT
	category,
    COUNT(transactions_id) as total_no_of_sales,
    SUM(total_sale) as total_sales
FROM retail
GROUP BY category;

-- Q5)What is the average age of customers who purchased items from the 'Beauty' category
SELECT
	category,
	ROUND(AVG(age)) as average_age
FROM retail
WHERE category='Beauty';

-- Q6) Find the transactions where total sale >1000
SELECT*FROM retail
WHERE total_sale>1000;

-- Q7) What is the total number of transactions made by each gender in each category 
SELECT
    category,
    gender,
    COUNT(transactions_id) as total_transactions
FROM retail
GROUP BY gender,category
ORDER BY category;

-- Q8) What is the average sale for each month, which is the best selling month each year
	
WITH ranked as
 (
    select
		MONTH(sale_date) as month,
		YEAR(sale_date) as year,
		ROUND(AVG(total_sale),2) as avg_sales,
        RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY(AVG(total_sale)) DESC) as ranking
	from retail
	GROUP BY 1,2
    ) 
SELECT* FROM ranked
WHERE ranking=1;

-- Q9) find the top 7 customers based on total sales
SELECT
	customer_id,
    SUM(total_sale) total_sales
FROM retail
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 7;

-- Q10)Find the number distinct customers in each category
SELECT
	COUNT(DISTINCT(customer_id)) total_customers,
    category 
FROM retail
GROUP BY category;

-- Q12) What is the number of orders in each shift(Morning<=12,Afternoon=between 12 and 17 and Evening=>17)
SELECT
	COUNT(transactions_id) as total_orders,
    shifts
FROM
(
	SELECT*,
		CASE
			WHEN HOUR(sale_time) < 12  THEN 'Morning'
			WHEN HOUR(sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shifts
	FROM retail
) temp
GROUP BY shifts;

