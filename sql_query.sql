-- Data Cleaning--------------------------------
SELECT * FROM coffee_shop_sales.coffeeshop_sales;
-- UPDATE DATE FORMAT------------------------------------
UPDATE coffeeshop_sales
SET transaction_date = str_to_date(transaction_date, '%d-%m-%Y')
-------------------------------------------------
ALTER TABLE coffeeshop_sales
MODIFY COLUMN transaction_date DATE;

--- CROSS-CHECK THE DATA TYPE--------------------
DESCRIBE coffeeshop_sales

----CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
UPDATE coffeeshop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

---ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER TABLE coffeeshop_sales
MODIFY COLUMN transaction_time TIME;

--- CROSS-CHECK THE DATA TYPE--------------------
DESCRIBE coffeeshop_sales

--CHANGE COLUMN NAME `ï»¿transaction_id` to transaction_id
ALTER TABLE coffeeshop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT

--CROSS-CHECK THE COLUMN NAME--------------------
SELECT * FROM coffeeshop_sales
DESCRIBE coffeeshop_sales

--TOTAL SALES-------------------------------------
SELECT SUM(unit_price * transaction_qty) AS Total_sales
FROM coffeeshop_sales
--Output: 698812.32

--RETRIEVE MONTHLY WISE TOTAL SALES
SELECT SUM(unit_price * transaction_qty) AS Total_sales
FROM coffeeshop_sales
WHERE 
MONTH(transaction_date) = 5  --5 means May month
--Output: '156727.7600000045'

----TOTAL SALES-"3" means March month
SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM coffeeshop_sales
WHERE 
MONTH(transaction_date) = 3 
--Output: '98834'

---- CONCAT "k"
SELECT CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000, "K") AS Total_sales
FROM coffeeshop_sales
WHERE 
MONTH(transaction_date) = 3 
--Output: '98.835K'

--TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH--PM-Previous Month/CM-Current Month
SELECT 
    MONTH(transaction_date) AS month, --No. of Months
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, --Total sales Column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) --Month Sales Difference 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- Divided by PM Sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage --Percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) --for month of April(PM) and May(CM)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    --Output: '4', '118941',  NULL
         '5', '156728', '31.769242384551315'

--TOTAL ORDERS
SELECT COUNT(transaction_id) as Total_Orders
FROM coffeeshop_sales 
WHERE MONTH (transaction_date)= 3 -- March Month
--Output: '21229'

SELECT COUNT(transaction_id) as Total_Orders
FROM coffeeshop_sales 
WHERE MONTH (transaction_date)= 5 -- for month of (CM-May)
--Output: '33527'

--TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
--Output: '4', '25335', NULL
'5', '33527', '32.3347'

-- TOTAL QUANTITY SOLD
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffeeshop_sales 
WHERE MONTH(transaction_date) = 5 -- for month of (CM-May)
--Output:'48233'

SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffeeshop_sales 
WHERE MONTH(transaction_date) = 6 -- for month of (CM-June)
--Output:'50942'

--TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
--Output: '4', '36469', NULL
'5', '48233', '32.2575'

--CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_quantity_sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_orders
FROM 
    coffeeshop_sales
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023
--OUTPUT: '5.6K', '1.7K', '1.2K'

--27th MARCH
SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_quantity_sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_orders
FROM 
    coffeeshop_sales
WHERE 
    transaction_date = '2023-03-27'; --For 27THMay 2023
--OUTPUT: '3.7K', '1.2K', '0.8K'

-- CHECK WEEKDAYS AND WEEKENDS SALES
-- Weekdays = Mon to Fri
-- Weekends = Sat to Sun
-- Sun= 1
-- Mon = 2
-
.
.
-- Sat = 7

-- We will create a new table, the will feed our sales value and then we will get our out    
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_sales 
FROM 
    coffeeshop_sales 
WHERE 
    MONTH(transaction_date) = 5 -- MAY MONTH
GROUP BY   
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END 
LIMIT 0, 1000;
-- Output: 'Weekdays', '116.6K'
'Weekends', '40.1K'

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_sales 
FROM 
    coffeeshop_sales 
WHERE 
    MONTH(transaction_date) = 2 -- FEB MONTH
