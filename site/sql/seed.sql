INSERT INTO staff (id, name, role) VALUES
  (1, 'Wanjiru', 'designer'), (2, 'Otieno', 'developer'), (3, 'Achieng', 'consultant');

INSERT INTO services (id, name, minutes, price_cents) VALUES
  (1, 'Discovery call', 30, 0),
  (2, 'Landing page design', 120, 1500000),
  (3, 'Website build sprint', 240, 4000000),
  (4, 'Site speed audit', 60, 800000),
  (5, 'SEO consultation', 60, 600000);

INSERT INTO clients (id, name, email, phone) VALUES
  (1, 'Mama Mboga Grocers', 'hello@mamamboga.co.ke', '+254700000001'),
  (2, 'Savannah Safaris', 'info@savannahsafaris.com', '+254700000002'),
  (3, 'Juja Tech Hub', 'team@jujatech.africa', NULL),
  (4, 'Kilele Fitness', 'coach@kilelefit.com', '+254700000004'),
  (5, 'Pwani Bakery', 'orders@pwanibakery.co.ke', NULL);

INSERT INTO bookings (id, client_id, staff_id, service_id, starts_at, ends_at, status) VALUES
  (1, 1, 3, 1, '2026-08-03 09:00', '2026-08-03 09:30', 'completed'),
  (2, 1, 1, 2, '2026-08-05 10:00', '2026-08-05 12:00', 'completed'),
  (3, 2, 2, 3, '2026-08-12 09:00', '2026-08-12 13:00', 'completed'),
  (4, 3, 2, 4, '2026-08-20 14:00', '2026-08-20 15:00', 'completed'),
  (5, 2, 3, 5, '2026-09-02 11:00', '2026-09-02 12:00', 'completed'),
  (6, 4, 1, 2, '2026-09-09 10:00', '2026-09-09 12:00', 'completed'),
  (7, 4, 2, 3, '2026-09-16 09:00', '2026-09-16 13:00', 'completed'),
  (8, 5, 3, 1, '2026-09-18 15:00', '2026-09-18 15:30', 'no_show'),
  (9, 1, 2, 3, '2026-10-07 09:00', '2026-10-07 13:00', 'completed'),
  (10, 3, 1, 2, '2026-10-14 13:00', '2026-10-14 15:00', 'cancelled'),
  (11, 5, 1, 2, '2026-10-21 10:00', '2026-10-21 12:00', 'completed'),
  (12, 2, 2, 4, '2026-11-03 10:00', '2026-11-03 11:00', 'booked'),
  (13, 4, 3, 5, '2026-11-04 09:00', '2026-11-04 10:00', 'booked');

INSERT INTO payments (booking_id, amount_cents, method, paid_at) VALUES
  (2, 1500000, 'mpesa', '2026-08-05 12:30'),
  (3, 2000000, 'bank',  '2026-08-12 13:30'),
  (3, 2000000, 'bank',  '2026-08-30 09:00'),
  (4,  800000, 'mpesa', '2026-08-20 15:10'),
  (5,  600000, 'card',  '2026-09-02 12:05'),
  (6, 1000000, 'mpesa', '2026-09-09 12:10'),
  (7, 4000000, 'bank',  '2026-09-20 10:00'),
  (9, 2500000, 'mpesa', '2026-10-07 13:20'),
  (11, 1500000, 'cash', '2026-10-21 12:00');
