# 📊 Data Analyst Job Market Analysis (SQL)
 
*A SQL-driven deep dive into what data analyst jobs actually pay, and what skills actually get you there.*
 
![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
 
---
 
## 📑 Table of Contents
 
- [The Problems I Set Out to Solve](#-the-problems-i-set-out-to-solve)
- [About the Data](#️-about-the-data)
- [Tools I Used](#️-tools-i-used)
- [How the Data Fits Together](#-how-the-data-fits-together)
- [The Analysis](#-the-analysis)
  - [1. Top-Paying Data Analyst Jobs](#1️⃣-top-paying-data-analyst-jobs)
  - [2. Skills for Top-Paying Jobs](#2️⃣-skills-for-top-paying-jobs)
  - [3. Most In-Demand Skills](#3️⃣-most-in-demand-skills)
  - [4. Skills Based on Salary](#4️⃣-skills-based-on-salary)
  - [5. Most Optimal Skills to Learn](#5️⃣-most-optimal-skills-to-learn)
- [Key Takeaways at a Glance](#-key-takeaways-at-a-glance)
- [What I Learned Building This](#-what-i-learned-building-this)
- [Challenges I Ran Into](#-challenges-i-ran-into)
- [Conclusions](#-conclusions)
- [Repo Structure](#-repo-structure)
- [Running This Yourself](#-running-this-yourself)
- [Possible Next Steps](#-possible-next-steps)
- [About Me](#-about-me)
---
 
## 🎯 The Problems I Set Out to Solve
 
When I started job hunting for data analyst roles, I realized I was navigating the market blind. I didn't actually know:
 
- Which skills were worth prioritizing over others
- Which jobs paid the most, and whether that pay was realistic or an outlier
- Whether remote roles were even competitive on salary compared to on-site ones
- Whether the skills everyone tells you to learn (SQL, Python, Excel) are actually the ones that pay the best, or just the ones that are easiest to list on a job posting
So instead of relying on generic career advice or "top 10 skills" listicles, I decided to answer these questions myself, directly from real job posting data, using SQL. Specifically, I wanted to answer:
 
1. **What are the top-paying data analyst jobs?**
2. **What skills are required for these top-paying jobs?**
3. **What skills are most in demand for data analysts?**
4. **Which skills are associated with higher salaries?**
5. **What are the most optimal skills to learn** — meaning skills that are both in high demand *and* well paid?
This repo is my SQL-driven answer to all five, with the actual queries, the results, and what I took away from each one.
 
---
 
## 🗂️ About the Data
 
The dataset comes from real-world job postings and includes:
 
- Job titles and short titles (e.g., "Senior Data Analyst" → `Data Analyst`)
- Company names
- Job location and remote-work status
- Average yearly salary (where disclosed)
- Posting dates
- Every individual skill listed on each posting
This combination is what makes the analysis possible — most job boards only show you *one* of these things at a time (a salary here, a skill list there). Having them joined together in a proper relational database is what let me ask compound questions like *"what skill shows up most often in jobs that pay over $150K?"* instead of guessing.
 
## 🛠️ Tools I Used
 
| Tool | Why I Used It |
|---|---|
| **SQL** | The core of the analysis — every insight in this repo comes from a SQL query, not a spreadsheet |
| **PostgreSQL** | Database engine for storing and querying the job posting data |
| **VS Code** | Writing, running, and organizing my SQL scripts |
| **Git & GitHub** | Version control and sharing my work publicly |
 
---
 
## 🔗 How the Data Fits Together
 
The database is organized as a small relational schema — nothing fancy, but understanding it makes every query below much easier to follow:

![Database Schema](assets\schema.png)

- **`job_postings_fact`** is the core table — one row per job posting.
- **`company_dim`** stores the company name behind each posting.
- **`skills_job_dim`** is a bridge table — because one job posting can require *many* skills, and one skill can appear across *many* jobs (a classic many-to-many relationship).
- **`skills_dim`** stores the actual skill names.
Every query in this project is essentially a different way of joining and filtering these four tables.
 
---
 
## 🔍 The Analysis
 
Each question got its own SQL query. Here's how I approached each one, and what I found.
 
### 1️⃣ Top-Paying Data Analyst Jobs
 
**The question:** If I only looked at the highest-paying data analyst jobs available remotely, what would they look like?
 
**My approach:** I filtered `job_postings_fact` for roles where the short title is `Data Analyst`, the location is `Anywhere` (i.e., fully remote), and the salary field isn't blank — then sorted by salary and kept the top 10.
 
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
 
**Takeaways:**
- Salaries in the top 10 range from **$184,000 to $650,000** — a massive spread, which tells me "data analyst" as a title covers a huge range of seniority and scope.
- Companies like **SmartAsset, Meta, and AT&T** show up, proving strong demand spans multiple industries — not just tech companies.
- Titles vary widely — from **Data Analyst** to **Director of Analytics** — showing how broad this career path can be, and how a "Data Analyst"-labeled posting can sometimes actually be a leadership role in disguise.
> 💡 Add the full 10-row output (job title, company, salary) here once you export it from your own query run — it'll make this section even easier to scan.
 
---
 
### 2️⃣ Skills for Top-Paying Jobs
 
**The question:** Now that I know *which* jobs pay the most, what skills do they actually ask for?
 
**My approach:** I used a `WITH` clause (a Common Table Expression, or CTE) to first isolate the same top 10 jobs from Question 1, then joined that result against the skills tables to unpack every skill tied to each of those postings.
 
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
 
**Why a CTE here?** Without it, I'd have had to repeat the entire top-10 filtering logic inline inside a subquery, which gets messy fast. The CTE lets me name that intermediate result (`top_paying_jobs`) and reuse it cleanly — a small thing, but it's the difference between a query you can read in ten seconds and one you have to trace line by line.
 
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
 
**Takeaways:**
- **SQL** appeared 8 out of 10 times across the top 10 highest-paying jobs — it's practically a baseline requirement at this level.
- **Python** wasn't far behind, appearing 7 times, reinforcing that scripting/automation skills matter even in "analyst" (not just "engineer") roles.
- **Tableau** showed up 6 times, with R, Snowflake, Pandas, and Excel trailing behind — showing that visualization ability is expected, but slightly less universal than SQL or Python.
---
 
### 3️⃣ Most In-Demand Skills
 
**The question:** Forget the top-paying jobs for a second — across *every* remote data analyst posting, what skills come up the most?
 
**My approach:** This time I didn't filter by salary at all. I joined every remote `Data Analyst` posting against its skills, grouped by skill, counted how often each one appeared, and kept the top 5.
 
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
 
**Takeaways:**
- **SQL and Excel are the clear foundation.** SQL leads by a wide margin, and Excel — despite being "basic" — is still the second most requested skill across thousands of postings. Don't skip it just because it feels old-school.
- **Python, Tableau, and Power BI round things out** as the technical/visualization layer employers expect on top of the fundamentals.
- Compared to Question 2, notice that Excel jumps way up in general demand even though it barely showed up in the *top-paying* jobs — a sign that Excel gets you in the door, but it's not what pushes salaries higher.
---
 
### 4️⃣ Skills Based on Salary
 
**The question:** Instead of "what's in demand," I flipped it: "what skill, on average, actually pays the most?"
 
**My approach:** Same join structure as before, but this time I grouped by skill and calculated the *average* salary for postings requiring that skill, rather than counting frequency.
 
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
 
**Takeaways:**
- **Big data + ML tools** (PySpark, DataRobot, Jupyter) sit at the very top — these are skills that overlap with data engineering and data science, not just traditional analysis.
- **Dev/deployment tooling** (GitLab, Bitbucket) shows up surprisingly high — a strong signal that analysts who can work inside a software engineering workflow (version control, CI/CD) get paid a premium.
- **Cloud platforms** (Elasticsearch, Databricks, GCP) reinforce that cloud fluency is no longer optional at the higher end of the pay scale.
- None of the highest-paying skills here are the "obvious" ones from Question 3 — which is exactly why this question mattered. Demand and pay are *not* the same thing.
---
 
### 5️⃣ Most Optimal Skills to Learn
 
**The question:** This is the one I actually cared about most — not "what pays the most" in isolation (since a $200K skill with only 3 job postings isn't a realistic bet), but **what skill gives me the best combination of demand *and* pay?**
 
**My approach:** I combined the logic from Questions 3 and 4 into a single query — grouping by skill, calculating both the count and average salary — and used a `HAVING` clause to filter out any skill with fewer than 10 postings, so a single outlier job couldn't skew the results.
 
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
 
**Why the `HAVING > 10` filter matters:** Without it, a skill that appears in exactly one $300K posting would technically show an "average salary" of $300K and rank at the top — which would be misleading. Filtering for at least 10 postings makes sure every skill on this list is backed by a reasonable sample size, not a fluke.
 
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
 
**Additional context beyond the top 10:**
 
| Skill | Demand Count | Avg. Salary ($) |
|---|---|---|
| Python | 236 | ~101,397 |
| R | 148 | ~100,499 |
| Tableau | 230 | ~99,288 |
| Looker | 49 | ~103,795 |
 
**Takeaways:**
- **Python and R** are the most in-demand programming languages by far (236 and 148 postings respectively), but their salaries sit around $100K–$101K — highly valued, but also *widely available*, which naturally caps the salary premium since more people can offer them.
- **Cloud skills** (Snowflake, Azure, AWS, BigQuery) hit a strong balance: meaningful demand *and* meaningful pay — this is the sweet spot I'd point a beginner toward after they've nailed SQL.
- **Tableau and Looker** confirm that BI/visualization skills remain essential, not optional, even if they don't top the salary charts.
- **Database skills** (Oracle, SQL Server, NoSQL) stay in steady demand with salaries between $97K–$104K, reflecting the ongoing, unglamorous-but-real need for solid data management fundamentals.
---
 
## 📈 Key Takeaways at a Glance
 
| Question | Top Answer |
|---|---|
| Highest-paying remote Data Analyst salary | $650,000 |
| Most-required skill in top-paying jobs | SQL (8/10 postings) |
| Most in-demand skill overall | SQL (7,291 postings) |
| Highest average-paying skill | PySpark ($208,172) |
| Best "optimal" skill (demand + pay balance) | Go ($115,320 avg, 27 postings) |
 
---
 
## 💡 What I Learned Building This
 
- **Writing complex queries** — combining multiple tables with joins and using `WITH` clauses (CTEs) to structure multi-step logic cleanly instead of nesting subqueries into an unreadable mess.
- **Aggregating data** — using `GROUP BY` alongside `COUNT()` and `AVG()` to turn thousands of raw rows into real, quotable insights.
- **Filtering aggregates correctly** — understanding *why* `HAVING` exists separately from `WHERE` (you can't filter on an aggregate like `COUNT()` in a `WHERE` clause, since `WHERE` runs before the grouping happens).
- **Turning vague questions into precise queries** — honestly, the hardest part wasn't SQL syntax. It was translating a fuzzy question like *"what's worth learning?"* into something a query could answer exactly and unambiguously.
## 🧩 Challenges I Ran Into
 
- **Deciding how to define "top-paying."** Should it be the single highest salary, or an average across many postings? I settled on top individual postings for Question 1, then switched to averages for Questions 3–5 once I was analyzing skills across many jobs at once — mixing the two would have been misleading.
- **Handling missing salary data.** A large chunk of postings don't disclose a salary at all, so every salary-based query needed an explicit `salary_year_avg IS NOT NULL` filter — otherwise `AVG()` and sorting would have behaved unpredictably.
- **Avoiding misleading averages.** Early on, a skill with just 1–2 postings could show up with an inflated "average salary" purely by chance. Adding the `HAVING COUNT(...) > 10` filter in Question 5 fixed this and made the results far more trustworthy.
## 📌 Conclusions
 
- **Top-paying remote data analyst jobs** range as high as **$650,000/year** — remote work does not mean lower pay.
- **SQL is non-negotiable.** It's the single most-required skill in high-paying jobs *and* the most in-demand skill overall — if you only learn one thing from this project, it should confirm that SQL comes first.
- **Niche skills pay a premium, but carry risk.** Tools like PySpark, DataRobot, and Bitbucket pay significantly above the analyst average, but come with lower demand — a trade-off worth knowing before you specialize too early.
- **The most balanced learning path** looks like: **SQL first**, then **Python/Pandas**, then a **BI tool** (Tableau or Power BI), then a **cloud platform** (Snowflake, AWS, or Azure).
This project didn't just sharpen my SQL — it gave me an actual, evidence-backed roadmap for what to learn next as a data analyst, instead of guessing based on generic career advice.
 
---
 
## 📁 Repo Structure
 
```
├── project_sql/          # All SQL queries used in this analysis, one file per question
├── csv_files/            # Source data used to build the database
└── README.md             # You are here
```
 
## 🚀 Running This Yourself
 
1. **Clone the repo**
```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
```
2. **Set up PostgreSQL** (or your SQL engine of choice) and create a new database.
3. **Load the data** from `csv_files/` into the four tables described in [How the Data Fits Together](#-how-the-data-fits-together): `job_postings_fact`, `company_dim`, `skills_job_dim`, and `skills_dim`.
4. **Run the queries** in `project_sql/` in order — each one builds on the concepts from the last, so going in sequence makes the logic easier to follow.
5. **Compare your output** to the tables in this README — your exact numbers may shift slightly depending on when the dataset was pulled.
## 🔮 Possible Next Steps
 
- Add a companion Python/Pandas notebook to generate the charts automatically instead of manually.
- Extend the analysis beyond `Data Analyst` to compare against `Data Scientist` and `Data Engineer` titles.
- Break the salary analysis down by location instead of just remote-vs-not, to see which cities offer the best pay-to-cost-of-living ratio.
- Automate this into a small dashboard (Tableau/Power BI/Streamlit) so the results update as new job posting data comes in.
## 🙋 About Me
 
This project was built as a hands-on way to apply SQL to a real, personally relevant problem — figuring out how to prioritize my own skill development as I look toward a data analyst career. If you spot something worth improving or have suggestions, feel free to open an issue or a pull request.