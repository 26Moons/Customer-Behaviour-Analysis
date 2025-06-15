/* How many customers have logged in more than once (returning customers) compared to those who logged in only once (one-time customers)? */

WITH customerLogins AS(
	SELECT
        Customer_id AS Customer,
        Count(*) AS NoOfLogins 
    FROM 
        Logins
    GROUP BY
        Customer_id         
)
SELECT Customer ,
        CASE
            WHEN NoOfLogins > 1 THEN 'Returning'
            ELSE 'One time'
        END AS STATUS
FROM customerLogins 
ORDER BY NoOfLogins ASC;

/*"How many days have passed since their last login?"*/

SELECT Last_Login,
        DATEDIFF(DAY,Last_Login,GETDATE()) AS days
FROM (
		SELECT 
			MAX(Login_date) AS Last_Login,
			Customer_id
		FROM 
			Logins
		GROUP BY
			Customer_id
) AS customerLastLoginDate;

/* "How well are we retaining customers over time?" (Monthly Retention (Cohort Table))
   "Out of the customers who joined in the cohort month, what percentage are active in the current month?"
   “For each group of customers who first logged in in a given month (a cohort), how many of them came back and logged in again in later months?”*/

WITH customerCohortMonth AS (
	SELECT MONTH(MIN(Login_date)) AS Cohort_month ,
		   Customer_id
	FROM   Logins
	GROUP BY Customer_id
),
customerActivityMonths AS (
	SELECT Month(Login_date) AS Activity_Month ,
		   Customer_id
	FROM Logins
),
cohortMonthSize AS(
	SELECT Cohort_month,
		   COUNT(DISTINCT Customer_id) AS Cohort_Size
	FROM customerCohortMonth
	GROUP BY Cohort_month 
)

SELECT c.Cohort_month ,
	   a.Activity_Month,
	   Count(DISTINCT a.Customer_id) AS total_activecustomers,
	   ROUND(Count(DISTINCT a.Customer_id)*100/cs.Cohort_Size,2) AS rtn_Pct
FROM customerCohortMonth AS c
JOIN customerActivityMonths AS a
ON c.Customer_id = a.Customer_id
JOIN cohortMonthSize AS cs
ON c.Cohort_month = cs.Cohort_month
GROUP BY c.Cohort_month ,
	   a.Activity_Month ,
	   cs.Cohort_Size
ORDER BY c.Cohort_month
	   