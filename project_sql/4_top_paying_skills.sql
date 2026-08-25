/* what are the top skills based on salary? */


SELECT
    skills,
    ROUND(AVG(salary_year_avg),0) AS avg_salary

FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE
    job_title_short = 'Data Analyst'
    AND 
    salary_year_avg IS NOT NULL
    AND 
    job_work_from_home = TRUE

GROUP BY
    skills
ORDER by
    avg_salary DESC

LIMIT 25;


/* 
Quick insights

1. Big Data / distributed computing dominates the top

PySpark — $208,172 is the clear #1.
Databricks — $141,907
Airflow — $126,103
Scala — $124,903

This suggests that Data Analysts with data engineering / large-scale data processing skills can command significantly higher salaries.

2. Python ecosystem is very valuable
Several Python/data-science tools appear high on the list:

Pandas — $151,821
Jupyter — $152,777
NumPy — $143,513
Scikit-learn — $125,781
PySpark — $208,172

So the data shows that Python knowledge becomes particularly valuable when combined with large-scale data and ML tooling, rather than just basic Python.

3. DevOps + cloud skills appear surprisingly often
You have:

Kubernetes — $132,500
Jenkins — $125,436
Linux — $136,508
GCP — $122,500
GitLab — $154,500
Bitbucket — $189,155

That's an interesting trend: the highest-paying analyst roles in this dataset aren't necessarily traditional BI-only roles. They often overlap with engineering, cloud, infrastructure, and data platforms.

4. Data/AI platforms are another high-paying cluster

Couchbase — $160,515
Watson — $160,515
DataRobot — $155,486
Elasticsearch — $145,000
Databricks — $141,907

This points toward a broader trend of analysts working closer to AI platforms, databases, and production data infrastructure.


🔥 Highest-value cluster: PySpark + Databricks + Airflow
🐍 Python cluster: Pandas + NumPy + Scikit-learn
☁️ Infrastructure cluster: Linux + Kubernetes + GCP
🤖 AI cluster: DataRobot + Watson
🗄️ Data-platform cluster: Elasticsearch + Couchbase + PostgreSQL

[
  {
    "skills": "pyspark",
    "avg_salary": "208172"
  },
  {
    "skills": "bitbucket",
    "avg_salary": "189155"
  },
  {
    "skills": "couchbase",
    "avg_salary": "160515"
  },
  {
    "skills": "watson",
    "avg_salary": "160515"
  },
  {
    "skills": "datarobot",
    "avg_salary": "155486"
  },
  {
    "skills": "gitlab",
    "avg_salary": "154500"
  },
  {
    "skills": "swift",
    "avg_salary": "153750"
  },
  {
    "skills": "jupyter",
    "avg_salary": "152777"
  },
  {
    "skills": "pandas",
    "avg_salary": "151821"
  },
  {
    "skills": "elasticsearch",
    "avg_salary": "145000"
  },
  {
    "skills": "golang",
    "avg_salary": "145000"
  },
  {
    "skills": "numpy",
    "avg_salary": "143513"
  },
  {
    "skills": "databricks",
    "avg_salary": "141907"
  },
  {
    "skills": "linux",
    "avg_salary": "136508"
  },
  {
    "skills": "kubernetes",
    "avg_salary": "132500"
  },
  {
    "skills": "atlassian",
    "avg_salary": "131162"
  },
  {
    "skills": "twilio",
    "avg_salary": "127000"
  },
  {
    "skills": "airflow",
    "avg_salary": "126103"
  },
  {
    "skills": "scikit-learn",
    "avg_salary": "125781"
  },
  {
    "skills": "jenkins",
    "avg_salary": "125436"
  },
  {
    "skills": "notion",
    "avg_salary": "125000"
  },
  {
    "skills": "scala",
    "avg_salary": "124903"
  },
  {
    "skills": "postgresql",
    "avg_salary": "123879"
  },
  {
    "skills": "gcp",
    "avg_salary": "122500"
  },
  {
    "skills": "microstrategy",
    "avg_salary": "121619"
  }
] 


*/