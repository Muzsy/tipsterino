## Mit találtunk?
- A `reward_grants` tábla egyediségét jelenleg egyetlen `user+code` index biztosítja, így a napi `daily_bonus` idempotenciáját nem tudjuk garantálni.
- A `grant_signup_bonus_if_eligible()` függvény `ON CONFLICT (user_id, code) do nothing` feltétele nem illeszkedik partial unique indexhez, ha azt részleges specifikáció szerint átalakítjuk.
- A schema/rls check az `reward_grants_user_id_code_unique` indexet várja, ami a jövőbeli partial indexek után nem lesz releváns.

## Mit módosítottunk?
- Új migráció (`supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`) hozzáadja a `grant_day` oszlopot, partial unique indexeket, az `reward_grants_user_created_at_idx` indexet biztosítja, és átírja a `grant_signup_bonus_if_eligible()` függvényt, hogy `ON CONFLICT (user_id, code) WHERE code = 'signup_bonus'` mezőt használjon.
- A `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` mostantól ellenőrzi a `grant_day` oszlop létezését, a `reward_grants_user_signup_bonus_unique` és `reward_grants_user_daily_bonus_day_unique` indexeket, valamint a `reward_grants_user_created_at_idx`/`user_events_user_created_at_idx` listázó indexeket.
- A `docs/data_model/reward_grants_table_doc.md` bővült a `grant_day` mező leírásával és a `signup_bonus`/`daily_bonus` egyediségre vonatkozó partial index szerződéssel.

## Tesztek
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (a `20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql` migráció lefutott; a `reward_grants_user_created_at_idx` már létezett, ezért NOTICE figyelmeztetés jelent meg).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` – PASS.
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS.
- `./scripts/check.sh` – PASS (a standard analyze és a widget/unit tesztek összessége hibátlanul futott, lásd `app/test/widget/*.dart` + `app/test/unit/bonus_system_post_auth_init_test.dart` log).

## Következő lépések javasolt
1. Győződjünk meg róla, hogy a jövőbeni `daily_bonus` migráció megfelelően beállítja a `grant_day` értéket és indexeket.
2. Ha további partial indexek érkeznek, a `bonus_system_db_schema_rls_checks.sql`-t bővítsük további névellenőrzésekkel.
