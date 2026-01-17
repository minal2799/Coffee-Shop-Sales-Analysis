-- Month-to-Month Sales Growth Analysis (April vs May)
WITH monthly_sales AS (
    SELECT
        MONTH(transaction_date) AS month,
        ROUND(SUM(transaction_qty * unit_price), 1) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4, 5)
    GROUP BY MONTH(transaction_date)
)
SELECT
    month,
    total_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month))
        / LAG(total_sales) OVER (ORDER BY month) * 100,
        2
    ) AS mom_increase_percentage
FROM monthly_sales
ORDER BY month;

-- Total Orders by month

SELECT COUNT(transaction_id) AS total_orders
 FROM coffee_shop_sales
 WHERE MONTH(transaction_date) = 3

-- Total Sales by Month

SELECT ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5	

-- Month-to-Month Order Growth Analysis (April vs May)

WITH monthly_orders AS (
    SELECT
        MONTH(transaction_date) AS month,
        COUNT(transaction_id) AS total_orders
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4, 5)
    GROUP BY MONTH(transaction_date)
)
SELECT
    month,
    total_orders,
    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY month))
        / LAG(total_orders) OVER (ORDER BY month) * 100,
        2
    ) AS mom_increase_percentage
FROM monthly_orders
ORDER BY month;

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH

WITH monthly_qty_sold AS (
    SELECT 
        MONTH(transaction_date) AS month,
        SUM(transaction_qty) AS total_quantity_sold
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4, 5)
    GROUP BY MONTH(transaction_date)
)
SELECT
    month,
    total_quantity_sold,
    ROUND(
        (total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month))
        / LAG(total_quantity_sold) OVER (ORDER BY month) * 100,
        2
    ) AS mom_increase_percentage
FROM monthly_qty_sold
ORDER BY month;


-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT
SUM(unit_price * transaction_qty) AS total_sales,
SUM(transaction_qty) AS total_quantity_sold,
COUNT(transaction_id) AS total_orders

FROM coffee_shop_sales
WHERE
transaction_date = '2023-05-19'; -- --For 18 May 2023

SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023;



-- SALES TREND OVER PERIOD

SELECT AVG(total_sales)  AS average_sales 
FROM (
SELECT
  SUM(unit_price * transaction_qty) AS total_sales
FROM 
   coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5
GROUP BY
    transaction_date
    ) AS internal_query;
	
    
-- DAILY SALES FOR MONTH SELECTED

SELECT
DAY(transaction_date) AS day_of_month,
ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM
  coffee_shop_sales
WHERE 
 MONTH(transaction_date) = 1
GROUP BY (transaction_date)
ORDER BY (transaction_date);


-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT
  day_of_month,
CASE
 WHEN total_sales > avg_sales THEN 'Above Average'
 WHEN total_sales < avg_sales THEN 'Below Average'
 ELSE 'Average'
 END AS sales_status,
 total_sales
 
 FROM(
 SELECT
  DAY(transaction_date) AS day_of_month,
  SUM(unit_price * transaction_qty) AS total_sales,
  AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
  FROM
  coffee_shop_sales
  WHERE
  MONTH(transaction_date) = 5
  GROUP BY 
      DAY(transaction_date)
      ) AS sales_data
  ORDER BY
     day_of_month;

-- SALES BY WEEKDAY / WEEKEND:

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;


-- SALES BY STORE LOCATION

SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC
  

-- SALES BY PRODUCT CATEGORY

SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC

-- SALES BY PRODUCTS (TOP 10)

SELECT
      product_type,
      ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales
FROM coffee_shop_sales
WHERE
     MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY total_sales  DESC
LIMIT 10

-- SALES BY DAY | HOUR

SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY

SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);

