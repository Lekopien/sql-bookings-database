-- Clients ranked by what they've paid, with their booking count and share of revenue.
SELECT c.name,
       COUNT(DISTINCT b.id)                                 AS bookings,
       COALESCE(SUM(p.amount_cents), 0) / 100.0             AS paid,
       ROUND(100.0 * COALESCE(SUM(p.amount_cents), 0) / (SELECT SUM(amount_cents) FROM payments), 1) AS pct_of_revenue,
       RANK() OVER (ORDER BY COALESCE(SUM(p.amount_cents), 0) DESC) AS rank
FROM clients c
LEFT JOIN bookings b ON b.client_id = c.id
LEFT JOIN payments p ON p.booking_id = b.id
GROUP BY c.id
ORDER BY rank;
