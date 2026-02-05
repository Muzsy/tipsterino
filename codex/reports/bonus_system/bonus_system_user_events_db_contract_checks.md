## Mit találtunk?
- A canvas szerint a `public.user_events` táblának egyértelmű schema/privilege/index szerződése van: konkrét oszlopok, RLS, authenticated privilege tiltások és az `user_id + created_at` index.
- A korábbi check nem használta ki a `pg_index` + `pg_class` + `pg_attribute` hármasát, és nem ellenőrizte explicit módon minden oszlop/típus párost.

## Mit módosítottunk?
- Megírtunk egy `SET LOCAL search_path TO pg_catalog, public, auth;`-t követő `DO $$ ... $$` blokkot, ami sorban ellenőrzi az `id`, `user_id`, `type`, `code`, `amount`, `payload`, `created_at` és `read_at` oszlopokat az `information_schema.columns` alapján (a repóban szereplő típusokra szűrve).
- A script `pg_class.relrowsecurity` lekérdezéssel biztosítja, hogy RLS be van kapcsolva, és `has_table_privilege`/`has_column_privilege` hívásokkal igazolja, hogy az authenticated csak SELECT joggal bír, de INSERT/DELETE tiltott, valamint csak `read_at` UPDATE-je engedélyezett.
- Az index-check a `pg_index` + `pg_class` + `pg_attribute` joinnal azt igazolja, hogy legalább egy index tartalmazza a `user_id` és `created_at` oszlopokat; ennek hiányában a script `RAISE EXCEPTION`-t dob.

## Módosított/létrehozott fájlok
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_user_events_db_contract_checks.md`
- `codex/reports/bonus_system/bonus_system_user_events_db_contract_checks.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` – FAIL (az aktuális környezetben az authenticated rendelkezik INSERT joggal a `public.user_events` táblán, így a script a `has_table_privilege('authenticated', ..., 'INSERT')` ágban hibát dob).

## Következő lépések javasolt
1. Töröljük vagy tiltsuk az authenticated INSERT/DELETE jogosultságát a `public.user_events` táblán, hogy a contract check zöld maradjon.
2. Érdemes lenne ezt az ellenőrzést CI/db gate részeként integrálni, és a hibát automatikusan jelezni a privilege változások után.
