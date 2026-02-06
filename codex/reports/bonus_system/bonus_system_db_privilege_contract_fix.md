## Mit találtunk?
- A canvas címe, hogy az RPC-t csak authenticated hívhatja, a `public.user_events` pedig csak SELECT + `read_at` UPDATE joggal bírhat, de a valós környezetben még maradtak szélesebben kiosztott jogok (anon EXECUTE + authenticated INSERT/DELETE/UPDATE).
- Az SQL checkek csak oszlopszinten ellenőrizték a `read_at` UPDATE jogot, így egy table-level UPDATE joggal a szerződés megkerülhető volt.

## Mit módosítottunk?
- Létrehoztuk a `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql` migrációt, amely a `grant_signup_bonus_if_eligible()`-t minden szerepkörből revoke-olja és csak az authenticatednek engedélyezi az EXECUTE-ot; a `public.user_events`, `reward_grants` és `user_stats` táblákon explicit REVOKE/GRA NT utasításokkal visszaadtuk a szigorú privilege szerződést.
- A meglévő SQL checkek mostantól explicit módon ellenőrzik, hogy az `authenticated` nem rendelkezik table-level UPDATE joggal a `public.user_events` táblán, így a column-level `read_at` UPDATE szerződés nem kerülhető meg.
- A migráció lefutása után kézzel újrafuttattuk ugyanazokat az REVOKE/GRA NT utasításokat a távoli adatbázison, hogy az `anon` EXECUTE jogát is eltávolítsuk (a migration frissítése után nem futott újra automatikusan).

## Módosított/létrehozott fájlok
- `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_db_privilege_contract_fix.md`
- `codex/reports/bonus_system/bonus_system_db_privilege_contract_fix.md`

## Tesztek
- `set -a; source .env.local; set +a; supabase db push` – PASS (a `20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql` és a `20260206000000_bonus_system_privilege_contract_fix.sql` migrációk lefutottak a távoli adatbázison).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` – PASS.

## Következő lépések javasolt
1. Automatikusan futtassuk ezt a privilege contract check+migration kombót a CI/db gate során, hogy a jogosultságok mindig hozzászóllás nélkül legyenek.
2. Ha új privilege-ek keletkeznek (pl. új RPC-ek), a migrationt bővítsük további REVOKE/GRANT utasításokkal.
