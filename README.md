# NovaCare Hospital: Capacity & Surge Command Center

## 🏥 Clinical Context & Problem
This project simulates a high-stakes audit for **NovaCare Hospital**, an integrated health system facing operational gridlock. Despite stable admission volumes, the facility reported "chronic stiffness," ambulance diversions, and nurse burnout.

### The Initial Complaint:
* **The 6:00 AM Melt-down:** Persistent backlogs during shift transitions.
* **The Pediatric Paradox:** Overcrowded pediatric wards despite stable pediatric volume.
* **The Sunday Surge:** A recurring "weekend effect" stalling Monday operations.

## 🛠️ Technical Solution
I acted as the Lead Healthcare Data Analyst for **Team 4**, moving through three phases of clinical intelligence:

1. **Metric Definition:** Established 10 core KPIs including Average Length of Stay (4.03 days) and Discharge Integrity (71.2%).
2. **SQL Investigation:** Leveraged PostgreSQL to join `patients`, `admissions`, and `diagnoses` tables to identify hidden bottlenecks.
3. **Visualization:** Built a Power BI Command Center to translate raw EHR data into actionable executive insights.

## 🔍 Key Findings & Bottlenecks
* **The Sunday Surge:** Admission volume peaks every Sunday at **737 admissions**, testing capacity limits.
* **Ward Misalignment:** A critical structural mismatch where the Pediatric Ward has an average patient age of **46.10 years**.
* **Boarding Crisis:** **714 adults** are currently "boarding" in pediatric beds, primarily for chronic conditions like UTI and Diabetes.
* **Discharge Stasis:** **252 seniors** are medically stable but awaiting Rehab placement, effectively "clutching" acute care beds.

## 💡 Strategic Recommendations
* **Bed Leveling:** Reallocate 15-20% of Pediatric bed capacity to a dedicated "Adult Overflow" unit.
* **Surge Staffing:** Implement a 15% staffing increase on Sundays and Mondays to absorb the 737-patient peak.
* **Rehab Fast-Track:** Initiate insurance pre-authorization for post-acute care on Day 2 of admission.

## 📂 Project Structure
* `/01_Business_Context`: Initial leadership complaints and problem synthesis.
* `/02_SQL_Queries`: PostgreSQL scripts for clinical data extraction.
* `/03_Dashboard`: Power BI (.pbix) files and dashboard screenshots.
* `/04_Presentation`: Final 30-slide executive dossier.

---
**Author:** Ayandokun Shadrach – MBBS Student & CS Undergraduate | Health Informatics Aspirant.
