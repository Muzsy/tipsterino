# Bonus system daily bonus RPC grant_daily_bonus_if_eligible checklist

## P1 – Canvas + terv
- [x] A canvas preflight rögzítette a grant_day/index/reward definition/profiles/sign-up RPC mintákat és a privilege contractot, így a napi RPC ugyanazokat a gate-eket követi.

## P2 – Implementációs blokkok
- [x] A `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql` migráció létrehozza az `grant_daily_bonus_if_eligible()` függvényt (gate-ek, idempotencia, next_eligible_at, user_stats/user_events) és a privilege REVOKE/GRANT-okat.
- [x] A `supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql` ellenőrzi az RPC létezését, security definert és az authenticated EXECUTE jogot.
- [x] A `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql` validálja a not_authenticated/not_verified/profile_incomplete/disabled/granted/already_claimed_today ágakat, a grant_day értéket, `user_stats` és `user_events` mellékhatásokat.
- [x] A `supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql` bizonyítja, hogy az `anon` nem hívhatja az RPC-t, és nincs DML joga, az `authenticated` pedig csak `user_events.read_at` UPDATE-joggal rendelkezik.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (a `20260210000000_bonus_system_rpc_daily_bonus.sql` migráció lefutott, a funkció frissül).
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- [x] `./scripts/check.sh` – PASS (analyze + widget/unit tesztek hibátlanul futottak).
