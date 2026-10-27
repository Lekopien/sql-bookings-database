-- Core entities for a small studio that sells services by appointment.
CREATE TABLE clients (
  id          INTEGER PRIMARY KEY,
  name        TEXT    NOT NULL,
  email       TEXT    NOT NULL UNIQUE COLLATE NOCASE CHECK (email LIKE '%_@_%._%'),
  phone       TEXT,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE staff (
  id      INTEGER PRIMARY KEY,
  name    TEXT NOT NULL,
  role    TEXT NOT NULL CHECK (role IN ('designer', 'developer', 'consultant')),
  active  INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

CREATE TABLE services (
  id            INTEGER PRIMARY KEY,
  name          TEXT    NOT NULL UNIQUE,
  minutes       INTEGER NOT NULL CHECK (minutes BETWEEN 15 AND 480),
  price_cents   INTEGER NOT NULL CHECK (price_cents >= 0)
);

CREATE TABLE bookings (
  id          INTEGER PRIMARY KEY,
  client_id   INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  staff_id    INTEGER NOT NULL REFERENCES staff(id),
  service_id  INTEGER NOT NULL REFERENCES services(id),
  starts_at   TEXT    NOT NULL,           -- ISO-8601, UTC
  ends_at     TEXT    NOT NULL,
  status      TEXT    NOT NULL DEFAULT 'booked' CHECK (status IN ('booked', 'completed', 'cancelled', 'no_show')),
  notes       TEXT,
  CHECK (ends_at > starts_at)
);

-- Indexes chosen for the queries in queries/: lookups by staff and time, and by client.
CREATE INDEX idx_bookings_staff_time ON bookings (staff_id, starts_at);
CREATE INDEX idx_bookings_client     ON bookings (client_id);
CREATE INDEX idx_bookings_status     ON bookings (status);
