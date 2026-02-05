## Mit találtunk?
- A canvas célja, hogy bizonyítsuk: az anon szerepkör nem férhet hozzá az RPC-hez és a bónuszhoz kapcsolódó táblákhoz, és az authenticated csak a `user_events.read_at`-ot frissítheti.
- A korábbi script `SET ROLE`/`PERFORM` használatával a szerepköröktől és az explicit privilege-ektől függött; ezt most `has_*_privilege`-al és `SET LOCAL search_path`-szel cseréljük le.

## Mit módosítottunk?
- Az SQL check immár `BEGIN; ... ROLLBACK;` blokkon belül kezdi a vizsgálatot, a `SET LOCAL search_path TO pg_catalog, public, auth;` után csak `has_function_privilege`/`has_table_privilege`/`has_column_privilege` hívásokat használ, és elkerüli a `SET ROLE`-t.
- Ellenőrizzük, hogy az `anon` nem rendelkezik `EXECUTE` joggal a `public.grant_signup_bonus_if_eligible()`-re, valamint nincs DML joga az `reward_grants`, `user_stats` és `user_events` táblákban.
- Az `authenticated` szerepkör esetében a `public.user_events` csak SELECT joggal bír, az INSERT/DELETE tiltott, és csak a `read_at` oszlopra van UPDATE jog, míg a `type/code/amount/payload` tiltott.

## Módosított/létrehozott fájlok
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` – FAIL (az aktuális Supabase projektben az `anon` már rendelkezik EXECUTE joggal a függvényre, ezért a script a `has_function_privilege('anon', ..., 'EXECUTE')` ellenőrzésnél hibát dob).

## Következő lépések javasolt
1. Visszavonni az `anon`-ra vonatkozó EXECUTE javakat a `public.grant_signup_bonus_if_eligible()` függvényből, vagy módosítani a migrációt, hogy ezt egyértelműen tiltsa.
2. Automatizálni ezt a checket CI/db-gate részeként, hogy ez a bottleneck mindig zöld legyen, miután a jogosultságok a kívánt állapotban vannak.
