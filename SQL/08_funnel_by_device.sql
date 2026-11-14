SELECT
  s.device,
  f.step,
  f.stage,
  COUNTIF(f.started) AS starting_sessions,
  COUNTIF(f.converted) AS converted_sessions
FROM `ecommerce-analytics-514205.ecommerce.sessions` AS s
CROSS JOIN UNNEST([
  STRUCT(1 AS step, 'Session → Product View' AS stage,
         TRUE AS started, s.viewed_product = 1 AS converted),
  STRUCT(2, 'Product View → Add to Cart',
         s.viewed_product = 1,
         s.viewed_product = 1 AND s.added_to_cart = 1),
  STRUCT(3, 'Add to Cart → Checkout',
         s.added_to_cart = 1,
         s.added_to_cart = 1 AND s.started_checkout = 1),
  STRUCT(4, 'Checkout → Purchase',
         s.started_checkout = 1,
         s.started_checkout = 1 AND s.purchased = 1),
  STRUCT(5, 'Session → Purchase',
         TRUE, s.purchased = 1)
]) AS f
GROUP BY s.device, f.step, f.stage
ORDER BY s.device, f.step;