CREATE TABLE payments (
  id           INTEGER PRIMARY KEY,
  booking_id   INTEGER NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  method       TEXT    NOT NULL CHECK (method IN ('mpesa', 'card', 'cash', 'bank')),
  paid_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_payments_booking ON payments (booking_id);

-- What each booking costs, what has been paid, and what is still owed.
CREATE VIEW booking_balances AS
SELECT b.id                                   AS booking_id,
       c.name                                 AS client,
       s.name                                 AS service,
       b.starts_at,
       b.status,
       s.price_cents                          AS due_cents,
       COALESCE(SUM(p.amount_cents), 0)       AS paid_cents,
       s.price_cents - COALESCE(SUM(p.amount_cents), 0) AS balance_cents
FROM bookings b
JOIN clients  c ON c.id = b.client_id
JOIN services s ON s.id = b.service_id
LEFT JOIN payments p ON p.booking_id = b.id
GROUP BY b.id;
