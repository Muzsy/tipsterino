## Mit találtunk?
- A canvas célja, hogy az RPC-t csak authenticated hívhassa meg, a `public.user_events` pedig kizárólag SELECT + `read_at` UPDATE joggal rendelkezzen, de a környezetben még szélesebb privilege-ok maradtak (anon EXECUTE, authenticated INSERT/DELETE/UPDATE).
- A korábbi SQL checkek oszlopszinten vizsgálták a `read_at` UPDATE jogot, így egy table-level `UPDATE` engedély megkerülhette a szerződést.

## Mit módosítottunk?
- Létrehoztuk a `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql` migrációt, amely a `grant_signup_bonus_if_eligible()`-t minden szerepkörből revoke-olja és csak az authenticatednek engedélyezi az EXECUTE-ot, a `user_events`, `reward_grants` és `user_stats` táblákon pedig explicit REVOKE/GRANT utasításokkal gurítja vissza a szigorú privilege szerződést.
- A SQL checkek immár table-level `UPDATE` tiltást is ellenőriznek (`has_table_privilege('authenticated', 'public.user_events', 'UPDATE') = false`), így nincs esély a column-level `read_at` szerződés kijátszására.
- Hozzáadtunk egy `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql` migrációt, amely ugyanazokat a REVOKE/GRANT utasításokat futtatja új timestamptel, így a `supabase db push` automatikusan újra érvényesíti a privilege contractot.
- A reapply migráció lefuttatása után már nem kell kézzel futtatni a REVOKE/GRANT blokkokat, mert minden Supabase push ezeket újra végrehajtja.

## Módosított/létrehozott fájlok
- `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`
- `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_db_privilege_contract_fix.md`
- `codex/reports/bonus_system/bonus_system_db_privilege_contract_fix.md`

## Tesztek
- `set -a; source .env.local; set +a; supabase db push` – PASS (a `20260207000000_bonus_system_privilege_contract_reapply.sql` migráció is lefutott, így a remote adatbázisban a kívánt privilege-állapot mindig alkalmazva van).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` – PASS.
- `./scripts/check.sh` – PASS.

## Következő lépések javasolt
1. Érdemes ezt a privilege contract checket és a reapply migrációt CI/db-gate-ba integrálni, hogy bármilyen új grant/revoke változás automatikusan ellenőrzésre kerüljön.
2. Ha új privilege-ek jelennek meg (pl. új RPC-ek), bővítsük a migrációkat további REVOKE/GRANT utasításokkal, hogy a contract változatlan legyen.
