SELECT
  session_date,
  COALESCE(device, 'unknown') AS device,
  COALESCE(first_user_source, 'unknown') AS first_user_source,
  COUNT(*) AS sessions,
  SUM(viewed_product) AS product_view_sessions,
  SUM(added_to_cart) AS cart_sessions,
  SUM(started_checkout) AS checkout_sessions,
  SUM(purchased) AS purchase_sessions,

  COUNTIF(started_checkout = 1 AND purchased = 1)
    AS checkout_purchase_sessions,

  COUNTIF(started_checkout = 1 AND purchased = 0)
    AS checkout_without_purchase_sessions

FROM
  `ecommerce-analytics-514205.ecommerce.sessions`

GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;