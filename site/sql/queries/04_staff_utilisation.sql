-- Hours each staff member spent on completed bookings, per month (pivot with conditional aggregation).
SELECT st.name,
       ROUND(SUM(CASE WHEN strftime('%m', b.starts_at) = '08' THEN (julianday(b.ends_at) - julianday(b.starts_at)) * 24 END), 1) AS aug_hours,
       ROUND(SUM(CASE WHEN strftime('%m', b.starts_at) = '09' THEN (julianday(b.ends_at) - julianday(b.starts_at)) * 24 END), 1) AS sep_hours,
       ROUND(SUM(CASE WHEN strftime('%m', b.starts_at) = '10' THEN (julianday(b.ends_at) - julianday(b.starts_at)) * 24 END), 1) AS oct_hours
FROM staff st
LEFT JOIN bookings b ON b.staff_id = st.id AND b.status = 'completed'
GROUP BY st.id
ORDER BY st.name;
