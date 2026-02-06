## Mit találtunk?
- Hiányzott a napi bónuszhoz kapcsolódó RPC, így a grant pipeline nem volt szerveroldali idempotens pontként elérhető, és a hozzá tartozó privilege contract nem volt megerősítve.
- A negatív access, viselkedési és séma ellenőrzések csak a signup bónuszra voltak megírva; a napi funkcionalitást nem guarded.

## Mit módosítottunk?
- A `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql` migráció létrehozza az `grant_daily_bonus_if_eligible()` függvényt (gate-ek, disabled/disabled reason, idempotencia, next_eligible_at, reward_grants grant_day, user_stats/user_events mellékhatások) és a privilege REVOKE/GRANT utasításokat az `authenticated` szerepkörre.
- Új SQL checkek jelentek meg: `supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`, `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql` és `supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`, amelyek a függvény létezését, security definert, gating logikát, mellékhatásokat és privilege-kontraktot ellenőrzik.
- A megfelelő regressziós ellenőrzéseket (signup RPC checks) is lefuttattuk a reportban felsorolt parancsok között.

## Tesztek
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (a `20260210000000_bonus_system_rpc_daily_bonus.sql` migráció alkalmazva lett, az új RPC definiálva).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- `./scripts/check.sh` – PASS (analyze + widget/unit tesztek, beleértve az `app/test/unit/bonus_system_post_auth_init_test.dart` sorozatot, hibátlanul futtak).

## Következő lépések javasolt
1. Az új RPC köré épülő kliens logika (UI/GRPC/Edge Function) egy következő taskban hivatkozzon a most létrehozott dokumentációra és ellenőrzésekre.
2. Ha a reward definition amount-ja vagy gate-je változik, frissítsük a `bonus_system_rpc_daily_bonus_behavior_checks.sql` fájlt, hogy a disabled/amount logikát is lefedje.
