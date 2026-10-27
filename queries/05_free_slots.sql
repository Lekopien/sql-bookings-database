-- Free one-hour slots for each staff member on 2026-11-03, between 09:00 and 17:00.
-- A recursive CTE builds the day's slots; NOT EXISTS removes those that overlap a booking.
WITH RECURSIVE slots(start) AS (
  SELECT '2026-11-03 09:00'
  UNION ALL
  SELECT strftime('%Y-%m-%d %H:%M', start, '+1 hour') FROM slots WHERE start < '2026-11-03 16:00'
)
SELECT st.name, time(s.start) AS free_from
FROM staff st CROSS JOIN slots s
WHERE st.active = 1
  AND NOT EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.staff_id = st.id AND b.status = 'booked'
      AND b.starts_at < strftime('%Y-%m-%d %H:%M', s.start, '+1 hour') AND s.start < b.ends_at
  )
ORDER BY st.name, s.start;
