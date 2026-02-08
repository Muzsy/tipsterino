# DB checks guide (Supabase local + CI)

## Prerequisites
- Docker is running (Supabase local stack depends on containers).
- Supabase CLI installed and in `PATH` (`supabase --version`).
- `psql` client installed (e.g., `postgresql-client` on Ubuntu).

## Local execution
1. Start the Supabase stack:
   ```bash
   supabase start
   ```
2. Reset the local database (apply migrations without seed):
   ```bash
   supabase db reset --local --no-seed
   ```
3. Run the SQL checks:
   ```bash
   ./scripts/check_db.sh
   ```
   The script will verify that the stack is running, discover the `DATABASE_URL`, and execute every `supabase/sql_checks/*.sql` file.
4. On error, inspect `supabase start` logs, verify the port (`54322`) is listening, and ensure Supabase CLI + `psql` are installed.

## CI behaviour
- Workflow: `.github/workflows/ci_db.yml` triggers on `pull_request`, `push`, and `workflow_dispatch`.
- Runner: `ubuntu-latest`, with Supabase CLI (`supabase/setup-cli@v1`) and `postgresql-client` installed.
- Steps: checkout → install Supabase CLI → install `psql` → `supabase start` → `supabase db reset --local --no-seed` → `./scripts/check_db.sh`.
- On failure, the job stops and surfaces the relevant error (missing CLI, DB port, or SQL errors).

## Troubleshooting
- `supabase: command not found`: install Supabase CLI (`npm install -g supabase` or follow https://supabase.com/docs/guides/cli).
- `psql: command not found`: install `postgresql-client` (e.g., `sudo apt-get install -y postgresql-client`).
- `supabase status failed`: make sure the local stack is running, check `supabase start` logs, restart stack.
- `no SQL check files found`: add `.sql` files under `supabase/sql_checks/` before running the script.
