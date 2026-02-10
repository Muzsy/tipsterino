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
   This is intentional: contract checks run seedless for deterministic results, and
   the repository seed file is a no-op placeholder by policy. See: `docs/qa/seed_policy.md`.
3. Run the SQL checks:
   ```bash
   ./scripts/check_db.sh
   ```
   The script will verify that the stack is running, discover the `DATABASE_URL`, and execute every `supabase/sql_checks/*.sql` file.
   Retention contract coverage includes:
   - `supabase/sql_checks/bonus_system_rpc_rate_limit_retention_checks.sql`
     (cleanup function presence, security-definer hardening, execute privileges, smoke invocation).
   Important cross-user RLS contract coverage includes:
   - `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql`
     (authenticated user1 must not read/update user2 rows in `profiles`, `reward_grants`, `user_stats`, `user_events`).
4. On error, inspect `supabase start` logs, verify the port (`54322`) is listening, and ensure Supabase CLI + `psql` are installed.

## Rate-limit retention operation note
- DB retention helper:
  - `public.cleanup_bonus_rpc_rate_limit_state(interval, integer)`
- Manual fallback run (admin/scheduler context):
  ```sql
  select public.cleanup_bonus_rpc_rate_limit_state(interval '7 days', 10000);
  ```
- Scheduler recommendation: run periodically (e.g. every hour) with conservative
  retention to avoid unbounded `rpc_rate_limit_state` growth.

## CI behaviour
- Workflow: `.github/workflows/ci_db.yml` triggers on `pull_request`, `push`, and `workflow_dispatch`.
- Runner: `ubuntu-24.04`, with pinned toolchain setup and `postgresql-client` installed.
- Pinned versions:
  - `actions/checkout@v4.2.2`
  - `subosito/flutter-action@v2.21.0` + `flutter-version: 3.38.7`
  - `supabase/setup-cli@v1.6.0` + `version: 2.65.5`
- Steps: checkout → install Supabase CLI → install `psql` → `supabase start` → `supabase db reset --local --no-seed` → `./scripts/check_db.sh`.
- On failure, the job stops and surfaces the relevant error (missing CLI, DB port, or SQL errors).

### CI pin matrix (canonical)
| Workflow | Runner pin | Flutter action pin | Supabase action pin | Toolchain pin |
| -------- | ---------- | ------------------ | ------------------- | ------------- |
| `ci.yml` | `ubuntu-24.04` | `subosito/flutter-action@v2.21.0` | n/a | `flutter-version: 3.38.7` |
| `ci_db.yml` | `ubuntu-24.04` | `subosito/flutter-action@v2.21.0` | `supabase/setup-cli@v1.6.0` | `flutter-version: 3.38.7`, `supabase-cli: 2.65.5` |

### Upgrade policy (CI pins)
- Never use floating `latest` for CI runners or toolchains (`Flutter`, `Supabase CLI`) and avoid major-only action tags.
- Upgrade pins in a dedicated PR by:
  1. changing workflow version pins,
  2. running local gate: `./scripts/check.sh` and `./scripts/check_db.sh`,
  3. running report gate: `./scripts/verify.sh --report codex/reports/<area>/<task>.md`.
- Keep upgrades small and explicit (single-version bump per tool when possible) so rollback stays low-risk.

## Rollback linkage
- Migration incident dontesi fa es rollback runbook:
  - `docs/qa/migration_rollback_strategy.md`
- Local rollback utan kotelezo verifikacio:
  - `./scripts/check_db.sh`
  - `./scripts/verify.sh --report codex/reports/<area>/<task>.md`

## Troubleshooting
- `supabase: command not found`: install Supabase CLI (`npm install -g supabase` or follow https://supabase.com/docs/guides/cli).
- `psql: command not found`: install `postgresql-client` (e.g., `sudo apt-get install -y postgresql-client`).
- `supabase status failed`: make sure the local stack is running, check `supabase start` logs, restart stack.
- `no SQL check files found`: add `.sql` files under `supabase/sql_checks/` before running the script.
