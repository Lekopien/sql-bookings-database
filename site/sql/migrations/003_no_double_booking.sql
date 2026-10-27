-- A staff member can't hold two active bookings that overlap in time.
-- Two ranges [a1, a2) and [b1, b2) overlap when a1 < b2 AND b1 < a2.
CREATE TRIGGER bookings_no_overlap_insert
BEFORE INSERT ON bookings
WHEN NEW.status IN ('booked', 'completed')
BEGIN
  SELECT RAISE(ABORT, 'staff member is already booked at that time')
  WHERE EXISTS (
    SELECT 1 FROM bookings
    WHERE staff_id = NEW.staff_id
      AND status IN ('booked', 'completed')
      AND starts_at < NEW.ends_at
      AND NEW.starts_at < ends_at
  );
END;

CREATE TRIGGER bookings_no_overlap_update
BEFORE UPDATE OF staff_id, starts_at, ends_at, status ON bookings
WHEN NEW.status IN ('booked', 'completed')
BEGIN
  SELECT RAISE(ABORT, 'staff member is already booked at that time')
  WHERE EXISTS (
    SELECT 1 FROM bookings
    WHERE staff_id = NEW.staff_id
      AND id <> NEW.id
      AND status IN ('booked', 'completed')
      AND starts_at < NEW.ends_at
      AND NEW.starts_at < ends_at
  );
END;

-- Overpaying a booking is almost always a data-entry mistake.
CREATE TRIGGER payments_no_overpay
BEFORE INSERT ON payments
BEGIN
  SELECT RAISE(ABORT, 'payment exceeds the remaining balance')
  WHERE NEW.amount_cents > (SELECT balance_cents FROM booking_balances WHERE booking_id = NEW.booking_id);
END;
