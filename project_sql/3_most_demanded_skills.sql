
/* Find the count of the number of remote job posting per skills 
    -Display the top 5 skills by their demand in remote jobs
    -Include skills ID, Name and count of posting requiring the skills
 */

WITH remote_jobs_skills AS (
    SELECT 
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings
    ON job_postings.job_id = skills_to_job.job_id

    WHERE
        job_postings.job_work_from_home = TRUE
        AND 
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT
    skills.skill_id,
    skills.skills AS skill_name,
    skill_count

FROM remote_jobs_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_jobs_skills.skill_id

ORDER BY
    skill_count DESC
LIMIT 5;




Select *

FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id