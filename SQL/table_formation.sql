-- Drop tables if they exist (order matters due to foreign keys)
DROP TABLE IF EXISTS orders, menu, food, restaurant, users;

-- 1. food
CREATE TABLE food (
    unnamed INT,
    f_id VARCHAR(20) PRIMARY KEY,
    item VARCHAR(255),
    veg_or_non_veg VARCHAR(20)
);

-- 2. restaurant
CREATE TABLE restaurant (
    unnamed INT,
    id INT PRIMARY KEY,
    name VARCHAR(255),
    city VARCHAR(100),
    rating TEXT,                     -- Will be converted to FLOAT after data loading
    rating_count VARCHAR(50),
    cost VARCHAR(50),                -- Will be converted to FLOAT after data loading
    cuisine VARCHAR(255),
    lic_no VARCHAR(100),
    link TEXT,
    address TEXT,
    menu TEXT
);

-- 3. users
CREATE TABLE users (
    unnamed INT,
    user_id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    Age INT,
    Gender VARCHAR(20),
    Marital_Status VARCHAR(30),
    Occupation VARCHAR(100),
    Monthly_Income VARCHAR(50),
    Educational_Qualifications VARCHAR(100),
    Family_size INT
);

-- 4. menu
CREATE TABLE menu (
    unnamed INT,
    menu_id VARCHAR(50),
    r_id INT,
    f_id VARCHAR(20),
    cuisine VARCHAR(100),
    price VARCHAR(50),               -- Will be converted to FLOAT after data loading
    PRIMARY KEY (unnamed, menu_id)
);

-- 5. orders
CREATE TABLE orders (
    unnamed INT,
    order_date DATE,
    sales_qty INT,
    sales_amount FLOAT,
    currency VARCHAR(10),
    user_id INT,
    r_id INT
);
