# Bonus system – daily_bonus reward_definitions migráció + doksi patch

**TASK_SLUG:** `bonus_system_daily_bonus_reward_definition_migration_and_docs_patch`

## 🎯 Funkció

1) DB-ben létrehozni a `reward_definitions` táblában a `daily_bonus` sort (repo+migrációval menedzselt, kézi módosítás nincs).
2) Két kicsi doksi-pontatlanság javítása:
   - `grant_day` képlet típusegyezése (`date`)
   - daily bonus UI állapotleírás pontosítása + napi limit szekció igazítása a már megvalósított (grant_day + partial unique index) szerződéshez
3) `bonus_system_db_schema_rls_checks.sql` kiegészítése: ellenőrizze, hogy a `daily_bonus` reward definition létezik.

Nem cél:
- `grant_daily_bonus_if_eligible()` RPC
- daily bonus DB behavior checks
- Flutter UI/l10n

## 🧠 Fejlesztési részletek

### Érintett fájlok (valós repo)
- Spec: `documents/bonus_system/daily_bonus.md`
- Tábla doku: `docs/data_model/reward_grants_table_doc.md`
- Schema/RLS check: `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- Új migráció: `supabase/migrations/<next_ts>_bonus_system_daily_bonus_reward_definition.sql`

### 1) Reward definition migráció

Hozz létre új migrációt, ami garantálja, hogy a `daily_bonus` definition létezik:

- `code='daily_bonus'`
- `enabled=true`
- `amount` kezdetben **0** (szándékosan: produkt döntés után külön migrációban állítjuk véglegesre)

A migráció legyen determinisztikus:
- `INSERT ... ON CONFLICT (code) DO UPDATE SET amount=EXCLUDED.amount, enabled=EXCLUDED.enabled;`
  (Így drift esetén is helyreáll a szerződés.)

### 2) Doksi patch #1 – `grant_day` képlet (date típus)

Javítandó pontatlanság:
- `DATE_TRUNC('day', (NOW() AT TIME ZONE 'UTC'))` → nem `date`, hanem timestamp.

Helyes minta:
- `grant_day = (now() AT TIME ZONE 'UTC')::date`

Ezt javítsd:
- `docs/data_model/reward_grants_table_doc.md` – grant_day logika
- `documents/bonus_system/daily_bonus.md` – “Mellékhatások” grant_day példája

### 3) Doksi patch #2 – daily bonus napi limit + UI state pontosítás

`documents/bonus_system/daily_bonus.md` módosítások:

**Napi limit szekció**
- Ne “opcionális/javasolt” legyen, hanem a valós szerződés:
  - `reward_grants.grant_day DATE`
  - CHECK constraint: `daily_bonus` esetén `grant_day` nem lehet NULL
  - partial unique index: `reward_grants_user_daily_bonus_day_unique` (user_id, code, grant_day) WHERE code='daily_bonus'

**UI szerződés**
- Állapotok legyenek egyértelműek és ellentmondásmentesek:
  - `available`: a user **most jogosult** (pl. `next_eligible_at` hiányzik vagy `<= now()`), tehát a claim elérhető
  - `claimed`: a user **már igényelte ma**, ezért `next_eligible_at` a jövőben van (jellemzően holnap 00:00 UTC)
  - `offline`: nincs hálózat; a legutóbbi cache-elt `next_eligible_at` alapján lehet becsülni (ha `<= now()` → valószínűleg available, különben claimed)

Fontos: a claimed állapotot **ne** az inbox `read_at`-ból vezesd le (az olvasottság nem a grant tényét jelzi).

### 4) Schema/RLS check kiegészítése

`supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` végén (ahol a `signup_bonus` definitiont ellenőrzi):
- ellenőrizze, hogy `public.reward_definitions` tartalmazza a `daily_bonus` sort is (létezés).

## 🧪 Tesztállapot

Kötelező futtatások (reportban dokumentálandó):

- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `./scripts/check.sh`

## 🌍 Lokalizáció

- Nem érint ARB kulcsokat.

## 📎 Kapcsolódások

- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql` (reward_definitions tábla + signup_bonus seed)
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql` (grant_day + index szerződés)
- `documents/bonus_system/daily_bonus.md`
- `docs/data_model/reward_grants_table_doc.md`
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `scripts/supabase.sh`
- `scripts/check.sh`
