-- Monthly revenue with a running total and month-over-month change (window functions).
WITH monthly AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) / 100.0 AS revenue
  FROM payments
  GROUP BY month
)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month)            AS running_total,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS change_vs_prev
FROM monthly
ORDER BY month;
