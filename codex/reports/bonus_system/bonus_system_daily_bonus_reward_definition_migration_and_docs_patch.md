## Mit találtunk?
- A `daily_bonus` reward definition nem volt benne az adatbázisban, így hiányzott a `reward_definitions` táblából az a sor, amelyhez a későbbi napi grantok kötődnek.
- A dokumentációban a `grant_day` képlet és a napi limit leírása nem tükrözte a már megvalósított szerződést (date típus + partial unique index), valamint a UI állapotok némi inkonzisztenciát mutattak.
- A schema/rls check nem ellenőrizte a `daily_bonus` definíció meglétét.

## Mit módosítottunk?
- Létrehoztuk a `supabase/migrations/20260209000000_bonus_system_daily_bonus_reward_definition.sql` migrációt, amely `INSERT ... ON CONFLICT UPDATE` logikával libikják a `daily_bonus` definíciót (amount=0 placeholder, enabled=true).
- A `documents/bonus_system/daily_bonus.md` részletesen leírja a napi limit szerződését (`grant_day DATE`, CHECK constraint + partial unique index) és az UI állapotokat (`available`, `claimed`, `offline` a `next_eligible_at` alapján, a read_at nem dönt).
- A `docs/data_model/reward_grants_table_doc.md` javítja a `grant_day` képletét `(now() AT TIME ZONE 'UTC')::date` formában, és rögzíti, hogy a `daily_bonus` partial unique index már él.
- A `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` mostantól ellenőrzi a `daily_bonus` definíció meglétét a `reward_definitions` táblában.

## Tesztek
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (a `20260209000000_bonus_system_daily_bonus_reward_definition.sql` migráció lefutott).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – PASS (a daily bonus és signup definíciók tesztelve).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- `./scripts/check.sh` – PASS (a standard analyze, az összes widget teszt és az `app/test/unit/bonus_system_post_auth_init_test.dart` hibátlanul futott).

## Következő lépések javasolt
1. A következő daily bonus implementáció során folyamatosan hivatkozzanak erre a migrációra és dokumentációra, hogy a `reward_definitions` szerződés mindig fennmaradjon.
2. Ha a `daily_bonus` összege vagy logikája változik, új migrációval frissítsük a definíciót és az ehhez kapcsolódó SQL checkeket.
