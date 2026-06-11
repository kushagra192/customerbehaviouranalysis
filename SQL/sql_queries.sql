-- 1. Top 10 Restaurants by Total Sales Amount

SELECT r.name, SUM(o.sales_amount) AS total_sales
FROM orders o
JOIN restaurant r ON o.r_id = r.id
GROUP BY r.name
ORDER BY total_sales DESC
LIMIT 10;

-----------------------------------------------------------------

-- 2. Average Rating and Rating Count by Top 20 City
-- PostgreSQL TO_CHAR / DATE_TRUNC → MySQL DATE_FORMAT

SELECT 
    city,
    AVG(rating) AS avg_rating,
    AVG(
        CASE 
            WHEN rating_count = 'Too Few Ratings' THEN 10
            WHEN rating_count = '20+ ratings'     THEN 25
            WHEN rating_count = '50+ ratings'     THEN 55
            WHEN rating_count = '100+ ratings'    THEN 110
            ELSE NULL
        END
    ) AS avg_rating_count_est
FROM restaurant
WHERE rating IS NOT NULL
GROUP BY city
ORDER BY avg_rating DESC
LIMIT 20;

-----------------------------------------------------------------

-- 3. Monthly Order Trends
-- PostgreSQL DATE_TRUNC + TO_CHAR → MySQL DATE_FORMAT
-- PostgreSQL TO_DATE for ordering  → MySQL STR_TO_DATE

SELECT month, total_orders
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%b') AS month,
        DATE_FORMAT(order_date, '%Y-%m-01') AS month_sort,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%b'), DATE_FORMAT(order_date, '%Y-%m-01')
) AS sub
ORDER BY month_sort;

-----------------------------------------------------------------

-- 4. Top 5 Most Popular Cuisines by Order Volume
-- COUNT(o.*) → COUNT(*) in MySQL

SELECT m.cuisine, COUNT(*) AS order_count
FROM orders o
JOIN menu m ON o.r_id = m.r_id
GROUP BY m.cuisine
ORDER BY order_count DESC
LIMIT 5;

-----------------------------------------------------------------

-- 5. Distribution of Vegetarian vs Non-Vegetarian Items Ordered

SELECT f.veg_or_non_veg, COUNT(*) AS item_count
FROM orders o
JOIN menu m ON o.r_id = m.r_id AND o.sales_qty > 0
JOIN food f ON m.f_id = f.f_id
GROUP BY f.veg_or_non_veg
LIMIT 2;

-----------------------------------------------------------------

-- 6. Top 20 Cities by Number of Restaurants

SELECT city, COUNT(*) AS restaurant_count
FROM restaurant
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 20;

-----------------------------------------------------------------

-- 7. User Demographics by Average Order Value

SELECT u.Occupation, AVG(o.sales_amount) AS avg_order_value
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.Occupation
ORDER BY avg_order_value DESC;

-----------------------------------------------------------------

-- 8. High-Spending Users (Top 15)
-- PostgreSQL PERCENTILE_CONT not available in MySQL
-- Equivalent using ROW_NUMBER + COUNT window functions (MySQL 8.0+)

WITH user_spending AS (
    SELECT user_id, SUM(sales_amount) AS total_spent
    FROM orders
    GROUP BY user_id
),
ranked AS (
    SELECT 
        user_id,
        total_spent,
        ROW_NUMBER() OVER (ORDER BY total_spent) AS rn,
        COUNT(*) OVER ()                          AS total_count
    FROM user_spending
)
SELECT user_id, total_spent
FROM ranked
WHERE rn > FLOOR(0.99 * total_count)
ORDER BY total_spent DESC
LIMIT 15;

-----------------------------------------------------------------

-- 9. Top 15 Average Menu Price by Cuisine

SELECT cuisine, AVG(price) AS avg_price
FROM menu
GROUP BY cuisine
ORDER BY avg_price DESC
LIMIT 15;

-----------------------------------------------------------------

-- 10. Restaurants Offering the Most Diverse Menu

SELECT r.name, COUNT(DISTINCT m.f_id) AS item_count
FROM restaurant r
JOIN menu m ON r.id = m.r_id
GROUP BY r.name
ORDER BY item_count DESC
LIMIT 10;

-----------------------------------------------------------------

-- 11. Most Ordered Food Items

SELECT f.item, SUM(o.sales_qty) AS total_quantity
FROM orders o
JOIN menu m ON o.r_id = m.r_id
JOIN food f ON m.f_id = f.f_id
GROUP BY f.item
ORDER BY total_quantity DESC
LIMIT 30;

-----------------------------------------------------------------

-- 12. Gender-wise Spending Behavior

SELECT u.Gender, AVG(o.sales_amount) AS avg_spending
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.Gender;

-----------------------------------------------------------------

-- 13. Peak Ordering Days
-- PostgreSQL TO_CHAR(order_date, 'Day') → MySQL DAYNAME()
-- PostgreSQL EXTRACT(DOW ...)           → MySQL DAYOFWEEK() (1=Sun, 7=Sat)

SELECT 
    DAYNAME(order_date)    AS weekday,
    DAYOFWEEK(order_date)  AS weekday_num,
    COUNT(*)               AS total_orders,
    SUM(sales_amount)      AS total_sales
FROM orders
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY weekday_num;

-----------------------------------------------------------------

-- 14. Income Group vs Order Frequency

SELECT 
    u.Monthly_Income, 
    COUNT(*) AS order_count
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.Monthly_Income
ORDER BY order_count DESC;
