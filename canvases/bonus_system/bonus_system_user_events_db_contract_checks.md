# Bonus system – user_events DB contract checks (schema + indexes + grants)

**TASK_SLUG:** `bonus_system_user_events_db_contract_checks`

---

## 🎯 Funkció

DB-szinten ellenőrizzük, hogy a `public.user_events` tábla megfelel a szerződésnek:

1) Oszlopok és típusok (min):
   - id (uuid)
   - user_id (uuid)
   - type (text)
   - code (text vagy nullable, ami a doksiban rögzítve van)
   - amount (integer/bigint nullable)
   - payload (jsonb)
   - created_at (timestamptz)
   - read_at (timestamptz nullable)

2) RLS enabled.

3) Privilege szerződés:
   - authenticated: SELECT saját sorokra policy-n keresztül (legalább table privilege megvan)
   - authenticated: UPDATE csak read_at oszlopra (oszlopszintű GRANT)
   - authenticated: INSERT/DELETE tiltva

4) Index sanity:
   - legyen értelmes index a listázáshoz (user_id + created_at), hogy a `/events` query ne full scan legyen.

---

## 🧠 Fejlesztési részletek

### Új SQL checks fájl

- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`

Követelmények:
- `BEGIN; ... ROLLBACK;`
- `information_schema.columns` + `pg_type/pg_attribute` alapján ellenőrizd a típusokat
- `pg_class.relrowsecurity` alapján RLS ellenőrzés
- `has_table_privilege` + `has_column_privilege` a grants-hez
- index ellenőrzés: `pg_indexes` és/vagy `pg_index` alapján keress `user_id` + `created_at` együtt szereplő indexet
  - ha több index van, elég, ha legalább egy megfelel

---

## 🧪 Tesztállapot

Kötelező:

`set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`

---

## 🌍 Lokalizáció

Nincs.

---

## 📎 Kapcsolódások

- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_user_events_db_contract_checks.md`
- `codex/reports/bonus_system/bonus_system_user_events_db_contract_checks.md`
