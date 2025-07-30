DROP TABLE IF EXISTS "COHORT_RETENTION";

CREATE TABLE "COHORT_RETENTION" AS 
WITH cohort_base AS (
  SELECT
    "USER_ID" AS user_id,
    MIN("WEEK") AS cohort_week
  FROM "RAW_DATA"
  GROUP BY user_id
),
relative_week AS (
	SELECT
	  r."USER_ID" as user_id,
	  r."WEEK",
	  c.cohort_week,
	  (r."WEEK" - c.cohort_week)/ 7 AS week_number
	FROM "RAW_DATA" r
	JOIN cohort_base c ON r."USER_ID" = c.user_id
),
user_week AS (
SELECT DISTINCT
  user_id,
  cohort_week,
  week_number
FROM relative_week
), 
retained_users AS (

 SELECT cohort_week, week_number, user_id
    FROM user_week
    WHERE week_number = 0

UNION 

SELECT
  curr.cohort_week,
  curr.week_number,
  curr.user_id
FROM user_week prev
JOIN user_week curr
  ON curr.user_id = prev.user_id
 AND curr.cohort_week = prev.cohort_week
 AND prev.week_number = curr.week_number - 1
 WHERE curr.week_number > 0
)
SELECT
  cohort_week as "COHORT",
  week_number "WEEK",
  COUNT(DISTINCT user_id) AS "USERS"
FROM retained_users
GROUP BY "COHORT", "WEEK"



