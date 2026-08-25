
/* Find the count of the number of remote job posting per skills 
    -Display the top 5 skills by their demand in remote jobs
    -Include skills ID, Name and count of posting requiring the skills
 */

SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE
    job_title_short = 'Data Analyst'
    AND
    job_work_from_home = TRUE

GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;




