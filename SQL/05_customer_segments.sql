CREATE OR REPLACE TABLE
  `ecommerce-analytics-514205.ecommerce.customers` AS

WITH visits AS (
  SELECT
    user_id,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchase_sessions,
    MAX(viewed_product) AS viewed_product,
    MAX(added_to_cart) AS added_to_cart,
    MAX(started_checkout) AS started_checkout
  FROM `ecommerce-analytics-514205.ecommerce.sessions`
  GROUP BY user_id
),

orders AS (
  SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(purchase_revenue_usd) AS gross_purchase_revenue_usd,
    COUNTIF(purchase_revenue_usd IS NULL) AS missing_revenue_orders
  FROM `ecommerce-analytics-514205.ecommerce.purchases`
  WHERE user_id IS NOT NULL
  GROUP BY user_id
)

SELECT
  v.*,
  COALESCE(o.order_count, 0) AS order_count,
  IF(o.order_count IS NULL, 0, o.gross_purchase_revenue_usd)
    AS gross_purchase_revenue_usd,
  COALESCE(o.missing_revenue_orders, 0) AS missing_revenue_orders,
  CASE
    WHEN o.order_count >= 2 THEN 'Repeat buyers'
    WHEN o.order_count = 1 THEN 'One-time buyers'
    WHEN v.purchase_sessions > 0
      THEN 'Purchase recorded without valid order'
    WHEN v.started_checkout = 1 THEN 'Checkout non-buyers'
    WHEN v.added_to_cart = 1 THEN 'Cart non-buyers'
    WHEN v.viewed_product = 1 THEN 'Product viewers'
    ELSE 'Other visitors'
  END AS segment
FROM visits AS v
LEFT JOIN orders AS o USING (user_id);


SELECT
  segment,
  COUNT(*) AS users,
  SUM(sessions) AS sessions,
  SUM(order_count) AS orders,
  ROUND(SUM(gross_purchase_revenue_usd), 2)
    AS gross_purchase_revenue_usd,
  SUM(missing_revenue_orders) AS missing_revenue_orders
FROM `ecommerce-analytics-514205.ecommerce.customers`
GROUP BY segment
ORDER BY users DESC;