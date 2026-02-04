## Mit találtunk?
- A `auth.users` táblában mind `email_confirmed_at`, mind `confirmed_at` oszlop megtalálható, ezért a helper `COALESCE(email_confirmed_at, confirmed_at)` logikát használja; a reportban dokumentáltuk, hogy az email verified ellenőrzés alapvetően az `email_confirmed_at` értékén alapul, a `confirmed_at` pedig az esetleges mobil/telefon validációt is lefedi.
- A `reward_grants_user_id_code_unique` index adja az idempotencia alapját, ezért az RPC csak a `RETURNING id` alapján folytatja a `user_stats`/`user_events` írását, és az `already_granted` reason explicit visszatér.

## Mit módosítottunk?
- Kiegészítettük a canvas dokumentációt az email verification mezők, index és conflict logika részleteivel.
- Létrehoztuk a `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql` migrációt: helper `is_email_verified`, `grant_signup_bonus_if_eligible` szerződés, search_path beállítás, `reward_grants` on conflict + `user_stats`/`user_events` frissítések, valamint a `grant execute` az authenticated szerepkörre.
- Elkészítettük a `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` fájlt, amely egymás után ellenőrzi a függvények létezését, hogy a RPC `SECURITY DEFINER`, és hogy az `authenticated` végrehajtási joga megvan.

## Módosított/létrehozott fájlok
- `canvases/bonus_system/bonus_system_rpc_signup_bonus.md`
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus.md`

## Tesztek
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (a CLI NOTICE a frissítésről nem befolyásolta a migráció végrehajtását).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS (a script megerősítette a helper és RPC meglétét, a security definer állapotot és az `authenticated` EXECUTE jogot).
- `./scripts/check.sh` – PASS (repo standard gate – analyze + widget tesztek).

## Következő javasolt lépések
1. A `grant_signup_bonus_if_eligible` RPC-t a post-auth init logikába illeszteni (edge function / trigger) és ellenőrizni a hívás `user_events` logikáját.
2. A `reason` mező és a `user_events.payload` extra mezői alapján az app oldalon a logolást/telemetriát részletesen dokumentálni.
3. Ha szükséges, a `signup_bonus` végleges összegét új migrációval frissíteni az üzleti döntés szerint.
