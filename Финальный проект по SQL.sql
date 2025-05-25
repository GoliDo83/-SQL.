CREATE DATABASE Customers_transactions;
UPDATE customers SET Gender = NULL WHERE Gender = '';
UPDATE customers SET Age = NULL WHERE Age = '';
ALTER TABLE Customers MODIFY Age INT NULL;

select * from customers;


CREATE TABLE Transactions (
    date_new date,  
    Id_check INT,
    ID_client INT,
    Count_products DECIMAL(10,3),
    Sum_payment DECIMAL(10,2)
);

DROP TABLE IF EXISTS Transactions_temp;

CREATE TABLE Transactions_temp (
    date_new DATE,
    Id_check BIGINT,
    ID_client INT,
    Count_products FLOAT,
    Sum_payment FLOAT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/TRANSACTIONS.csv"
INTO TABLE Transactions_temp
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

select * from transactions_info;

INSERT INTO transactions_info (date_new, Id_check, ID_client, Count_products, Sum_payment)
SELECT date_new, Id_check, ID_client, Count_products, Sum_payment
FROM Transactions_temp;

UPDATE transactions_info
SET
    year = YEAR(date_new),
    month = MONTH(date_new),
    quarter = QUARTER(date_new)
WHERE date_new IS NOT NULL
LIMIT 50000;

select * from transactions_temp;

CREATE TABLE customers (
    ID_client INT PRIMARY KEY,
    Total_amount FLOAT,
    Gender VARCHAR(2),
    Age INT,
    Count_city INT,
    Response_communcation INT,
    Communication_3month INT,
    Tenure INT
);

CREATE TABLE transactions_info (
    date_new DATE,
    Id_check BIGINT,
    ID_client INT,
    Count_products FLOAT,
    Sum_payment FLOAT
);

SHOW COLUMNS FROM transactions_info;


UPDATE transactions_info
SET
    year = YEAR(date_new),
    month = MONTH(date_new),
    quarter = QUARTER(date_new)
WHERE date_new IS NOT NULL;
    
SELECT COUNT(*) FROM transactions_info;

UPDATE customers
SET age_group = CASE
    WHEN Age IS NULL THEN 'NA'
    WHEN Age < 20 THEN '0-19'
    WHEN Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN Age BETWEEN 40 AND 49 THEN '40-49'
    WHEN Age BETWEEN 50 AND 59 THEN '50-59'
    WHEN Age BETWEEN 60 AND 69 THEN '60-69'
    ELSE '70+'
END;
   
SELECT age_group, COUNT(*) FROM customers GROUP BY age_group;
    
    
SELECT ID_client
FROM (
    SELECT ID_client, COUNT(DISTINCT CONCAT(year, '-', month)) AS months_active
    FROM transactions_info
    GROUP BY ID_client
) AS t
WHERE months_active = 12
LIMIT 0, 2000;

SELECT 
    ID_client,
    COUNT(*) AS total_operations,
    AVG(Sum_payment) AS avg_check,
    SUM(Sum_payment) / COUNT(DISTINCT year || '-' || month) AS avg_monthly_spend
FROM transactions_info
GROUP BY ID_client;

SELECT 
    year,
    month,
    COUNT(DISTINCT ID_client) AS active_clients,
    COUNT(*) AS total_operations,
    AVG(Sum_payment) AS avg_check
FROM transactions_info
GROUP BY year, month
ORDER BY year, month;

SELECT 
    Gender,
    COUNT(DISTINCT c.ID_client) AS client_count,
    SUM(t.Sum_payment) AS total_spent,
    AVG(t.Sum_payment) AS avg_check
FROM customers c
LEFT JOIN transactions_info t ON c.ID_client = t.ID_client
GROUP BY Gender;

SELECT 
    c.age_group,
    t.year,
    t.quarter,
    COUNT(*) AS total_transactions,
    SUM(t.Sum_payment) AS total_spent,
    AVG(t.Sum_payment) AS avg_check
FROM transactions_info t
JOIN customers c ON c.ID_client = t.ID_client
GROUP BY c.age_group, t.year, t.quarter
ORDER BY t.year, t.quarter, c.age_group
LIMIT 0, 2000;