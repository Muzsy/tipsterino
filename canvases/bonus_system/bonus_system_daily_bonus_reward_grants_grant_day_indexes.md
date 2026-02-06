# Bonus system – reward_grants grant_day + indexek (daily bonus előkészítés)

**TASK_SLUG:** `bonus_system_daily_bonus_reward_grants_grant_day_indexes`

**Cél:** a daily bonus napi idempotencia DB-alapjának előkészítése úgy, hogy a meglévő signup bonus funkció **nem törik el**.

---

## 🎯 Funkció

A `reward_grants` táblába bevezetjük a napi grantolás támogatását:

- új mező: `grant_day DATE` (UTC nap)
- új index-szerződés:
  - `signup_bonus`: **egyszeri**, user+code egyediség **csak erre a code-ra**
  - `daily_bonus`: **napi egyszer**, user+code+grant_day egyediség **csak erre a code-ra**
- a meglévő `grant_signup_bonus_if_eligible()` RPC-t kompatibilissé tesszük az új (partial) index-szerződéssel

**Kötelező:** semmilyen meglévő bonus pipeline funkció (signup bonus) nem sérülhet.

### Nem cél

- `daily_bonus` reward_definitions rekord felvétele (külön task)
- `grant_daily_bonus_if_eligible()` RPC implementáció (külön task)
- Flutter UI / inbox / l10n módosítás (külön task)

---

## 🧠 Fejlesztési részletek

### Talált releváns fájlok (forrás-igazság)

- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
  - itt van a `reward_grants_user_id_code_unique` index, ami **blokkolja** a daily bonus többszöri grantolást
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
  - itt van a legfrissebb `grant_signup_bonus_if_eligible()` definíció `on conflict (user_id, code) do nothing`-gal
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
  - jelenleg **elvárja** a `reward_grants_user_id_code_unique` indexet → frissíteni kell
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
  - signup bonus működését ellenőrzi → ennek továbbra is PASS-olnia kell
- `docs/data_model/reward_grants_table_doc.md`
  - tábladoki frissítendő (grant_day + egyediség logika)

### DB változások (migráció)

1) `reward_grants` bővítése:
- `alter table public.reward_grants add column if not exists grant_day date;`
- opcionálisan (javasolt): CHECK constraint, hogy daily bonus esetén kötelező legyen:
  - `code <> 'daily_bonus' OR grant_day is not null`

2) Indexek újraszerződése:
- `drop index if exists reward_grants_user_id_code_unique;`
- új partial unique indexek:
  - signup bonus:
    - `create unique index ... on public.reward_grants (user_id, code) where code = 'signup_bonus';`
  - daily bonus:
    - `create unique index ... on public.reward_grants (user_id, code, grant_day) where code = 'daily_bonus' and grant_day is not null;`
- a meglévő listázó index marad:
  - `reward_grants_user_created_at_idx` (ha nincs, hozzuk létre)

### Signup bonus RPC kompatibilitás

A `grant_signup_bonus_if_eligible()` jelenleg:
- `on conflict (user_id, code) do nothing`-ot használ, ami **nem fog működni**, ha csak partial unique index marad.

Megoldás:
- a beszúrást módosítsd erre:
  - `on conflict (user_id, code) where code = 'signup_bonus' do nothing`
- a függvény egyéb logikája maradjon változatlan (email verified + profile complete gate + user_stats + user_events).

### SQL checks frissítés

`supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` módosításai:
- ellenőrizze a `grant_day` oszlop létezését
- ne keresse többé a `reward_grants_user_id_code_unique` indexet
- helyette keresse:
  - signup partial unique index (név szerint)
  - daily partial unique index (név szerint)
- a meglévő `reward_grants_user_created_at_idx` ellenőrzés maradjon

### Dokumentáció frissítés

`docs/data_model/reward_grants_table_doc.md` bővítése:
- új mező: `grant_day (date)` – definíció: `created_at` UTC napja / szerveroldali számítás
- egyediség szabályok:
  - `signup_bonus`: user + code egyszer
  - `daily_bonus`: user + code + grant_day (UTC) naponta egyszer
- megjegyzés: idempotencia DB-szinten garantált indexekkel, a kliens nem “számolgat”

### Kockázatok / rollback

- Kockázat: signup bonus RPC elromlik, ha az ON CONFLICT nem illeszkedik az indexre.
  - Mitigáció: ugyanabban a migrációban frissítsd a függvényt, és futtasd a behavior check-et.
- Rollback: a migráció visszavonása (down nincs), ezért hibánál új follow-up migrációval javíts.

---

## 🧪 Tesztállapot

Kötelező futtatások (reportban dokumentálandó):

- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `./scripts/check.sh`

---

## 🌍 Lokalizáció

- Nem érint UI szöveget.

---

## 📎 Kapcsolódások

- `documents/bonus_system/daily_bonus.md`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `docs/data_model/reward_grants_table_doc.md`
- `scripts/supabase.sh`
- `scripts/check.sh`
