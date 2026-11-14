-- Save one purchase record per transaction ID.
CREATE OR REPLACE TABLE
  `ecommerce-analytics-514205.ecommerce.purchases` AS

SELECT
  ecommerce.transaction_id AS transaction_id,
  user_pseudo_id AS user_id,
  PARSE_DATE('%Y%m%d', event_date) AS purchase_date,
  ecommerce.purchase_revenue_in_usd AS purchase_revenue_usd,
  items

FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
  _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
  AND NULLIF(TRIM(ecommerce.transaction_id), '') IS NOT NULL
  AND ecommerce.transaction_id NOT IN ('(not set)', '<Other>')

QUALIFY ROW_NUMBER() OVER (
  PARTITION BY ecommerce.transaction_id
  ORDER BY event_timestamp
) = 1;


-- Summarize purchased products by category.
SELECT
  COALESCE(NULLIF(item.item_category, ''), 'Unknown')
    AS category,
  COUNT(DISTINCT transaction_id) AS orders_including_category,
  SUM(item.quantity) AS units_sold,
  ROUND(SUM(item.item_revenue_in_usd), 2)
    AS gross_item_revenue_usd,
  COUNTIF(item.item_revenue_in_usd IS NULL)
    AS missing_revenue_item_rows

FROM
  `ecommerce-analytics-514205.ecommerce.purchases`
CROSS JOIN UNNEST(items) AS item

GROUP BY category
ORDER BY gross_item_revenue_usd DESC;