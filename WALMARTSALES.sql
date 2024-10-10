CREATE database IF NOT EXISTS WALMARTSALESDATA ;

CREATE TABLE IF NOT exists SALES (
	INVOICE_ID VARCHAR (30)  NOT NULL PRIMARY KEY,
    BRANCH VARCHAR(5) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    CUSTOMER_TYPE VARCHAR (30),
    GENDER VARCHAR(10) NOT NULL,
    PRODUCT_LINE VARCHAR(100) NOT NULL,
    UNIT_PRICE DECIMAL(10,2) NOT NULL,
    QUANTITY INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,TOTAL DECIMAL(12,4)NOT NULL,
    DATE DATETIME NOT NULL,
    TIME TIME NOT NULL,
    PAYMENMT_METHOD VARCHAR (15) NOT NULL,
    COGS DECIMAL(10,2) NOT NULL,
    GROSS_MARGIN_PERCENT FLOAT(11,9),
    GROSS_INCOME DECIMAL (12,4) NOT NULL,
    RATING FLOAT (2,1) 
    
);


SELECT * FROM walmartsalesdata.SALES;


-- --------------------------sales analysis------------------------------------------------
#1. data wraling 
#2.feature engnineering 
#3. exploratory data analysis

-- feature engnineering ---
-- 1. TIME OF DATE
-- 2. DAY_NAME
-- 3. MONTH_NAME

# -- DAY OF TIME 
SELECT TIME ,
	(CASE 
			WHEN `TIME` BETWEEN '00;00;00' AND '12;00;00' THEN 'MORNING'
			WHEN `TIME` BETWEEN '12;01;00' AND '16;00;00' THEN 'AFTERNOON'
			ELSE 'EVENING'
	END) AS TIME_OF_DATE
FROM SALES ;

ALTER TABLE SALES ADD COLUMN TIME_OF_DAY VARCHAR(20);

UPDATE SALES 
SET TIME_OF_DAY = (
    CASE 
        WHEN `TIME` BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN `TIME` BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END);

-- -- DAY_NAME----

SELECT DATE,
DAYNAME(DATE)
FROM SALES ;

alter TABLE  SALES ADD COLUMN DAY_NAME VARCHAR(12);

UPDATE SALES  SET DAY_NAME = DAYNAME(DATE);

--  ----MONTH_NAME---

SELECT DATE , monthname(DATE)
FROM SALES;
ALTER TABLE SALES ADD COLUMN MONTH_NAME VARCHAR (12) ;
UPDATE SALES SET MONTH_NAME = MONTHNAME(DATE);


-- ------------------BUSINESS QUESTION ------------------------------------
#Generic Question
-- 1.	How many unique cities does the data have?
-- 2.	In which city is each branch?

SELECT distinct(CITY)
FROM SALES ;

SELECT DISTINCT (BRANCH) 
FROM SALES ;

SELECT distinct(CITY) ,BRANCH
FROM SALES ;

-- PRODUCT QUESTION -----------
#1.	How many unique product lines does the data have?

SELECT COUNT(DISTINCT PRODUCT_LINE) 
FROM SALES;

ALTER TABLE SALES 
RENAME COLUMN PAYMENMT_METHOD TO PAYMENT_METHOD;

#2.	What is the most common payment method?
DESCRIBE SALES;

SELECT PAYMENT_METHOD
FROM SALES ;
 
SELECT PAYMENT_METHOD , COUNT(PAYMENT_METHOD) AS CNT
FROM SALES
GROUP BY PAYMENT_METHOD
ORDER BY CNT DESC;
 
SELECT PAYMENT_METHOD, COUNT(*) AS method_count
FROM SALES
GROUP BY PAYMENT_METHOD
ORDER BY method_count DESC
LIMIT 1;

#3.	What is the most selling product line?

SELECT PRODUCT_LINE , COUNT(PRODUCT_LINE) AS PRODUCT_COUNT
FROM SALES 
GROUP BY PRODUCT_LINE 
ORDER BY PRODUCT_COUNT DESC  
LIMIT 1;

#4.	What is the total revenue by month?

SELECT MONTH_NAME AS MONTHS , 
SUM(TOTAL) AS TOTAL_RENVENUE
FROM SALES
GROUP BY MONTHS
ORDER BY TOTAL_RENVENUE DESC;

#5.	What month had the largest COGS?

SELECT MONTH_NAME AS MONTHS,
SUM(COGS) AS CG
FROM SALES 
GROUP BY MONTHS 
ORDER BY CG DESC
LIMIT 1;

#6.	What product line had the largest revenue?

SELECT PRODUCT_LINE , SUM(TOTAL) AS REVENUE 
FROM SALES 
GROUP BY PRODUCT_LINE 
ORDER BY REVENUE DESC ;

#7.	What is the city with the largest revenue?

SELECT CITY , SUM(TOTAL) AS REVENUE_TOTAL
FROM SALES 
GROUP BY CITY 
ORDER BY REVENUE_TOTAL DESC
LIMIT 1;

#8.	WHICH product line had the largest VAT? WHICH
SELECT PRODUCT_LINE , SUM(VAT) AS TOTAL_VAT
FROM SALES 
GROUP BY PRODUCT_LINE 
ORDER BY TOTAL_VAT DESC;

SELECT PRODUCT_LINE , AVG(VAT) AS AVG_VAT 
FROM SALES 
GROUP BY PRODUCT_LINE 
ORDER BY AVG_VAT DESC;

#9.	Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT AVG(TOTAL)
FROM SALES ;

