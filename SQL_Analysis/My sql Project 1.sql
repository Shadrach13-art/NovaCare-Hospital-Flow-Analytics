ALTER TABLE "admissions.csv" 
ADD COLUMN "admission_id" INT;

ALTER TABLE "admissions.csv"
ADD COLUMN "patient_id" INT,
ADD COLUMN "admission_datetime" TIMESTAMP,
ADD COLUMN "discharge_datetime" TIMESTAMP,
ADD COLUMN "admission_type" VARCHAR(50),
ADD COLUMN "department" VARCHAR(100),
ADD COLUMN "discharge_disposition" VARCHAR(100);


SELECT * FROM "admissions.csv";


ALTER TABLE "diagnoses.csv"
ADD COLUMN "diagnosis_id" INT,
ADD COLUMN "admission_id" INT,
ADD COLUMN "icd10_code" VARCHAR(10);

select * from diagnose

select * from "admissions_csv"


----Question 1 How many patients are admitted to the hospital each day?
Select admission_datetime::DATE AS admission_day,
	   Count(admission_id) As total_admissions
FROM "admissions.csv"
GROUP BY admission_day
ORDER BY admission_day;

---or
SELECT DATE(admission_datetime),  
       COUNT(*) AS Patients_admitted 
 FROM "admissions.csv"
 GROUP BY DATE(admission_datetime)
 ORDER BY DATE(admission_datetime);

 ----QUESTION 2 What is the overall average length of stay (LOS) for admitted patients?
 select * from "admissions.csv"
 SELECT 
   ROUND(AVG(EXTRACT(EPOCH FROM (discharge_datetime - admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv";

--- QUESTION 3 How does average length of stay vary by department?
SELECT
   department,
   ROUND(AVG(EXTRACT(EPOCH FROM (discharge_datetime - admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv"
GROUP BY department
ORDER BY avg_los_days
--- query 4  age of patient in Pediatrics
SELECT
      MIN(p.age) AS youngest_patient,
	  MAX(p.age) AS oldest_patient,
	  ROUND(AVG(P.age),1) as averge_age
FROM "patient.csv" p
Join "admissions.csv" a on p.patient_id=a.patient_id
WHERE a.department = 'Pediatrics'
----- Reedited / refirmed co=lumn
SELECT 
    CASE 
        -- Rule 1: Anyone 17 or under is ALWAYS Pediatrics
        WHEN p.age <= 17 THEN 'True Pediatrics (0-17)'
        
        -- Rule 2: If an adult (18+) was labeled 'Pediatrics', 
        -- we re-label them based on their medical need (like 'Medicine' or 'General')
        WHEN p.age >=18 AND a.department = 'Pediatrics' THEN 'Adult in Ped Ward'
        
        -- Rule 3: Everyone else stays in their original department
        ELSE a.department 
    END AS clean_department,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400)::numeric, 2) AS avg_los
FROM "admissions.csv" a
JOIN "patient.csv" p ON a.patient_id = p.patient_id
GROUP BY 1
ORDER BY avg_los DESC;

--QUESTION 4   How are admissions distributed by admission type?
SELECT 
      admission_type,
	  COUNT(admission_id) AS total_admissions,
	  ROUND(COUNT(admission_id) * 100.0 / SUM(COUNT(admission_id)) OVER(), 2)
FROM "admissions.csv"
GROUP BY admission_type
ORDER BY total_admissions DESC;
----A better view in percentage 
SELECT 
    admission_type,
    COUNT(admission_id) AS total_admissions,
    ROUND(COUNT(admission_id) * 100.0 / SUM(COUNT(admission_id)) OVER(), 2) AS percentage
FROM "admissions.csv"
GROUP BY admission_type
ORDER BY total_admissions DESC;


---QUESTION 5 Which admission type is associated with the longest average length of stay?

SELECT
      admission_type,
	  ROUND(AVG(EXTRACT(EPOCH FROM (discharge_datetime - admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv"
GROUP BY admission_type
ORDER BY avg_los_days DESC
LIMIT 1
----To get the full picture
SELECT
      admission_type,
	  ROUND(AVG(EXTRACT(EPOCH FROM (discharge_datetime - admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv"
GROUP BY admission_type
ORDER BY avg_los_days DESC


---
SELECT 
    a.admission_type,
    CASE 
        WHEN d.icd10_code = 'A09' THEN 'Stomach Flu'
        WHEN d.icd10_code = 'E11' THEN 'Type 2 Diabetes'
        WHEN d.icd10_code = 'N39' THEN 'UTI'
        WHEN d.icd10_code = 'I10' THEN 'Hypertension'
        WHEN d.icd10_code = 'O80' THEN 'Normal Delivery'
        WHEN d.icd10_code = 'J18' THEN 'Pneumonia'
        WHEN d.icd10_code = 'K35' THEN 'Acute Appendicitis'
        ELSE d.icd10_code 
    END AS diagnosis_name,
    COUNT(a.admission_id) AS patient_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv" a
JOIN "diagnoses.csv" d ON a.admission_id = d.admission_id
GROUP BY a.admission_type, diagnosis_name
ORDER BY avg_los_days DESC, a.admission_type ASC;


----Question 6 How do discharge dispositions break down across all admissions?
SELECT 
      discharge_disposition,
	  COUNT(admission_id) AS patient_count,
	  ROUND(COUNT(admission_id) * 100.0 / SUM(COUNT(admission_id)) OVER(), 2) AS percentage
FROM "admissions.csv"
GROUP BY discharge_disposition
ORDER BY patient_count DESC;

-----QUESTION 7 Do certain discharge dispositions correspond to longer hospital stays?
SELECT
   discharge_disposition,
   ROUND(AVG(EXTRACT(EPOCH FROM (discharge_datetime - admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
FROM "admissions.csv"
GROUP BY discharge_disposition
ORDER BY avg_los_days

---QUESTION 8 At what hours of the day do most admissions occur?
SELECT
      EXTRACT( HOUR FROM admission_datetime) AS admission_hour,
	  Count(admission_id) AS total_admissions,
	  ROUND(COUNT(admission_id) * 100.0 / SUM(COUNT(admission_id)) OVER(), 2) AS percentage
FROM "admissions.csv"
GROUP BY admission_hour
ORDER BY percentage DESC;


--QUESTION 9 Are there specific days of the week with consistently higher admissions?
SELECT 
    EXTRACT(DOW FROM admission_datetime) AS day_of_week,
    CASE 
        WHEN EXTRACT(DOW FROM admission_datetime) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM admission_datetime) = 6 THEN 'Saturday'
    END AS day_name,
    COUNT(admission_id) AS total_admissions
FROM "admissions.csv"
GROUP BY day_of_week, day_name
ORDER BY day_of_week;

---QUESTION 10  Which departments experience the highest admission volume?
SELECT 
    CASE 
        /* 1. First, catch all children regardless of where they were admitted */
        WHEN p.age < 18 THEN 'True Pediatrics'
        
        /* 2. Then, catch adults specifically in the Pediatric ward */
        WHEN a.department = 'Pediatrics' AND p.age >= 18 THEN 'Adults in Pediatrics'
        
        /* 3. Everyone else stays in their respective adult departments */
        ELSE a.department 
    END AS final_department_mapping,
    COUNT(a.admission_id) AS total_admissions,
    ROUND(COUNT(a.admission_id) * 100.0 / SUM(COUNT(a.admission_id)) OVER(), 2) AS percentage_of_total
FROM "admissions.csv" AS a
JOIN "patient.csv" AS p ON a.patient_id = p.patient_id
GROUP BY final_department_mapping
ORDER BY total_admissions DESC;


--- further analysis base on the c\adult in pred ward with
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM a.admission_datetime) = 6 THEN 'Saturday'
    END AS day_name,
    CASE 
        WHEN d.icd10_code LIKE 'N39%' THEN 'Urinary Tract Infection (UTI)'
        WHEN d.icd10_code LIKE 'E11%' THEN 'Type 2 Diabetes'
        ELSE 'Other Adult Diagnosis'
    END AS diagnosis_label,
    COUNT(a.admission_id) AS patient_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400)::numeric, 2) AS avg_los
FROM "admissions.csv" AS a
JOIN "patient.csv" AS p ON a.patient_id = p.patient_id
JOIN "diagnoses.csv" AS d ON a.admission_id = d.admission_id
WHERE 
    a.department = 'Pediatrics' 
    AND p.age >= 18 
    AND (d.icd10_code LIKE 'N39%' OR d.icd10_code LIKE 'E11%')
GROUP BY day_name, diagnosis_label
ORDER BY day_name DESC, patient_count DESC;

---
SELECT 
    CASE 
        WHEN p.age BETWEEN 18 AND 44 THEN '18-44 (Young Adult)'
        WHEN p.age BETWEEN 45 AND 64 THEN '45-64 (Middle Adult)'
        ELSE '65+ (Senior)' 
    END AS age_group,
    CASE 
        WHEN a.department = 'Pediatrics' THEN 'Boarded in Pediatrics'
        ELSE 'Placed in Proper Adult Ward'
    END AS placement_status,
    -- Total count of ALL adults in that specific placement
    COUNT(a.admission_id) AS total_adults_in_placement,
    -- Count of those who specifically expired
    SUM(CASE WHEN a.discharge_disposition = 'Expired' THEN 1 ELSE 0 END) AS death_count,
    -- Average days until death (only for the expired group)
    ROUND(AVG(CASE 
        WHEN a.discharge_disposition = 'Expired' 
        THEN (EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400) 
    END)::numeric, 2) AS avg_days_to_expiry,
    -- Mortality Rate for that specific placement
    ROUND((SUM(CASE WHEN a.discharge_disposition = 'Expired' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.admission_id)), 2) AS mortality_rate_pct
FROM "admissions.csv" AS a
JOIN "patient.csv" AS p ON a.patient_id = p.patient_id
WHERE p.age >= 18 
GROUP BY age_group, placement_status
ORDER BY age_group, avg_days_to_expiry;


----QUESTION 11 How does patient age relate to length of stay?
SELECT
     CASE 
	 WHEN p.age < 18 THEN '0-17(pediatrics)'
	 WHEN p.age BETWEEN 18 AND 44 THEN '18-44 (Young Adult)'
	 WHEN p.age BETWEEN 45 AND 64 THEN '45-64 (Middle Adult)'
	 ELSE '65+(Senior)'
END AS age_group,
COUNT (a.admission_id) AS total_patients,
 ROUND(AVG(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400)::numeric, 2) AS avg_los_days
 FROM "admissions.csv" AS a
JOIN "patient.csv" p ON a.patient_id= p.patient_id 
GROUP BY  age_group
ORDER BY avg_los_days DESC;

---QUESTION 12  Are older patients more likely to be discharged to rehab or skilled nursing?
SELECT 
    CASE 
        WHEN p.age BETWEEN 18 AND 44 THEN '18-44 (Young Adult)'
	 WHEN p.age BETWEEN 45 AND 64 THEN '45-64 (Middle Adult)'
	 ELSE '65+(Senior)'
    END AS age_group,
    a.discharge_disposition,
    COUNT(*) AS patient_count
FROM "admissions.csv" a
JOIN "patient.csv" p ON a.patient_id = p.patient_id
WHERE a.discharge_disposition IN ('Rehab', 'Skilled Nursing')
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


---The Age-Placement Inefficiency Gap

--- QUESTION 13 Which diagnoses are most commonly associated with hospital admissions?
SELECT 
    CASE 
        WHEN d.icd10_code = 'A09' THEN 'Stomach Flu (Infectious Gastroenteritis)'
        WHEN d.icd10_code = 'E11' THEN 'Type 2 Diabetes'
        WHEN d.icd10_code = 'N39' THEN 'UTI (Urinary Tract Infection)'
        WHEN d.icd10_code = 'I10' THEN 'High Blood Pressure (Hypertension)'
        WHEN d.icd10_code = 'O80' THEN 'Normal Delivery (Childbirth)'
        WHEN d.icd10_code = 'J18' THEN 'Pneumonia'
        WHEN d.icd10_code = 'K35' THEN 'Acute Appendicitis'
        ELSE d.icd10_code 
    END AS diagnosis_name,
    COUNT(*) AS total_cases
FROM "diagnoses.csv" d
JOIN "admissions.csv" a ON d.admission_id = a.admission_id
JOIN "patient.csv" p ON a.patient_id = p.patient_id
WHERE p.age >= 18
GROUP BY 1
ORDER BY total_cases DESC;

--- QUESTION 14 Do certain diagnoses result in longer average hospital stays?
SELECT 
    CASE 
        WHEN d.icd10_code = 'N39' THEN 'Urinary Tract Infection (UTI)'
        WHEN d.icd10_code = 'E11' THEN 'Type 2 Diabetes'
        WHEN d.icd10_code = 'A09' THEN 'Stomach Flu (Infectious Gastroenteritis)'
        WHEN d.icd10_code = 'K35' THEN 'Acute Appendicitis'
        WHEN d.icd10_code = 'O80' THEN 'Normal Delivery (Childbirth)'
        WHEN d.icd10_code = 'J18' THEN 'Pneumonia'
        WHEN d.icd10_code = 'I10' THEN 'High Blood Pressure (Hypertension)'
        ELSE d.icd10_code 
    END AS diagnosis_name,
    COUNT(*) AS patient_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime)) / 86400)::numeric, 2) AS avg_los
FROM "admissions.csv" a
JOIN "diagnoses.csv" d ON a.admission_id = d.admission_id
JOIN "patient.csv" p ON a.patient_id = p.patient_id
WHERE p.age >= 18
GROUP BY 1
ORDER BY avg_los DESC;