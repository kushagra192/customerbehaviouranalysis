-- 1. Convert USD entries to INR in orders table
-- (1 USD = 82.5 INR approximately on entry day)
SELECT * FROM orders
WHERE currency = 'USD';

UPDATE orders
SET currency = 'INR',
    sales_amount = sales_amount * 82.5
WHERE currency = 'USD';

------------------------------------------------

-- 2. Normalize blank/placeholder ratings to NULL
UPDATE restaurant
SET rating = NULL
WHERE rating IS NULL OR rating IN ('--', '');

-- Convert rating column from TEXT to FLOAT
-- MySQL syntax: MODIFY COLUMN instead of ALTER COLUMN ... TYPE ... USING
ALTER TABLE restaurant
MODIFY COLUMN rating FLOAT;

-----------------------------------------------

-- 3. Convert price in menu table from VARCHAR to FLOAT

-- Step 1: Add a clean float column
ALTER TABLE menu ADD COLUMN price_clean FLOAT;

-- Step 2: Strip non-numeric characters and populate
-- MySQL REGEXP_REPLACE replaces all matches by default (no 'g' flag needed)
UPDATE menu
SET price_clean = CAST(REGEXP_REPLACE(price, '[^0-9.]', '') AS DECIMAL(10,2));

-- Step 3: Drop old column and rename new one
ALTER TABLE menu DROP COLUMN price;

-- RENAME COLUMN supported in MySQL 8.0+
ALTER TABLE menu RENAME COLUMN price_clean TO price;

-----------------------------------------------------------------------------

-- 4. Find and delete menu rows where r_id has no matching restaurant
SELECT *
FROM menu
WHERE r_id NOT IN (
    SELECT id FROM restaurant
);
-- 273 entries found

DELETE FROM menu
WHERE r_id NOT IN (
    SELECT id FROM restaurant
);

-------------------------------------------------------------

-- 5. Clean cost column in restaurant table (keep only numeric values)
UPDATE restaurant
SET cost = REGEXP_REPLACE(cost, '[^0-9.]', '');

-- Convert cost from VARCHAR to FLOAT
ALTER TABLE restaurant
MODIFY COLUMN cost FLOAT;

-----------------------------------------------------------

-- 6. Find NULL name entries in restaurant table
SELECT *
FROM restaurant
WHERE name IS NULL;
-- 86 entries found

-- Reconstruct name from link column
-- PostgreSQL SPLIT_PART → MySQL SUBSTRING_INDEX
-- PostgreSQL INITCAP → manual CONCAT + UPPER/LOWER per word in MySQL

UPDATE restaurant
SET name = CONCAT(
    -- Word 1
    UPPER(LEFT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 1)
    , 1)),
    LOWER(SUBSTRING(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 1)
    , 2)),
    ' ',
    -- Word 2
    UPPER(LEFT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 2), '-', -1)
    , 1)),
    LOWER(SUBSTRING(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 2), '-', -1)
    , 2)),
    ' ',
    -- Word 3
    UPPER(LEFT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 3), '-', -1)
    , 1)),
    LOWER(SUBSTRING(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 3), '-', -1)
    , 2)),
    ' ',
    -- Word 4
    UPPER(LEFT(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 4), '-', -1)
    , 1)),
    LOWER(SUBSTRING(
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(link, '/restaurants/', -1), '/', 1), '-', 4), '-', -1)
    , 2))
)
WHERE name IS NULL
  AND link IS NOT NULL;
