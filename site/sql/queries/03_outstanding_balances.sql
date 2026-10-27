-- Completed work that hasn't been fully paid yet.
SELECT booking_id, client, service, date(starts_at) AS day,
       due_cents / 100.0 AS due, paid_cents / 100.0 AS paid, balance_cents / 100.0 AS owed
FROM booking_balances
WHERE status = 'completed' AND balance_cents > 0
ORDER BY owed DESC;
