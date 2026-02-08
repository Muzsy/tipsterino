#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v supabase >/dev/null 2>&1; then
  echo "ERROR: supabase CLI not found in PATH"
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "ERROR: psql not found (install postgresql-client)"
  exit 1
fi

if [ ! -d "supabase/sql_checks" ]; then
  echo "ERROR: supabase/sql_checks directory not found"
  exit 1
fi

# Ensure local stack is running
if ! supabase status >/dev/null 2>&1; then
  echo "ERROR: supabase status failed. Is local stack running? Run: supabase start"
  exit 1
fi

# Best-effort DB URL discovery
DB_URL=""

# Try JSON output if available
if supabase status --output json >/dev/null 2>&1; then
  # Avoid SIGPIPE with pipefail by parsing from a stored JSON snapshot.
  STATUS_JSON="$(supabase status --output json || true)"
  DB_URL="$(python3 -c 'import json,sys
try:
    data=json.loads(sys.stdin.read() or "{}")
except Exception:
    print("")
    raise SystemExit(0)
for k in ["DB_URL","db_url","database_url","DATABASE_URL"]:
    v=data.get(k)
    if isinstance(v,str) and v.strip():
        print(v.strip())
        raise SystemExit(0)
print("")
' <<< "$STATUS_JSON")"
fi

# Fallback: parse text output
if [ -z "$DB_URL" ]; then
  LINE="$(supabase status 2>/dev/null | grep -E 'DB URL:' | head -n 1 || true)"
  if [ -n "$LINE" ]; then
    DB_URL="${LINE#*DB URL: }"
  fi
fi

# Final fallback (default supabase local port)
if [ -z "$DB_URL" ]; then
  DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
fi

export DATABASE_URL="$DB_URL"

shopt -s nullglob
SQL_FILES=(supabase/sql_checks/*.sql)
if [ "${#SQL_FILES[@]}" -eq 0 ]; then
  echo "ERROR: no SQL check files found in supabase/sql_checks/*.sql"
  exit 1
fi

echo "Using DATABASE_URL=$DATABASE_URL"
for f in "${SQL_FILES[@]}"; do
  echo "Running SQL check: $f"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done

echo "DB contract checks: PASS"
