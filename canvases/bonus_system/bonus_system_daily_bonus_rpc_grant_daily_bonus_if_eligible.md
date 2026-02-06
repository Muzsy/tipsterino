# Bonus system – grant_daily_bonus_if_eligible() RPC (DB grant + privilege + checks)

**TASK_SLUG:** `bonus_system_daily_bonus_rpc_grant_daily_bonus_if_eligible`

## 🎯 Funkció

Implementálni a napi bónusz DB-oldali grantolását egyetlen, idempotens RPC-n keresztül:

- `public.grant_daily_bonus_if_eligible() -> jsonb`
- Gate-ek (a signup bonus mintájára): `not_authenticated`, `not_verified`, `profile_incomplete`, `disabled`, `already_claimed_today`, `granted`
- Napi limit: UTC nap (`grant_day DATE` + partial unique index már megvan)
- Mellékhatások (standard grant pipeline):
  - insert `public.reward_grants` (code=`daily_bonus`, grant_day=`(now() AT TIME ZONE 'UTC')::date`)
  - upsert + update `public.user_stats.tippcoins += amount`
  - insert `public.user_events` (`type='tippcoin_credit'`, `code='daily_bonus'`, `amount`, payload)

Privilege contract:
- `anon` nem hívhatja
- `authenticated` hívhatja (EXECUTE), de **nem** kaphat table-level INSERT/UPDATE jogot a ledger táblákon

## 🧠 Fejlesztési részletek

### Forrás-igazság (repo)
- Spec: `documents/bonus_system/daily_bonus.md`
- Reward definition: `supabase/migrations/20260209000000_bonus_system_daily_bonus_reward_definition.sql` (amount=0 placeholder)
- grant_day/index szerződés: `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- Signup RPC minta: `public.grant_signup_bonus_if_eligible()` a 202602080 migrációban
- Email verifikáció helper: `public.is_email_verified(uuid)` (202602040 migráció)
- Privilege contract minta: `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql`
- SQL check minták:
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
  - `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`

### RPC szerződés (kötelező response mezők)
`jsonb` mezők:
- `granted` boolean
- `amount` integer
- `reason` text
- `next_eligible_at` timestamptz (UI-hoz; not_authenticated esetén lehet null)

### Disabled logika (fontos a placeholder miatt)
A `daily_bonus` reward_definitions jelenleg `amount=0` placeholder.
Az RPC viselkedése:
- ha `enabled=false` **vagy** `amount <= 0` → `reason='disabled'`, `granted=false`
(Ezzel elkerüljük a “0 értékű grant” esemény-spam-et.)

### Idempotencia (napi)
- `grant_day := (now() AT TIME ZONE 'UTC')::date`
- Insert:
  - `ON CONFLICT (user_id, code, grant_day) WHERE code='daily_bonus' DO NOTHING`
- Ha nem jött létre grant row → `reason='already_claimed_today'`

### next_eligible_at számítás (UTC holnap 00:00)
Ajánlott:
- `v_next_eligible_at := (date_trunc('day', now() AT TIME ZONE 'UTC') + interval '1 day') AT TIME ZONE 'UTC';`

### Gate-ek (ugyanaz a sorrend, mint signupnál)
1) `v_user_id := auth.uid()` null → not_authenticated
2) `public.is_email_verified(v_user_id)` false → not_verified
3) `profiles.nickname` és `profiles.avatar_key` non-empty → profile_incomplete ha hiányzik
4) reward_definitions `daily_bonus` (enabled/amount) → disabled
5) insert grant (idempotens) → already_claimed_today / granted

### Privilege contract
Új migrációban:
- `REVOKE ALL ON FUNCTION public.grant_daily_bonus_if_eligible() FROM PUBLIC, anon, authenticated;`
- `GRANT EXECUTE ON FUNCTION public.grant_daily_bonus_if_eligible() TO authenticated;`

(A táblák privilege szerződését nem módosítjuk; csak ellenőrizzük a negatív access checkben.)

### SQL checks (újak)
Hozz létre 3 új check fájlt (signup mintára):

1) `supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
- function existence
- SECURITY DEFINER ellenőrzés
- authenticated EXECUTE ellenőrzés

2) `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
- not_authenticated
- not_verified
- profile_incomplete
- disabled (amount=0 / enabled=false)
- granted (amount>0 + enabled=true)
- idempotencia (same day → already_claimed_today)
- mellékhatások: reward_grants 1 sor + grant_day helyes; user_stats tippcoins; user_events 1 sor

3) `supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`
- anon: nincs EXECUTE a daily RPC-n
- anon: nincs INSERT/UPDATE/DELETE a reward_grants/user_stats/user_events táblákon
- authenticated: nincs table-level UPDATE a user_events-en; csak read_at UPDATE oszlopjog (konzisztencia a meglévő contracttal)

## 🧪 Tesztállapot

Kötelező futtatások (reportban dokumentálandó):

- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_daily_bonus_negative_access_checks.sql`
- plusz regresszió:
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
  - `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
  - `./scripts/check.sh`

## 🌍 Lokalizáció

- Nem érint ARB kulcsokat.

## 📎 Kapcsolódások

- `documents/bonus_system/daily_bonus.md`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/migrations/20260209000000_bonus_system_daily_bonus_reward_definition.sql`
- `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql`
