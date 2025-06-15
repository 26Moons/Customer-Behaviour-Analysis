# Customer-Behaviour-Analysis
Case Study :


Question 1 : "How many customers have logged in more than once (returning customers) compared to those who logged in only once (one-time customers)?"
Solution : Approach : (Go to Logins Table - find no of logins for each customer - count the no of logins if more than 1 then returning else one time)
           SQL Query : Step 1 - write a CTE to find no of logins
                       Step 2 - count the no of logins , if > 1 then returning else one time

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

Question 2 : "How many days have passed since their last login?"
Solution : Approach : (Go to logins table - find last login for each customer - find difference between today date and the last login date of each customer)
           SQL Query : Step 1 - write a subquery to find last login date of each customer by using MAX()
                       Step 2 - now select customer id and last date , find difference of last date and current date to find days , from this subquery

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

Question 3 : "How well are we retaining customers over time?" (Monthly Retention (Cohort Table))
             "Out of the customers who joined in the cohort month, what percentage are active in the current month?"
Solution : Approach : find the cohort month (i.e first login month) for each customer 
                    - find all the activity months for each customer
                    - now u have to find all distinct customers who have joined in a particular cohort month and were active in this particular activity month (customer may have logged                         in more than one time in the same month so we need distinct)
                    - caculate the retention percentage.
           SQL Query : Step 1 - write a CTE to find cohort month (i.e first login month) for each customer
                       Step 2 - write a CTE to find all the activity months for each customer
                       Step 3 - write a CTE to find the cohort size from the 1st CTE
                       Step 3 - now join these 3 CTEs on the basis of customer id so that for every customer , we have their cohort and all activity months and cohort month so 
                                we can get the cohort size
                       Step 4 - group the data by cohort and activity month , find no of unique customers for the same 
                       Step 5 - find retention percentage by COUNT(DISTINCT a.Customer_id) * 100 / cs.Cohort_size

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

Question 4 -            

            

          
