-- Create our dataset if it does not already exist.
CREATE SCHEMA IF NOT EXISTS
  `ecommerce-analytics-514205.ecommerce`
OPTIONS(location = 'US');

-- Combine website actions into one row per visit.
CREATE OR REPLACE TABLE
  `ecommerce-analytics-514205.ecommerce.sessions` AS

WITH events AS (
  SELECT
    user_pseudo_id AS user_id,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
      LIMIT 1
    ) AS session_id,
    PARSE_DATE('%Y%m%d', event_date) AS event_day,
    event_timestamp,
    event_name,
    device.category AS device,
    traffic_source.source AS first_user_source
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
  CONCAT(user_id, '.', CAST(session_id AS STRING)) AS session_key,
  user_id,
  MIN(event_day) AS session_date,
  ARRAY_AGG(
    device IGNORE NULLS ORDER BY event_timestamp LIMIT 1
  )[SAFE_OFFSET(0)] AS device,
  ANY_VALUE(first_user_source) AS first_user_source,
  COUNT(*) AS event_count,
  COUNTIF(event_name = 'page_view') AS page_views,
  MAX(IF(event_name = 'view_item', 1, 0)) AS viewed_product,
  MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
  MAX(IF(event_name = 'begin_checkout', 1, 0)) AS started_checkout,
  MAX(IF(event_name = 'purchase', 1, 0)) AS purchased
FROM events
WHERE user_id IS NOT NULL AND session_id IS NOT NULL
GROUP BY user_id, session_id;

-- Check our new table.
SELECT
  COUNT(*) AS total_sessions,
  COUNT(*) - COUNT(DISTINCT session_key) AS duplicate_sessions,
  SUM(purchased) AS sessions_with_purchase
FROM `ecommerce-analytics-514205.ecommerce.sessions`;