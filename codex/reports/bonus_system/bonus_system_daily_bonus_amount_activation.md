## Mit találtunk?
- A `reward_definitions` seed tegnap `amount=0` értékkel fut, így a `daily_bonus` RPC a `disabled` branchre esik, amíg nincs valós amount.

## Mit módosítottunk?
- `20260211000000_bonus_system_daily_bonus_amount_activation.sql` migráció került fel, amely `daily_bonus`-ra `amount=50` és `enabled=true` értékeket ír INSERT ... ON CONFLICT UPDATE utasítással, így drift esetén is fix marad a definíció.
- Frissítettük a dokumentáció `Reward definition` szakaszát, ahol az induló amountként 50 TippCoin szerepel, illetve megemlítettük a migráció timestampjét és azt, hogy csak migrációk módosíthatják az értéket.

## Módosított/létrehozott fájlok
- `supabase/migrations/20260211000000_bonus_system_daily_bonus_amount_activation.sql`
- `documents/bonus_system/daily_bonus.md`
- `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_amount_activation.md`
- `codex/reports/bonus_system/bonus_system_daily_bonus_amount_activation.md`

## Tesztek / parancsok
- `./scripts/check.sh` – PASS (analyze + unit/widget tesztek futottak a Flutter-kódban)
- Supabase parancsok (**nem futottak** itt, mert az environment nem rendelkezik valós `DATABASE_URL`/Supabase klienssel):
  - `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`

## Következő javasolt lépések
1. Futtasd végig a Supabase parancsokat (db push + SQL checkek) valós DB kapcsolattal, és dokumentáld az eredményeket a reportban.
2. Ha a reward definition további értékváltozásokat igényel, hasonló migrációs mintát használj az INSERT ... ON CONFLICT UPDATE-hez, és dokumentáld a timestampet.
