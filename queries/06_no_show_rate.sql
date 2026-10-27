-- Booking outcomes per service, including cancellation and no-show rates.
SELECT s.name AS service,
       COUNT(*) AS total,
       SUM(b.status = 'completed') AS completed,
       ROUND(100.0 * SUM(b.status = 'cancelled') / COUNT(*), 1) AS cancel_pct,
       ROUND(100.0 * SUM(b.status = 'no_show')   / COUNT(*), 1) AS no_show_pct
FROM bookings b JOIN services s ON s.id = b.service_id
GROUP BY s.id
ORDER BY total DESC;
