# Bonus system DB privilege contract fix checklist

## P1 – Canvas + terv
- [x] Az új canvas leírja a RPC EXECUTE és a `public.user_events` privilege szerződést, valamint a reward_grants/user_stats read-only opciót.
- [x] A terv szerint a SQL checkek table-level UPDATE jogot is vizsgálják, így az oszlopszintű `read_at` UPDATE szerződés nem megkerülhető.
- [x] A DB gate részeként a migrációk alkalmazása és a két SQL check lefuttatása is kötelező.

## P2 – Implementációs blokkok
- [x] Létrehoztuk a `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql` migrationt, amely REVOKE/GRANT utasításokkal szűkíti az RPC-t és a `public.user_events` privilege-eket, plusz opcionális read-only access-et ad a `reward_grants` és `user_stats` táblákhoz.
- [x] Mindkét SQL checkben (`supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` és `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`) explicit módon leellenőrizzük, hogy az `authenticated` nem rendelkezik table-level UPDATE joggal a `public.user_events`-en.
- [x] Az `anon` és `authenticated` privilege-okat a migrationben egyértelműen revoke-oltuk, majd a kívánt jogokat csak a szükséges szereplőknek adtuk vissza.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; supabase db push` – PASS (a 20260205000000 és 20260206000000 migrációk lefutottak a célbázison).
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` – PASS.
