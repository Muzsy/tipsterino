# Bonus system – DB privilege contract fix (RPC + user_events) + SQL checks megerősítés

🎯 Funkció
- Tegyük valósággá a privilege szerződést, hogy a meglévő SQL checkek PASS-oljanak és a rendszer tényleg biztonságos legyen:
  1) `public.grant_signup_bonus_if_eligible()` ne legyen futtatható `anon`/PUBLIC számára.
  2) `public.user_events` táblán `authenticated` ne tudjon INSERT/DELETE/UPDATE-t table szinten.
     - `authenticated` csak SELECT + UPDATE(read_at) jogosultságot kapjon.
  3) Megerősítjük a SQL checkeket: explicit ellenőrizzük, hogy `authenticated`-nek NINCS table-level UPDATE joga `user_events`-en (különben oszlopszint megkerülhető).

🧠 Fejlesztési részletek
- Új migráció: DB grant contract fix (explicit REVOKE + GRANT):
  - `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`
- Módosítandó SQL checks:
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
  - `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`

Migráció követelmények:
- RPC:
  - `REVOKE ALL ON FUNCTION public.grant_signup_bonus_if_eligible() FROM PUBLIC;`
  - `GRANT EXECUTE ON FUNCTION public.grant_signup_bonus_if_eligible() TO authenticated;`
- user_events:
  - `REVOKE ALL ON TABLE public.user_events FROM PUBLIC;`
  - `REVOKE ALL ON TABLE public.user_events FROM anon;`
  - `REVOKE ALL ON TABLE public.user_events FROM authenticated;`
  - `GRANT SELECT ON TABLE public.user_events TO authenticated;`
  - `GRANT UPDATE (read_at) ON TABLE public.user_events TO authenticated;`
- (Opcionális, de ajánlott) reward_grants + user_stats read-only a kliensnek:
  - `REVOKE ALL ... FROM PUBLIC/anon/authenticated;`
  - `GRANT SELECT ... TO authenticated;`

SQL checks bővítés:
- Mindkét checkben legyen explicit assert:
  - `has_table_privilege('authenticated','public.user_events','UPDATE') = false`
- Negatív access checkben bővítsd anon DML tiltást UPDATE-re is (már van, de ellenőrizd teljességet).

🧪 Tesztállapot
- DB gate:
  - migrációk futtatása a projekt szokásos Supabase flow-ja szerint
  - utána futtasd psql-lel mindkét SQL checks fájlt:
    - `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
    - `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- Reportokban szerepeljen: parancsok + PASS.

🌍 Lokalizáció
- Nincs.

📎 Kapcsolódások
- Új/érintett fájlok:
  - `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
  - `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
  - `codex/codex_checklist/bonus_system/bonus_system_db_privilege_contract_fix.md`
  - `codex/reports/bonus_system/bonus_system_db_privilege_contract_fix.md`
