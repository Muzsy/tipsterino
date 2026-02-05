# Bonus system RPC signup bonus behavior checks checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_rpc_signup_bonus_behavior_checks.md` meghatározza a not_authenticated/not_verified/granted/idempotent scenáriókat és a ROLLBACK tranzakciós megközelítést.
- [x] A SQL checks fájl `BEGIN;`/`ROLLBACK;` blokkal fut, így nem hagy nyomot az adatbázisban.

## P2 – Implementációs blokkok
- [x] `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` lefedi a not_authenticated, not_verified, granted és idempotent eseteket, `set_config('request.jwt.claim.sub', ...)`-szal, kötelező `reward_definitions` előkészítéssel és user metadata beállítással.
- [x] A script ellenőrzi, hogy a not_verified esetben nincs reward_grants/user_stats/user_events, a granted esetben egy reward_grant és egy user_event jön létre, és az idempotens újrahívás nem szaporítja a rekordokat.
- [x] A script kezeli az `auth.users` vérifikációs mezőit, csak akkor próbálja megfrissíteni `confirmed_at`-ot, ha nem generált oszlop, különben az `email_confirmed_at`-ot állítja.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` lefutott.
