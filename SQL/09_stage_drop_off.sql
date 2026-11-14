WITH stages AS (
  SELECT
    1 AS step,
    'Session → Product View' AS stage,
    COUNT(*) AS starting_sessions,
    COUNTIF(viewed_product = 0) AS dropped_sessions
  FROM `ecommerce-analytics-514205.ecommerce.sessions`

  UNION ALL

  SELECT 2, 'Product View → Cart',
    COUNTIF(viewed_product = 1),
    COUNTIF(viewed_product = 1 AND added_to_cart = 0)
  FROM `ecommerce-analytics-514205.ecommerce.sessions`

  UNION ALL

  SELECT 3, 'Cart → Checkout',
    COUNTIF(added_to_cart = 1),
    COUNTIF(added_to_cart = 1 AND started_checkout = 0)
  FROM `ecommerce-analytics-514205.ecommerce.sessions`

  UNION ALL

  SELECT 4, 'Checkout → Purchase',
    COUNTIF(started_checkout = 1),
    COUNTIF(started_checkout = 1 AND purchased = 0)
  FROM `ecommerce-analytics-514205.ecommerce.sessions`
)
SELECT
  *,
  starting_sessions - dropped_sessions AS sessions_with_both_steps,
  SAFE_DIVIDE(dropped_sessions, starting_sessions) AS drop_off_rate
FROM stages
ORDER BY step;