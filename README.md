# 📊 Data Analyst Job Market Analysis (SQL)
 
## The Problems I Set Out to Solve
 
When I started job hunting for data analyst roles, I realized I was navigating the market blind — I didn't actually know which skills were worth prioritizing, which jobs paid the most, or whether remote roles were even competitive on salary. So I decided to stop guessing and let the data answer these questions for me using SQL:
 
1. **What are the top-paying data analyst jobs?**
2. **What skills are required for these top-paying jobs?**
3. **What skills are most in demand for data analysts?**
4. **Which skills are associated with higher salaries?**
5. **What are the most optimal skills to learn** (high demand *and* high pay)?
This repo is my SQL-driven answer to all five.
 
---
 
## 🗂️ About the Data
 
The dataset comes from real-world job postings and includes job titles, salaries, locations, and the specific skills tied to each posting. It gave me everything I needed to dig into the data analyst job market with actual numbers instead of assumptions.
 
## 🛠️ Tools I Used
 
| Tool | Why I Used It |
|---|---|
| **SQL** | The core of the analysis — writing the actual queries |
| **PostgreSQL** | Database engine for storing and querying the job posting data |
| **VS Code** | Writing and running my SQL scripts |
| **Git & GitHub** | Version control and sharing my work |
 
---
 
## 🔍 The Analysis
 
Each question got its own SQL query. Here's how I approached each one, and what I found.
 
### 1️⃣ Top-Paying Data Analyst Jobs
 
I filtered for `Data Analyst` roles marked as remote (`Anywhere`) with a non-null average yearly salary, then sorted by salary.
 
```sql
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```
 
**What I found:**
 
| Metric | Value |
|---|---|
| Highest salary in top 10 | $650,000 |
| Lowest salary in top 10 | $184,000 |
| Number of unique companies represented | 10 |
| Example companies | SmartAsset, Meta, AT&T |
| Job title range | Data Analyst → Director of Analytics |


  ![Top Paying Roles](assets\1_top_10_highest_paying_jobs.png)
 
- Salaries in the top 10 range from **$184,000 to $650,000** — a massive spread.
- Companies like **SmartAsset, Meta, and AT&T** show up, proving demand spans multiple industries.
- Titles vary widely — from **Data Analyst** to **Director of Analytics** — showing how broad this career path can be.
> 💡 Add the full 10-row output (job title, company, salary) here once you export it from your own query run — it'll make this section even easier to scan.
 
---
 
### 2️⃣ Skills for Top-Paying Jobs
 
Using a CTE to pull the top 10 highest-paying roles, I joined them against the skills tables to see what those jobs actually asked for.
 
```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
 
SELECT
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```
 
**What I found:**
 
| Skill | Frequency in Top 10 Jobs |
|---|---|
| SQL | 8 |
| Python | 7 |
| Tableau | 6 |
| R | Lower frequency |
| Snowflake | Lower frequency |
| Pandas | Lower frequency |
| Excel | Lower frequency |
 
- **SQL** appeared 8 times across the top 10 highest-paying jobs.
- **Python** wasn't far behind, appearing 7 times.
- **Tableau** showed up 6 times, with R, Snowflake, Pandas, and Excel trailing behind.
---
 
### 3️⃣ Most In-Demand Skills
 
Next, I looked across *all* remote data analyst postings (not just top-paying ones) to see which skills came up the most.
 
```sql
SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_work_from_home = True
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
 
**What I found:**
 
| Skill | Demand Count |
|---|---|
| SQL | 7,291 |
| Excel | 4,611 |
| Python | 4,330 |
| Tableau | 3,745 |
| Power BI | 2,609 |
 
SQL and Excel are the clear foundation. Python, Tableau, and Power BI round things out as the technical/visualization layer employers expect.
 
---
 
### 4️⃣ Skills Based on Salary
 
I flipped the question around: instead of "what's in demand," I asked "what actually pays the most?"
 
```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
 
**What I found (top 10):**
 
| Skill | Avg. Salary ($) |
|---|---|
| PySpark | 208,172 |
| Bitbucket | 189,155 |
| Couchbase | 160,515 |
| Watson | 160,515 |
| DataRobot | 155,486 |
| GitLab | 154,500 |
| Swift | 153,750 |
| Jupyter | 152,777 |
| Pandas | 151,821 |
| Elasticsearch | 145,000 |
 
The big themes here: **big data + ML tools** (PySpark, DataRobot, Jupyter), **dev/deployment tooling** (GitLab, Kubernetes, Airflow), and **cloud platforms** (Elasticsearch, Databricks, GCP) all command a serious salary premium over "generalist" analyst skills.
 
---
 
### 5️⃣ Most Optimal Skills to Learn
 
This was the one I cared about most: combining **demand** and **salary** to find skills worth actually investing time in — filtering out anything with fewer than 10 postings so I wasn't chasing statistical noise.
 
```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```
 
**What I found (top 10):**
 
| Skill | Demand Count | Avg. Salary ($) |
|---|---|---|
| Go | 27 | 115,320 |
| Confluence | 11 | 114,210 |
| Hadoop | 22 | 113,193 |
| Snowflake | 37 | 112,948 |
| Azure | 34 | 111,225 |
| BigQuery | 13 | 109,654 |
| AWS | 32 | 108,317 |
| Java | 17 | 106,906 |
| SSIS | 12 | 106,683 |
| Jira | 20 | 104,918 |
 
A few other things stood out beyond this table:
- **Python and R** are the most in-demand programming languages (236 and 148 postings respectively), but their salaries sit around $100K–$101K — highly valued, but also widely available, which caps the premium.
- **Cloud skills** (Snowflake, Azure, AWS, BigQuery) balance strong demand with strong pay — a good place to specialize.
- **Tableau and Looker** confirm that BI/visualization skills remain essential, not optional.
- **Database skills** (Oracle, SQL Server, NoSQL) stay in steady demand with salaries between $97K–$104K, reflecting the ongoing need for solid data management fundamentals.
---
 
## 💡 What I Learned Building This
 
- **Writing complex queries** — combining multiple tables with joins and using `WITH` clauses (CTEs) to structure multi-step logic cleanly.
- **Aggregating data** — using `GROUP BY` alongside `COUNT()` and `AVG()` to turn raw rows into real insights.
- **Turning questions into queries** — the actual hardest part wasn't SQL syntax, it was translating a vague question ("what's worth learning?") into something a query could answer precisely.
## 📌 Conclusions
 
- **Top-paying remote data analyst jobs** range as high as **$650,000/year** — remote work does not mean lower pay.
- **SQL is non-negotiable.** It's the single most-required skill in high-paying jobs *and* the most in-demand skill overall.
- **Niche skills pay a premium.** Tools like PySpark, DataRobot, and Bitbucket pay significantly above the analyst average, but come with lower demand — a trade-off worth knowing.
- **The most balanced bet is SQL first**, followed by Python/Pandas, a BI tool (Tableau or Power BI), and a cloud platform (Snowflake, AWS, or Azure).
This project didn't just sharpen my SQL — it gave me an actual, evidence-backed roadmap for what to learn next as a data analyst instead of guessing based on generic career advice.
 
---
 
## 📁 Repo Structure
 
```
├── project_sql/          # All SQL queries used in this analysis
├── csv_files/            # Source data
└── README.md
```
