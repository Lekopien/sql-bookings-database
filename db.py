"""Bookings database tool.

    python db.py migrate            apply new migrations
    python db.py seed               load demo data
    python db.py query <name>       run queries/<name>*.sql and print a table
    python db.py report             run every query
    python db.py plan <name>        show SQLite's query plan
    python db.py sync-site          copy the SQL into site/sql for the browser playground
"""
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB_FILE = ROOT / "bookings.db"


def connect(path: str | Path = DB_FILE) -> sqlite3.Connection:
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def migrate(conn: sqlite3.Connection) -> list[str]:
    """Applies migrations/NNN_*.sql in order, each once, each in its own transaction."""
    conn.execute("CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TEXT DEFAULT (datetime('now')))")
    done = {v for (v,) in conn.execute("SELECT version FROM schema_migrations")}
    applied = []
    for file in sorted((ROOT / "migrations").glob("*.sql")):
        if file.stem in done:
            continue
        try:
            conn.executescript("BEGIN;\n" + file.read_text() + f"\nINSERT INTO schema_migrations (version) VALUES ('{file.stem}');\nCOMMIT;")
        except sqlite3.Error:
            conn.rollback()
            raise
        applied.append(file.stem)
    return applied


def seed(conn: sqlite3.Connection) -> None:
    conn.executescript((ROOT / "seed.sql").read_text())


def site_files() -> dict[Path, Path]:
    """Maps each SQL source file to its copy under site/sql/."""
    sources = [*sorted((ROOT / "migrations").glob("*.sql")), ROOT / "seed.sql", *sorted((ROOT / "queries").glob("*.sql"))]
    return {src: ROOT / "site" / "sql" / src.relative_to(ROOT) for src in sources}


def sync_site() -> None:
    for src, dst in site_files().items():
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(src.read_text())
    (ROOT / "site" / "sql" / "manifest.txt").write_text(
        "\n".join(str(dst.relative_to(ROOT / "site")) for dst in site_files().values()) + "\n")


def find_query(name: str) -> Path:
    matches = sorted((ROOT / "queries").glob(f"*{name}*.sql"))
    if not matches:
        raise SystemExit(f"no query matching {name!r}")
    return matches[0]


def run(conn: sqlite3.Connection, sql: str) -> tuple[list[str], list[tuple]]:
    cur = conn.execute(sql)
    return [d[0] for d in cur.description], cur.fetchall()


def table(cols: list[str], rows: list[tuple]) -> str:
    cells = [[("" if v is None else str(v)) for v in r] for r in rows]
    widths = [max(len(c), *(len(r[i]) for r in cells)) if cells else len(c) for i, c in enumerate(cols)]
    line = lambda vals: " | ".join(v.ljust(w) for v, w in zip(vals, widths))  # noqa: E731
    return "\n".join([line(cols), "-+-".join("-" * w for w in widths), *map(line, cells)])


def main(argv: list[str]) -> None:
    if not argv:
        raise SystemExit(__doc__)
    cmd, *rest = argv
    conn = connect()
    if cmd == "migrate":
        print("applied:", ", ".join(migrate(conn)) or "nothing new")
    elif cmd == "seed":
        migrate(conn)
        seed(conn)
        print("seeded demo data")
    elif cmd == "query" and rest:
        print(table(*run(conn, find_query(rest[0]).read_text())))
    elif cmd == "plan" and rest:
        for row in conn.execute("EXPLAIN QUERY PLAN " + find_query(rest[0]).read_text()):
            print(row[-1])
    elif cmd == "sync-site":
        sync_site()
        print("site/sql updated")
    elif cmd == "report":
        for file in sorted((ROOT / "queries").glob("*.sql")):
            print(f"\n== {file.stem} ==\n" + table(*run(conn, file.read_text())))
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
