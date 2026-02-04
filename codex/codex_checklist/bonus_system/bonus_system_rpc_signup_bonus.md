# Bonus system RPC signup bonus checklist

## P1 – Canvas + helper
- [x] A `canvases/bonus_system/bonus_system_rpc_signup_bonus.md` immár a `auth.users.email_confirmed_at` / `confirmed_at` mezők együttműködését említi, az index (`reward_grants_user_id_code_unique`) és a verified helper logika is szerepel.
- [x] A helper függvény (public.is_email_verified) és a fő RPC (grant_signup_bonus_if_eligible) security definer módon kerül implementálásra.

## P2 – Migráció + checks
- [x] `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql` tartalmazza a helpert, a biztonsági kontextust, a `reward_grants` on conflict logikát, a `user_stats`/`user_events` frissítést és a `grant execute`-ot.
- [x] `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` ellenőrzi a függvények meglétét, a security definer beállítást és az `authenticated` EXECUTE jogot.

## P3 – QA gate
- [x] `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` futott.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` futott.
- [x] `./scripts/check.sh` lefutott a repo standard gate-jével.
