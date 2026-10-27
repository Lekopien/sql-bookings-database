# SQL Bookings Database

[![test](https://github.com/Lekopien/sql-bookings-database/actions/workflows/test.yml/badge.svg)](https://github.com/Lekopien/sql-bookings-database/actions/workflows/test.yml)

**Live SQL playground: https://sql.lekopien.com**

A relational database design for a studio that sells services by appointment (clients, staff, services, bookings, payments), written in **SQLite SQL**. The interesting part is that the rules live in the database itself: constraints, cascades, triggers and views. The analytics use window functions, CTEs and recursive queries.

The demo site runs the exact same SQL files in your browser through WebAssembly ([sql.js](https://github.com/sql-js/sql.js)).

## What's inside

| Path | Contents |
| --- | --- |
| `migrations/001_core_tables.sql` | Tables, CHECK constraints, foreign keys, indexes |
| `migrations/002_payments.sql` | Payments table and the `booking_balances` view |
| `migrations/003_no_double_booking.sql` | Triggers that block overlapping bookings and overpayments |
| `seed.sql` | Realistic demo data |
| `queries/` | Six reports (below) |
| `db.py` | Migration runner and CLI (Python standard library only) |
| `tests/test_db.py` | 13 tests covering constraints, triggers, queries and the query plan |
| `site/` | Browser playground served at sql.lekopien.com |

### Reports

1. **Revenue by month**: running total with `SUM() OVER` and month-over-month change with `LAG()`.
2. **Top clients**: `RANK()` by amount paid and share of revenue.
3. **Outstanding balances**: completed work that isn't fully paid, from the view.
4. **Staff utilisation**: hours per person per month, pivoted with conditional aggregation.
5. **Free slots**: a recursive CTE builds the day's hourly slots and `NOT EXISTS` removes booked ones.
6. **No-show rate**: outcomes per service.

## Run it

```bash
python3 db.py seed              # creates bookings.db, applies migrations, loads data
python3 db.py report            # runs every report
python3 db.py query free_slots  # one report
python3 db.py plan free_slots   # EXPLAIN QUERY PLAN
python3 -m unittest -v
```

```
month   | revenue | running_total | change_vs_prev
--------+---------+---------------+---------------
2026-08 | 63000.0 | 63000.0       |
2026-09 | 56000.0 | 119000.0      | -7000.0
2026-10 | 40000.0 | 159000.0      | -16000.0
```

Or use any SQLite client: `sqlite3 bookings.db < queries/01_revenue_by_month.sql`.

## Design decisions

- **Overlap rule:** two time ranges `[a1, a2)` and `[b1, b2)` overlap exactly when `a1 < b2 AND b1 < a2`. The trigger applies it on insert *and* update, ignores cancelled bookings, and allows back-to-back slots.
- **Money in cents** as integers, so totals never suffer floating-point drift.
- **Migrations** run each file once inside a transaction and record it in `schema_migrations`, so `migrate` is safe to run repeatedly.
- **Indexes match the queries:** `(staff_id, starts_at)` serves both the overlap trigger and the calendar; a test checks SQLite's planner actually uses it.

After editing SQL files run `python3 db.py sync-site` to refresh the playground copy (a test fails if you forget).

## License

MIT. `site/vendor/` contains sql.js, MIT licensed (see `SQLJS-LICENSE`).
