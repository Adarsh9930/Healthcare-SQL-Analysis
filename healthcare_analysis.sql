SELECT * FROM adarsh.healthcare;

-- Task 1:
-- Find the top 5 most common medical conditions along with their patient count.

select Medical_Condition, count(*) Counts from healthcare group by 1 order by 1 desc limit 5 ;

-- Task 2:
-- List all patients who stayed in the hospital more than 10 days and had a billing amount above 50000.

SELECT PersonName, Hospital, DATEDIFF(Discharge_Date, Date_of_Admission) AS Days, Billing_Amount
FROM healthcare 
WHERE DATEDIFF(Discharge_Date, Date_of_Admission) > 10 
AND Billing_Amount > 50000;


-- LEVEL 2 – Date Functions & CASE Statements
-- 🔹 Task 3:
-- Find the month with the highest number of admissions.

select month(Date_of_Admission) HighestNoOfAdmission, count(*) Counts
from healthcare group by month(Date_of_Admission);

-- Task 4:
-- Add a column categorizing patients based on billing:

Select PersonName, sum(Billing_Amount) TotalBilling,
Case
	when sum(Billing_Amount) >= 100000 then 'High'
	when sum(Billing_Amount) between 50000 and 99999 then 'Mediam'
    else 'Low'
    End as PatientsCategory
from healthcare group by PersonName order by TotalBilling desc ;

-- LEVEL 3 – Window Functions
-- 🔹 Task 5:
-- For each hospital, rank patients by billing amount (highest first). Show only the top 2 per hospital.

select * from (
select PersonName, Hospital, sum(Billing_Amount) BillingAmounts, 
row_number() over( partition by Hospital order by sum(Billing_Amount) desc ) Ranked
from healthcare group by PersonName, Hospital) as RR
where Ranked <=2;

-- Task 6:
-- Use LAG() to find patients whose billing amount increased compared to the previous patient (by admission date) in the same hospital.
SELECT PersonName, Hospital, Billing_Amount,
       LAG(Billing_Amount) OVER (PARTITION BY Hospital ORDER BY Date_of_Admission) AS PreviousBilling
FROM healthcare
WHERE Billing_Amount > LAG(Billing_Amount) OVER (PARTITION BY Hospital ORDER BY Date_of_Admission);

-- LEVEL 4 – CTE + Advanced
-- 🔹 Task 7:
-- Use a CTE to find the average length of stay per hospital, and then filter only hospitals where the average stay is more than 7 days.

WITH StayPerHospital AS (
  SELECT 
    Hospital,
    AVG(Length_of_Stay) AS AverageStay
  FROM healthcare
  GROUP BY Hospital
)
SELECT *
FROM StayPerHospital
WHERE AverageStay > 7;

-- Task 8:
-- Create a CTE to classify each doctor’s patients by test result count:
-- Excellent (All patients have "Positive" results)
-- Needs Review (More than 30% have "Negative")

WITH DoctorStats AS (
  SELECT Doctor,
         COUNT(*) AS TotalPatients,
         SUM(CASE WHEN Test_Results = 'Negative' THEN 1 ELSE 0 END) AS NegativePatients
  FROM healthcare
  GROUP BY Doctor
)
SELECT *,
       CASE 
         WHEN NegativePatients = 0 THEN 'Excellent'
         WHEN (NegativePatients / TotalPatients) > 0.3 THEN 'Needs Review'
         ELSE 'Satisfactory'
       END AS Classification
FROM DoctorStats;
