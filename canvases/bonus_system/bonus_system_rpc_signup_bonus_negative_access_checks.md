# Bonus system – RPC signup bonus: negatív hozzáférési ellenőrzések (anon/privilegiumok)

**TASK_SLUG:** `bonus_system_rpc_signup_bonus_negative_access_checks`

---

## 🎯 Funkció

Bizonyítsuk DB-szinten, hogy a `public.grant_signup_bonus_if_eligible()` **nem futtatható anon** szerepkörből, és hogy a bónusz-logika nem megkerülhető közvetlen táblaműveletekkel anon/authenticated szerepkörből.

Minimum:

1) `anon` role: `EXECUTE` tiltás a `public.grant_signup_bonus_if_eligible()` RPC-re (permission denied).
2) `anon` role: nincs közvetlen `INSERT/UPDATE` jog:
   - `public.reward_grants`
   - `public.user_stats`
   - `public.user_events`
3) `authenticated` role: `public.user_events` UPDATE jog **csak** `read_at` oszlopra van (oszlopszintű GRANT), más oszlopokra nincs.

---

## 🧠 Fejlesztési részletek

### Új SQL checks fájl

- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`

Követelmények:
- `BEGIN; ... ROLLBACK;` (bár itt nem írunk, egységes forma)
- a `postgres`/admin kapcsolatból `SET LOCAL ROLE anon;` és `SET LOCAL ROLE authenticated;` módszerrel ellenőrizzünk privilege-eket
- ahol várhatóan permission denied jön, ott `DO $$ BEGIN ... EXCEPTION WHEN insufficient_privilege THEN ... END $$;` mintával fogjuk el és **ha nem dob**, akkor `RAISE EXCEPTION`

Fontos: itt nem a JWT sub szimuláció a lényeg, hanem az adatbázis privilege.

---

## 🧪 Tesztállapot

Kötelező futtatás:

`set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`

---

## 🌍 Lokalizáció

Nincs.

---

## 📎 Kapcsolódások

- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md`
