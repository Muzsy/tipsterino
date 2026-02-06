# Bonus system daily bonus reward definition migration + docs patch checklist

## P1 – Canvas + terv
- [x] Az canvas tisztázta az érintett fájlokat, a `supabase/migrations` timestamp konvenciót és a doc pontatlanságokat.

## P2 – Implementációs blokkok
- [x] Új migráció készült (`supabase/migrations/20260209000000_bonus_system_daily_bonus_reward_definition.sql`), amely determinisztikusan seedeli a `daily_bonus` definitiont (INSERT ... ON CONFLICT UPDATE).
- [x] A `documents/bonus_system/daily_bonus.md` tartalmazza a rögzített napi limitet (`grant_day DATE`, `CHECK` és partial unique index) és a tiszta UI állapotleírást (`available`/`claimed`/`offline` a `next_eligible_at` alapján).
- [x] A `docs/data_model/reward_grants_table_doc.md` dokumentálja a `grant_day` képletét `(now() AT TIME ZONE 'UTC')::date` és a `daily_bonus` partial unique index szerződését.
- [x] A `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` mostantól ellenőrzi a `daily_bonus` definíciót is.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- [x] `./scripts/check.sh` – PASS (analyze + widget/unit tesztek).
