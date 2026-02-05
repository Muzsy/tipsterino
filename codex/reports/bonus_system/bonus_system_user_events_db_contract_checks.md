## Mit találtunk?
- A `user_events` contract a tárolt eseményeket, RLS-t és privilege-okat foglalja össze; fontos, hogy az auth only read/update hagyományokat tartsa.
- Bizonyítanunk kellett, hogy a táblát RLS védi, csak read_at frissíthető, és hogy van index a user_id + created_at lekérésekhez.

## Mit módosítottunk?
- Írtunk egy `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` fájlt, amely `BEGIN; ... ROLLBACK;` blokkon belül ellenőrzi az oszlopokat/típusokat, RLS-t, privileges-eket (SELECT/INSERT/DELETE, valamint oszlopszintű UPDATE) és az indexet.
- Az oszlopellenőrzés a `information_schema.columns` adatokat használja, a RLS a `pg_class.relrowsecurity` mezőt olvassa, a privilege-ek `has_table_privilege`/`has_column_privilege` alapján kerülnek validálásra, az index pedig `pg_indexes`-ből jön.

## Módosított/létrehozott fájlok
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_user_events_db_contract_checks.md`
- `codex/reports/bonus_system/bonus_system_user_events_db_contract_checks.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` – PASS (BEGIN/ROLLBACK, no side effects).

## Következő javasolt lépések
1. A jövőben automatizáljuk ezt a checket (pl. db gate), hogy a schema mindig megfeleljen a szerződésnek.
2. Ha új oszlopok kerülnek a `user_events`-be, frissítsük a `expected_columns` listát és a privilege-k ellenőrzését.
