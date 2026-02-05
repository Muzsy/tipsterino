## Mit találtunk?
- A canvas célja, hogy bizonyítsuk: az RPC-t csak authentikált felhasználó hívhatja, és az anon szerepkör ne férjen hozzá a bónusz-táblákhoz sem.
- Fontos, hogy az authenticated user_events UPDATE csak a `read_at`-ra vonatkozik, más oszlopokra nincs jog.

## Mit módosítottunk?
- Írtunk egy SQL checket (`supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`), amely `BEGIN; ... ROLLBACK;` alatt SET LOCAL ROLE anon/ authenticated beállításokkal futtatja a privilege ellenőrzéseket.
- Ellenőrizzük, hogy anon szerepkör nem tud EXECUTE-ot hívni az RPC-t, valamint nincs INSERT privilege a reward_grants/user_stats/user_events táblákon.
- Az authenticated role esetén `has_column_privilege`-szal biztosítjuk, hogy csak a `read_at` oszlop frissíthető, az `amount/type/code` oszlopokra nincs UPDATE jog.

## Módosított/létrehozott fájlok
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` – PASS (BEGIN/ROLLBACK, no modifications).

## Következő lépések javasolt
1. Ha a szerepkörök új privilege-okat kapnak, frissítsük a scriptet, hogy további oszlop/ táblajogokat ellenőrizzen.
2. Automatizáljuk a checks futtatását például db gate részeként vagy CI pipeline-ban.
