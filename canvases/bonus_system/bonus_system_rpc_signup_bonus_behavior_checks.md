# Bonus system – RPC signup bonus behavior checks (DB)

**TASK_SLUG:** `bonus_system_rpc_signup_bonus_behavior_checks`

---

## 🎯 Funkció

Készüljön el **DB-szintű viselkedés-ellenőrzés** a `public.grant_signup_bonus_if_eligible()` RPC-hez.

A cél nem csak “létezik a függvény”, hanem hogy ténylegesen:

1) **not_authenticated**: JWT sub nélkül → `granted=false`, reason=`not_authenticated`, és **nincs** DB-mellékhatás.
2) **not_verified**: nem verifikált user → `granted=false`, reason=`not_verified`, és **nincs** reward_grants/user_stats/user_events beszúrás.
3) **granted**: verifikált user + enabled reward_definitions →
   - `granted=true`, reason=`granted`, amount > 0
   - beszúr `reward_grants` (1 db)
   - `user_stats.tippcoins` nő az amounttal
   - beszúr `user_events` (1 db, type=`tippcoin_credit`, code=`signup_bonus`)
4) **idempotencia**: második hívás → `granted=false`, reason=`already_granted`, és
   - nincs új `reward_grants`
   - nincs új `user_events`
   - `user_stats.tippcoins` nem nő tovább

Minden ellenőrzés **tranzakcióban** fusson és **ROLLBACK** legyen a végén, hogy ne maradjon szemét adat.

---

## 🧠 Fejlesztési részletek

### Érintett meglévő fájlok

- Migráció: `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- Létező schema/RPC checks:
  - `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`

### Új SQL behavior checks fájl

- Új fájl: `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`

Elvárások:

- `BEGIN; ... ROLLBACK;`
- Egy `DO $$ ... $$;` blokkban:
  - állítsd be ideiglenesen a `reward_definitions` rekordot determinisztikusra (pl. amount=100, enabled=true) **csak a tranzakción belül**
  - generálj egy teszt user_id-t és hozz létre hozzá **auth.users** sort úgy, hogy az FK-k miatt a grant útvonal tudjon insertelni
    - a beszúrás legyen “robosztus”: legalább az `id`, `email` és a tipikus kötelező mezők kezelése
    - email legyen egyedi (uuid alapján)
  - “not_verified” állapothoz legyen biztosan null a verifikációs timestamp
  - “verified” állapothoz állíts be `email_confirmed_at`-ot (ha nincs, akkor `confirmed_at`-ot)

### JWT claim szimuláció

A `auth.uid()` a `request.jwt.claim.sub` beállítást használja. A DO blockon belül:

- not_authenticated: sub nincs beállítva
- not_verified/granted/idempotens: `set_config('request.jwt.claim.sub', '<uuid>', true)`

A függvény SECURITY DEFINER, de a viselkedést a `auth.uid()` és a `auth.users` sor fogja meghatározni.

---

## 🧪 Tesztállapot

Kötelező futtatás (lokál / remote DB):

- `.env.local` (nem committed) tartalmazza:
  - `DATABASE_URL=...`
- Parancs:
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`

Opcionálisan készülhet egy wrapper script, de nem kötelező.

---

## 🌍 Lokalizáció

Nincs.

---

## 📎 Kapcsolódások

Új / érintett fájlok:

- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_behavior_checks.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_behavior_checks.md`
