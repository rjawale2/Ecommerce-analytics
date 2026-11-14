SELECT
  COUNT(*) AS total_sessions,
  SUM(viewed_product) AS product_view_sessions,
  SUM(added_to_cart) AS cart_sessions,
  SUM(started_checkout) AS checkout_sessions,
  SUM(purchased) AS purchase_sessions,

  COUNTIF(started_checkout = 1 AND purchased = 0)
    AS checkout_without_purchase_sessions,

  ROUND(
    100.0 * SAFE_DIVIDE(
      COUNTIF(started_checkout = 1 AND purchased = 0),
      COUNTIF(started_checkout = 1)
    ),
    2
  ) AS checkout_dropoff_pct

FROM
  `ecommerce-analytics-514205.ecommerce.sessions`;