SELECT PRODUCT_LINE ,
(CASE 
		WHEN TOTAL >(SELECT  AVG(TOTAL) FROM SALES) THEN 'GOOD'                              
		ELSE 'BAD'
END) AS SALES_PERFM
FROM SALES ;

alter table sales 
add column SALES_PERFM varchar(6) ;

UPDATE SALES 
SET SALES_PERFM = (CASE 
		WHEN TOTAL > (SELECT  AVG(TOTAL) FROM SALES) THEN 'GOOD'        # WILL UPADTE IT CAN'T eference the same table you're updating inside a subquery                    
		ELSE 'BAD'
END);


SET @AVG_TOTAL = (SELECT AVG(TOTAL) FROM SALES ); -- PUT IN  THE VARIABLE 
 
UPDATE SALES 
SET SALES_PERFM =( CASE 
WHEN TOTAL >  @AVG_TOTAL THEN 'GOOD'
ELSE 'BAD'
END);

#10.	Which branch sold more products than average product sold?

SELECT (AVG(QUANTITY)) 
FROM SALES;
SELECT SUM(QUANTITY) FROM SALES; 

SELECT   DISTINCT BRANCH,QUANTITY AS QNT 
FROM SALES
WHERE QUANTITY > (SELECT AVG(QUANTITY ) FROM SALES);


SELECT BRANCH, 
       SUM(QUANTITY) AS total_quantity
FROM SALES
GROUP BY BRANCH
HAVING SUM(QUANTITY) > (SELECT AVG(total_quantity) 
                        FROM (SELECT SUM(QUANTITY) AS total_quantity 
                              FROM SALES 
                              GROUP BY BRANCH) AS branch_totals);
                              
# 11.	What is the most common product line by gender?                  

SELECT DISTINCT GENDER , (PRODUCT_LINE) , COUNT(GENDER) AS GEN_COUNT
FROM SALES 
GROUP BY GENDER, PRODUCT_LINE
ORDER BY GEN_COUNT DESC;

#12.	What is the average rating of each product line?

SELECT PRODUCT_LINE , AVG(RATING) AS AVG_RATE
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY AVG_RATE DESC;


-- -----------------------------------SALES ANALYSISI---------------------------------------------------

#  1.	Number of sales made in each time of the day per weekday

SELECT TIME_OF_DAY,
COUNT(*) AS TOTAL_SALES
FROM SALES
GROUP BY TIME_OF_DAY;


#.	Which of the customer types brings the most revenue?

SELECT DISTINCT(CUSTOMER_TYPE), SUM(TOTAL) AS REVENUE
FROM SALES 
GROUP BY CUSTOMER_TYPE
ORDER BY REVENUE DESC;


#	Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT CITY , AVG(VAT) AS VAT 
FROM SALES 
GROUP BY CITY
order by VAT DESC;

SELECT CITY,
		SUM(VAT) AS TOTAL_VAT,
		SUM(TOTAL) AS TOTAL_REVENUE,
		(SUM(VAT)/ SUM(TOTAL)) * 100 AS VAT_PERC
FROM SALES
GROUP BY CITY
ORDER BY VAT_PERC;
	

#.	Which customer type pays the most in VAT?

SELECT 
CUSTOMER_TYPE, AVG(VAT) AS VAT
FROM SALES 
GROUP BY CUSTOMER_TYPE
ORDER BY VAT DESC;

-- ----------------------------------CUSTOMER ANALYSIS----------------

	#	1.	How many unique customer types does the data have?
    
SELECT DISTINCT ( CUSTOMER_TYPE) 
FROM SALES ;
    
	#	2.	How many unique payment methods does the data have?
    
SELECT DISTINCT( Payment_method)
from sales;
    
    
	#	3.	What is the most common customer type?
    
SELECT CUSTOMER_TYPE , COUNT(CUSTOMER_TYPE)
FROM SALES
GROUP BY CUSTOMER_TYPE;
    
	#	4.	Which customer type buys the most?
    
SELECT CUSTOMER_TYPE , COUNT(*) AS BUY
FROM SALES 
group by CUSTOMER_TYPE
ORDER BY BUY DESC;

    
#	5.	What is the gender of most of the customers?

SELECT GENDER , COUNT(GENDER)
FROM SALES 
GROUP BY GENDER ;

#	6.	What is the gender distribution per branch?
SELECT BRANCH , GENDER , COUNT(*)
FROM SALES 
WHERE BRANCH ='B'
GROUP BY GENDER
ORDER BY COUNT(GENDER) ASC;

SELECT BRANCH , GENDER , COUNT(*)
FROM SALES 
GROUP BY GENDER , BRANCH
ORDER BY COUNT(GENDER) ASC;

#	7.	Which time of the day do customers give most ratings?
SELECT TIME_OF_DAY , COUNT(RATING) AS RATE
FROM SALES
GROUP BY TIME_OF_DAY
LIMIT 1 ;

#	8.	Which time of the day do customers give most ratings per branch?
SELECT  BRANCH ,TIME_OF_DAY ,COUNT(RATING) 
FROM SALES 
GROUP BY TIME_OF_DAY, BRANCH
ORDER BY COUNT(RATING) DESC;

#	9.	Which day fo the week has the best avg ratings?
SELECT DAY_NAME , ROUND(AVG(RATING),1) AS RATE
FROM SALES 
GROUP BY DAY_NAME
ORDER BY RATE DESC;
#	10.	Which day of the week has the best average ratings per branch?
SELECT BRANCH, DAY_NAME , ROUND(AVG(RATING),1) AS RATING
FROM SALES
GROUP BY BRANCH, DAY_NAME
ORDER BY BRANCH ASC;
