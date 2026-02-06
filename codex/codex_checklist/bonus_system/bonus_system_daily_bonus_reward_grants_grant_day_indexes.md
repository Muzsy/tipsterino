# Bonus system daily bonus reward_grants grant_day + indexes checklist

## P1 – Canvas + terv
- [x] Canvas segít azonosítani a korrekt migrációt (grant_day, partial indexek, RPC kompatibilitás) és a kapcsolódó SQL checks / doc célokat.

## P2 – Implementációs blokkok
- [x] Új migration készül a `supabase/migrations/` alatt, amely hozzáadja a `grant_day` oszlopot, partial unique indexeket és frissíti a `grant_signup_bonus_if_eligible()` függvényt.
- [x] A `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` a `grant_day` oszlopot és az új partial unique indexeket ellenőrzi, miközben a listázó index továbbra is megvan.
- [x] A `docs/data_model/reward_grants_table_doc.md` dokumentálja a `grant_day` mezőt és a `signup_bonus`/`daily_bonus` egyediség szisztémáját.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – a `20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql` migráció lefutott, a `reward_grants_user_created_at_idx` index már létezett, így egy NOTICE jelzés volt.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- [x] `./scripts/check.sh` – PASS (a `app/test/widget/*.dart` és `app/test/unit/bonus_system_post_auth_init_test.dart` sorozatok hibátlanul futottak).