GROUP BY   
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END 
LIMIT 0, 1000;
-- Output: 'Weekdays', '54K'
'Weekends', '22.1K'

-- SALES BY STORE LOCATION 
SELECT
     store_location,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_Sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5 -- MAY MONTH
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC
--OUTPUT: 'Hell\'s Kitchen', '52.6K'
'Astoria', '52.4K'
'Lower Manhattan', '51.7K'

SELECT
     store_location,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_Sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 6 -- JUNE MONTH
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC
--OUTPUT: 'Hell\'s Kitchen', '57K'
'Astoria', '55.1K'
'Lower Manhattan', '54.4K'

-- SALES TREND OVER PERIOD
SELECT 
    CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_sales
FROM
    (
    SELECT SUM(unit_price * transaction_qty) AS total_sales
    FROM coffeeshop_sales
    WHERE MONTH(transaction_date) = 5 -- MAY MONTH
    GROUP BY transaction_date
    ) AS Internal_query;
-- OUTPUT: '5.1K'

SELECT 
    CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_sales
FROM
    (
    SELECT SUM(unit_price * transaction_qty) AS total_sales
    FROM coffeeshop_sales
    WHERE MONTH(transaction_date) = 4 -- APRIL MONTH
    GROUP BY transaction_date
    ) AS Internal_query;
-- OUTPUT: '4K'

-- DAILY SALES FOR MONTH SELECTED
SELECT
     DAY(transaction_date) AS day_of_month,
     SUM(unit_price * transaction_qty) AS total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);
-- OUTPUT:'1', '4731.449999999999'
'2', '4625.499999999997'
'3', '4714.599999999994'
'4', '4589.699999999995'
'5', '4700.999999999997'

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffeeshop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
-- OUTPUT:'1', 'Below Average', '4731.449999999999'
'2', 'Below Average', '4625.499999999997'
'3', 'Below Average', '4714.599999999994'
'4', 'Below Average', '4589.699999999995'
'5', 'Below Average', '4700.999999999997'

-- SALES BY PRODUCT CATEGORY 
SELECT
     product_category,
     SUM(unit_price * transaction_qty) AS total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC
-- OUTPUT: 'Coffee', '60362.84999999928'
'Tea', '44539.84999999951'
'Bakery', '18565.519999999997'
'Drinking Chocolate', '16319.75'
'Coffee beans', '8768.949999999997'

-- TOP 10 PRODUCT TYPE BY SALES
SELECT
     product_type,
     SUM(unit_price * transaction_qty) AS total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;
-- OUTPUT: 'Barista Espresso', '20423.749999999993'
'Brewed Chai tea', '17427.350000000082'
'Hot chocolate', '16319.75'
'Gourmet brewed coffee', '15559.200000000008'
'Brewed herbal tea', '10930'
'Brewed Black tea', '10778'
'Premium brewed coffee', '8739.199999999973'
'Organic brewed coffee', '8350.199999999939'
'Scone', '8305.27999999999'
'Drip coffee', '7290.5'

-- TOP 10 COFFEE PRODUCT CATEGORY BY SALES
SELECT
     product_type,
     SUM(unit_price * transaction_qty) AS total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;
-- OUTPUT: 'Barista Espresso', '20423.749999999993'
'Gourmet brewed coffee', '15559.200000000008'
'Premium brewed coffee', '8739.199999999973'
'Organic brewed coffee', '8350.199999999939'
'Drip coffee', '7290.5'

-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffeeshop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
-- OUTPUT: '2969', '874', '612'

-- SALES BY HOUR
SELECT 
      HOUR(transaction_time),
      SUM(unit_price * transaction_qty) AS Total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time)
-- OUTPUT: '6', '4912.930000000001'
'7', '14350.680000000037'
'8', '18822.31000000003'
'9', '19145.270000000022'
'10', '19639.13000000001'

-- SALES BY DAY -- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
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
    coffeeshop_sales
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
-- OUTPUT: 'Monday', '25221'
'Tuesday', '25347'
'Wednesday', '25465'
'Thursday', '20254'
'Friday', '20341'
'Saturday', '20795'
'Sunday', '19305'


--- ----------------------------









         

