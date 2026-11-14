WITH visits_daily AS (
  SELECT
    session_date AS report_date,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchase_sessions
  FROM `ecommerce-analytics-514205.ecommerce.sessions`
  GROUP BY report_date
),

orders_daily AS (
  SELECT
    purchase_date AS report_date,
    COUNT(*) AS valid_orders,
    SUM(purchase_revenue_usd) AS gross_purchase_revenue_usd,
    COUNTIF(purchase_revenue_usd IS NULL)
      AS missing_revenue_orders
  FROM `ecommerce-analytics-514205.ecommerce.purchases`
  GROUP BY report_date
)

SELECT
  report_date,
  COALESCE(v.sessions, 0) AS sessions,
  COALESCE(v.purchase_sessions, 0) AS purchase_sessions,
  COALESCE(o.valid_orders, 0) AS valid_orders,
  CASE
    WHEN o.valid_orders IS NULL THEN 0
    ELSE ROUND(o.gross_purchase_revenue_usd, 2)
  END AS gross_purchase_revenue_usd,
  COALESCE(o.missing_revenue_orders, 0)
    AS missing_revenue_orders

FROM visits_daily AS v
FULL OUTER JOIN orders_daily AS o USING (report_date)
ORDER BY report_date;