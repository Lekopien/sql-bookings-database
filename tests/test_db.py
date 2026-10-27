import sqlite3
import unittest

import db


class DatabaseTests(unittest.TestCase):
    def setUp(self):
        self.conn = db.connect(":memory:")
        db.migrate(self.conn)
        db.seed(self.conn)

    def q(self, sql, *args):
        return self.conn.execute(sql, args).fetchall()

    def test_migrations_are_idempotent(self):
        self.assertEqual(db.migrate(self.conn), [])
        versions = [v for (v,) in self.q("SELECT version FROM schema_migrations ORDER BY version")]
        self.assertEqual(versions, ["001_core_tables", "002_payments", "003_no_double_booking"])

    def test_rejects_overlapping_booking(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError, "already booked"):
            self.conn.execute("INSERT INTO bookings (client_id, staff_id, service_id, starts_at, ends_at) "
                              "VALUES (1, 2, 4, '2026-11-03 10:30', '2026-11-03 11:30')")

    def test_allows_back_to_back_and_cancelled_overlap(self):
        self.conn.execute("INSERT INTO bookings (client_id, staff_id, service_id, starts_at, ends_at) "
                          "VALUES (1, 2, 4, '2026-11-03 11:00', '2026-11-03 12:00')")
        self.conn.execute("INSERT INTO bookings (client_id, staff_id, service_id, starts_at, ends_at, status) "
                          "VALUES (1, 2, 4, '2026-11-03 10:15', '2026-11-03 10:45', 'cancelled')")

    def test_rejects_moving_into_a_clash(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("UPDATE bookings SET staff_id = 3, starts_at = '2026-11-04 09:30', ends_at = '2026-11-04 10:30' WHERE id = 12")

    def test_constraints(self):
        bad = [
            "INSERT INTO clients (name, email) VALUES ('X', 'not-an-email')",
            "INSERT INTO clients (name, email) VALUES ('Dup', 'HELLO@mamamboga.co.ke')",
            "INSERT INTO bookings (client_id, staff_id, service_id, starts_at, ends_at) VALUES (999, 1, 1, '2027-01-01 09:00', '2027-01-01 10:00')",
            "INSERT INTO bookings (client_id, staff_id, service_id, starts_at, ends_at) VALUES (1, 1, 1, '2027-01-01 10:00', '2027-01-01 09:00')",
            "INSERT INTO services (name, minutes, price_cents) VALUES ('Too long', 1000, 1)",
        ]
        for sql in bad:
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.conn.execute(sql)

    def test_overpayment_blocked(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError, "exceeds"):
            self.conn.execute("INSERT INTO payments (booking_id, amount_cents, method) VALUES (9, 2000000, 'cash')")

    def test_cascade_delete(self):
        self.conn.execute("DELETE FROM clients WHERE id = 2")
        self.assertEqual(self.q("SELECT COUNT(*) FROM bookings WHERE client_id = 2"), [(0,)])
        self.assertEqual(self.q("SELECT COUNT(*) FROM payments WHERE booking_id = 3"), [(0,)])

    def run_query(self, name):
        return db.run(self.conn, db.find_query(name).read_text())

    def test_revenue_by_month(self):
        cols, rows = self.run_query("revenue")
        self.assertEqual(cols, ["month", "revenue", "running_total", "change_vs_prev"])
        self.assertEqual([r[0] for r in rows], ["2026-08", "2026-09", "2026-10"])
        self.assertEqual(rows[-1][2], sum(r[1] for r in rows))

    def test_outstanding_balances(self):
        _, rows = self.run_query("outstanding")
        self.assertEqual({r[0] for r in rows}, {6, 9})  # partly paid builds

    def test_free_slots_exclude_bookings(self):
        _, rows = self.run_query("free_slots")
        otieno = [t for name, t in rows if name == "Otieno"]
        self.assertNotIn("10:00:00", otieno)
        self.assertEqual(len(otieno), 7)

    def test_every_query_runs(self):
        for file in sorted((db.ROOT / "queries").glob("*.sql")):
            with self.subTest(query=file.stem):
                cols, rows = db.run(self.conn, file.read_text())
                self.assertTrue(cols and rows)

    def test_indexes_used(self):
        plan = " ".join(r[-1] for r in self.q(
            "EXPLAIN QUERY PLAN SELECT * FROM bookings WHERE staff_id = 2 AND starts_at > '2026-10-01'"))
        self.assertIn("idx_bookings_staff_time", plan)


    def test_site_copy_is_in_sync(self):
        for src, dst in db.site_files().items():
            with self.subTest(file=src.name):
                self.assertTrue(dst.exists(), "run: python db.py sync-site")
                self.assertEqual(src.read_text(), dst.read_text(), "run: python db.py sync-site")


if __name__ == "__main__":
    unittest.main()
