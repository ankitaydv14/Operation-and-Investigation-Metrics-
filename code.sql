-- Number of jobs reviewd 
SELECT
count(DISTINCT job_id)/(24*30) AS jb_cnt
FROM sql_table
WHERE ds BETWEEN '01-11-2020' AND '30-11-2020';


-- Throughput 

SELECT ds, jb_cnt,  
(AVG(jb_cnt) OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW ) ) as Rolling_avg
From (
 SELECT ds,
 Count(Distinct job_id) AS jb_cnt
FROM sql_table
WHERE ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds)a;


-- Percentage Share of each Language 

SELECT language, count(*) * 100.0/ sum(count(*)) over()
FROM sql_table 
GROUP BY language;


-- Duplicate Rows

SELECT ds,job_id,actor_id,event,language,time_spent,org,
COUNT(*) AS cnt 
FROM sql_table
GROUP BY ds,job_id,actor_id,event,language,time_spent,org
HAVING COUNT(*) >1;


-- user engagement rate

SELECT 
event_type, event_name,
EXTRACT(month from occurred_at)as week,
COUNT(DISTINCT user_id) AS weekly_active_users
FROM events 
GROUP BY event_name, event_type, week ;


-- user growth 

SELECT
EXTRACT(day FROM created_at) AS day,
COUNT(*) AS all_users,
COUNT(CASE WHEN activated_at IS NOT NULL THEN user_id ELSE NULL END) AS activated_users
FROM users 
GROUP BY 1
ORDER BY 1;


-- weekly retension 

with signup_cohort AS 
(SELECT company_id, date(created_at) AS signup_week
FROM users)
SELECT signup_week,
COUNT(DISTINCT signup_cohort.company_id) AS total_signups,
COUNT(DISTINCT events.user_id) as retained_users,
COUNT(DISTINCT events.user_id)/COUNT(DISTINCT signup_cohort.company_id) as retension_rate 
FROM signup_cohort
left JOIN events  on events.user_id=signup_cohort.company_id
GROUP BY 1
ORDER BY 1;


-- weekly engagement 

With weekly_engagement as 
(SELECT  user_id, device,
EXTRACT(week from occurred_at)as week,
COUNT(*) as engagement
FROM events 
GROUP BY user_id, device, week
ORDER BY user_id, device, week)
SELECT device, week, SUM(engagement) as weekly_engagement
FROM weekly_engagement
GROUP BY device, week 
ORDER BY device, week;


-- email engagement

SELECT 
count(distinct user_id) as user,
Date_format("occurred_at", "%U") AS week,
COUNT(CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS weekly_emails,
count(CASE WHEN action = 'sent_reengagement_email' THEN user_id ELSE NULL END) AS reengagement_emails,
count(CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS email_opens,
count(CASE WHEN action = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthroughs 
FROM email_events 
GROUP BY action ;



