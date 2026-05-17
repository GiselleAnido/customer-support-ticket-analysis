DROP VIEW IF EXISTS clean_customer_tickets;

CREATE VIEW clean_customer_tickets AS
SELECT
    CASE
        WHEN "Customer Age" < 15 THEN '0-14'
        WHEN "Customer Age" BETWEEN 15 AND 25 THEN '15-25'
        WHEN "Customer Age" BETWEEN 26 AND 35 THEN '26-35'
        WHEN "Customer Age" BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    *
FROM customer_support_tickets
WHERE "Ticket ID" IS NOT NULL
AND "Customer Name" IS NOT NULL
AND "Customer Age" BETWEEN 0 AND 100
AND "Customer Gender" IN ('Male', 'Female', 'Other')
AND "Ticket Status" IN ('Open','Closed','Pending Customer Response')
AND "Customer Email" LIKE '%@%.%';

SELECT * FROM clean_customer_tickets;


-- DATA QUALITY CHECKS
-- =====================================

--Check for NULLs satisfaction rate
SELECT
    COUNT(*) AS missing_satisfaction
FROM clean_customer_tickets
WHERE "Customer Satisfaction Rating" IS NULL;


--Check for duplicate ticket IDs
SELECT
    "Ticket ID",
    COUNT(*) AS duplicates
FROM clean_customer_tickets
GROUP BY "Ticket ID"
HAVING COUNT(*) > 1
ORDER BY duplicates DESC;

--Check for invalid ages
SELECT *
FROM clean_customer_tickets
WHERE "Customer Age" < 0
OR "Customer Age" > 100;


SELECT COUNT(*) AS invalid_timestamp_rows
FROM clean_customer_tickets
WHERE "Time to Resolution" IS NOT NULL
AND "First Response Time" IS NOT NULL
AND julianday("Time to Resolution") < julianday("First Response Time");

-- =====================================
--2. Main KPI Metrics
-- =====================================

SELECT COUNT(*) AS total_tickets
FROM clean_customer_tickets;

-- Average ticket resolution time in hours
-- Excludes invalid data where resolution is earlier than first response
SELECT
  ROUND(AVG((julianday("Time to Resolution" ) - julianday("First Response Time")) * 24),2) AS avg_resolution_hours
FROM clean_customer_tickets
WHERE "Time to Resolution"  IS NOT NULL
  AND "first response time"  IS NOT NULL
  AND "Time to Resolution"  >= "first response time";

-- Average satisfaction raiting
SELECT ROUND(AVG("Customer Satisfaction Rating"),2) AS avg_satisfaction
FROM clean_customer_tickets
WHERE "Customer Satisfaction Rating" IS NOT  NULL;

--Cuurently open tickets
SELECT COUNT(*) AS total_open_tickets
FROM clean_customer_tickets
WHERE "Ticket Status" = 'Open';


--Open ticket percentage
SELECT
  ROUND(
    SUM(CASE WHEN "Ticket Status" = 'Open' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) AS open_ticket_percentage
FROM clean_customer_tickets;

-- Resolution rate
SELECT
    ROUND(
        SUM(CASE WHEN "Ticket Status" = 'Closed' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS resolution_rate
FROM clean_customer_tickets;


-- =====================================
--3. Ticket Distribution Analysis
-- =====================================

--Not very useful, incomplete data
SELECT "Ticket Type", 
COUNT(*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Ticket Type"
HAVING COUNT(*) > 2
ORDER BY total_tickets DESC;


SELECT "Ticket Status",
COUNT (*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Ticket Status"
HAVING COUNT(*) > 1
ORDER BY total_tickets DESC;

SELECT "Ticket Priority",
COUNT (*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Ticket Priority"
HAVING COUNT(*) > 1
ORDER BY total_tickets DESC;

SELECT "Ticket Subject",
COUNT (*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Ticket Subject"
HAVING COUNT(*) > 2
ORDER BY total_tickets DESC;

SELECT "Product Purchased",
COUNT (*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Product Purchased"
HAVING COUNT(*) > 7
ORDER BY total_tickets DESC;


SELECT "Ticket Channel" ,
COUNT (*) AS total_tickets
FROM clean_customer_tickets
GROUP BY "Ticket Channel"
HAVING COUNT(*) >1
ORDER BY total_tickets DESC;



-- =====================================
--4. Customer Demographic Analysis
-- =====================================




SELECT "Customer Gender",
COUNT (*) AS total_tickets
FROM clean_customer_tickets
WHERE "Customer Gender" IN ('Male', 'Female', 'Other')
GROUP BY "Customer Gender"
ORDER BY total_tickets DESC;

--Tickets per age group
SELECT 
    age_group,
    COUNT(*) AS total_tickets
FROM clean_customer_tickets
GROUP BY age_group
ORDER BY total_tickets DESC;


--Channel usage by age group
SELECT 
    age_group,
    "Ticket Channel",
    COUNT(*) AS total_tickets
FROM clean_customer_tickets
GROUP BY
    age_group,
    "Ticket Channel"
ORDER BY
    age_group,
    total_tickets DESC;

--Satisfaction by age group 
SELECT age_group,
ROUND(AVG ("Customer Satisfaction Rating"),2) AS avg_rate
FROM clean_customer_tickets
GROUP BY age_group ;

--Satisfaction by gender
SELECT "Customer Gender",
ROUND(AVG ("Customer Satisfaction Rating"),2) AS avg_rate
FROM clean_customer_tickets
WHERE "Customer Gender" IN ('Male', 'Female', 'Other')
GROUP BY "Customer Gender"
ORDER BY avg_rate DESC;

-- =====================================
-- 6. Operational Performance Analysis
-- =====================================


-- =====================================
-- 6. Operational Performance Analysis
-- =====================================
--The dataset does not contain ticket creation timestamps, therefore certain time-series operational analyses cannot be reliably performed.


SELECT
    "Ticket Priority",
    ROUND(
        AVG(
            (julianday("Time to Resolution") - julianday("First Response Time")) * 24
        ),
        2
    ) AS avg_resolution_hours
FROM clean_customer_tickets
WHERE "Time to Resolution" IS NOT NULL
AND "First Response Time" IS NOT NULL
AND "Time to Resolution" >= "First Response Time"
GROUP BY "Ticket Priority"
ORDER BY avg_resolution_hours DESC;





