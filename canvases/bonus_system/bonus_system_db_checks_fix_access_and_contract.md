# Bonus system – DB checks javítás: negatív access + user_events contract

🎯 Funkció
- Javítsuk a `bonus_system_rpc_signup_bonus_negative_access_checks.sql` hibáit és tegyük hordozhatóvá:
  - ne legyen top-level `PERFORM`
  - ne használjon `SET LOCAL ROLE`-t
  - privilege-eket kizárólag `has_*_privilege` függvényekkel bizonyítson
  - ellenőrizze: anon EXECUTE tiltás + anon DML tiltások + authenticated user_events szerződés (SELECT ok, INSERT/DELETE tiltva, UPDATE csak read_at)

- Javítsuk a `bonus_system_user_events_db_contract_checks.sql` hiányosságait:
  - authenticated INSERT/DELETE tiltás ellenőrzése
  - authenticated UPDATE tiltások explicit ellenőrzése (type/code/amount/payload)
  - index sanity (user_id + created_at) robusztusabban

- Frissítsük a hozzájuk tartozó checklist + report fájlokat úgy, hogy 1:1-ben egyezzenek a valós checkekkel.

🧠 Fejlesztési részletek
- Érintett SQL fájlok:
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
  - `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`

- Kötelező forma:
  - `BEGIN;`
  - `SET LOCAL search_path TO pg_catalog, public, auth;`
  - `DO $$ ... $$;` (itt mehet a PL/pgSQL `PERFORM`, változók, exception)
  - `ROLLBACK;`
  - Hibánál: `RAISE EXCEPTION`.

- Negatív access checks: ne függjön role membershiptől.
  - `has_function_privilege('anon', 'public.grant_signup_bonus_if_eligible()', 'EXECUTE') = false`
  - anon táblák: reward_grants/user_stats/user_events -> INSERT/UPDATE/DELETE mind false
  - authenticated user_events:
    - table: SELECT true, INSERT false, DELETE false
    - column UPDATE: read_at true, type/code/amount/payload false

- user_events contract checks:
  - oszlopok + típusok (minimum) + RLS
  - grants/column update szerződés (ugyanaz, mint fent)
  - index sanity: legyen olyan index, amely tartalmazza `user_id` és `created_at` oszlopokat (pg_index + pg_attribute alapján)

- Checklist + report javítás:
  - `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
  - `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
  - `codex/codex_checklist/bonus_system/bonus_system_user_events_db_contract_checks.md`
  - `codex/reports/bonus_system/bonus_system_user_events_db_contract_checks.md`
  - A reportokba kerüljön be a tényleges futtatási parancs + PASS.

🧪 Tesztállapot
- Kötelező futtatás psql-lel mindkét fájlra:
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- Mindkettő PASS legyen, és kerüljön be a reportokba.

🌍 Lokalizáció
- Nincs.

📎 Kapcsolódások
- Érintett/új fájlok:
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
  - `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
  - `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
  - `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
  - `codex/codex_checklist/bonus_system/bonus_system_user_events_db_contract_checks.md`
  - `codex/reports/bonus_system/bonus_system_user_events_db_contract_checks.md`
