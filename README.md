# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Database**: `SQL_Retail_Analysis_db`

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Import empty strings as null in MySQL Workbench.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `SQL_Retail_Analysis_db`.
```sql
DROP DATABASE IF EXISTS SQL_Retail_Analysis_db;
create database SQL_Retail_Analysis_db;
```

- **Table Creation**: A table named `retail` is created to store the sales data. The table structure includes columns(transaction ID, sale date, sale time, customer id, gender, age,  category, quantity , price per unit,  cogs, total sale)

```sql
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
```
### 2. Data Importation
**Load Data Infile**

```sql
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
```

### 2. Data Exploration 

- **Record Count**: Determine the total number of records in the dataset.
 ```sql
SELECT COUNT(*) FROM retail_sales;
```

- **Customer Count**: Find out how many unique customers are in the dataset.
```sql
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
```

- **Category Count**: Identify all unique product categories in the dataset.
```sql
    SELECT DISTINCT category FROM retail_sales;
```

- **Checking Null**: Find out the nulls in the dataset

```sql
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **which sales were made on '2023-12-14'**:
```sql
SELECT *
SELECT*FROM retail
WHERE sale_date='2023-12-14';
```

2. **which sales from the clothing category have quantity > 3 for the month of DEC-2022**:
```sql
SELECT*FROM RETAIL
WHERE category='clothing'
AND quantity>3
AND DATE_FORMAT(sale_date,'%Y-%m')='2022-12';
```

3. **calculate the total sales for each category **:
```sql
SELECT
	category,
    COUNT(transactions_id) as total_no_of_sales,
    SUM(total_sale) as total_sales
FROM retail
GROUP BY category;
```

4. **What is the average age of customers who purchased items from the 'Beauty' category**:
```sql
SELECT
	category,
	ROUND(AVG(age)) as average_age
FROM retail
WHERE category='Beauty';
```

5. **Find the transactions where total sale >1000**:
```sql
SELECT*FROM retail
WHERE total_sale>1000;
```

6. **What is the total number of transactions made by each gender in each category**:
```sql
SELECT
    category,
    gender,
    COUNT(transactions_id) as total_transactions
FROM retail
GROUP BY gender,category
ORDER BY category;
```

7. **What is the average sale for each month, which is the best selling month each year**:
```sql
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
```

8. **find the top 7 customers based on total sales**:
```sql
SELECT
	customer_id,
    SUM(total_sale) total_sales
FROM retail
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 7;
```

9. **Find the number distinct customers in each category**:
```sql
SELECT
	COUNT(DISTINCT(customer_id)) total_customers,
    category 
FROM retail
GROUP BY category;
```

10. **What is the number of orders in each shift(Morning<=12,Afternoon=between 12 and 17 and Evening=>17)**:
```sql
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
GROUP BY shifts
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing, Electronics and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Conclusion

This project serves as an introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


## Author - Gabriel Ian Muli Mwema

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. 
