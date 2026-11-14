WITH first_seen AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(session_date), WEEK(MONDAY)) AS cohort_week
  FROM `ecommerce-analytics-514205.ecommerce.sessions`
  GROUP BY user_id
),

cohort_sizes AS (
  SELECT
    cohort_week,
    COUNT(*) AS cohort_users
  FROM first_seen
  GROUP BY cohort_week
),

weekly_activity AS (
  SELECT
    f.cohort_week,
    DATE_DIFF(
      DATE_TRUNC(s.session_date, WEEK(MONDAY)),
      f.cohort_week,
      WEEK(MONDAY)
    ) AS week_number,
    COUNT(DISTINCT s.user_id) AS active_users
  FROM `ecommerce-analytics-514205.ecommerce.sessions` AS s
  JOIN first_seen AS f USING (user_id)
  GROUP BY 1, 2
)

SELECT
  c.cohort_week,
  week_offset AS week_number,
  c.cohort_users,
  COALESCE(a.active_users, 0) AS active_users,
  ROUND(
    SAFE_DIVIDE(COALESCE(a.active_users, 0), c.cohort_users),
    4
  ) AS retention_rate

FROM cohort_sizes AS c

-- Generate only weeks observed before the dataset ends.
CROSS JOIN UNNEST(
  GENERATE_ARRAY(
    0,
    DATE_DIFF(
      DATE_TRUNC(DATE '2021-01-31', WEEK(MONDAY)),
      c.cohort_week,
      WEEK(MONDAY)
    )
  )
) AS week_offset

LEFT JOIN weekly_activity AS a
  ON a.cohort_week = c.cohort_week
  AND a.week_number = week_offset

ORDER BY cohort_week, week_number;