# Daily bonus – amount aktiválása (reward_definitions)

**TASK_SLUG:** `bonus_system_daily_bonus_amount_activation`

## 🎯 Funkció

A `reward_definitions.code='daily_bonus'` jelenleg `amount=0` placeholder, ezért a daily bonus RPC “disabled” ágon marad.
Ebben a taskban aktiváljuk az éles napi bónuszt: `amount > 0`, `enabled = true` migrációval.

Cél:
- új Supabase migráció, ami determinisztikusan beállítja a daily bonus amount-ot (alap: **50**)
- opcionális doksi pontosítás: a specben szerepeljen az aktuális induló amount (single source of truth)

Nem cél:
- Flutter UI módosítás
- RPC logika módosítás
- új SQL-check fájlok bevezetése (a meglévő behavior check már lefedi a 0 és 50 ágakat)

## 🧠 Fejlesztési részletek

### Érintett fájlok (valós repo)
- `supabase/migrations/20260209000000_bonus_system_daily_bonus_reward_definition.sql` (régi seed, amount=0)
- ÚJ: `supabase/migrations/20260211000000_bonus_system_daily_bonus_amount_activation.sql`
- Opcionális doksi: `documents/bonus_system/daily_bonus.md`
- Regressziók:
  - `supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
  - `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
  - `supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`
  - `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`

### 1) Migráció: amount=50, enabled=true (deterministikus)

Követelmény:
- INSERT … ON CONFLICT UPDATE, hogy drift esetén is fixálja a kívánt állapotot

Javasolt SQL:
- `code='daily_bonus'`
- `amount=50`
- `enabled=true`

### 2) Doksipatch (opcionális, kicsi)

A `documents/bonus_system/daily_bonus.md` “Reward definition” szekciójába:
- “Jelenlegi induló amount: 50 TippCoin (migráció: 20260211000000…)”
- rögzítve, hogy csak migrációval változik

## 🧪 Tesztállapot

Kötelező parancsok (dokumentálni a reportban):
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`
- `./scripts/check.sh`

## 🌍 Lokalizáció

Nincs.

## 📎 Kapcsolódások

- `public.reward_definitions` (daily_bonus)
- `public.grant_daily_bonus_if_eligible()` disabled feltétele: enabled=false vagy amount<=0
- A behavior check már explicit módon állít amount=0 és amount=50 értékeket, így regressziót fogni fog.
