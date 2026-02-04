# Bonus system – DB schema + RLS migráció

**TASK_SLUG:** `bonus_system_db_schema_rls`

**Cél:** a bónuszrendszerhez szükséges adatmodell és jogosultságok (RLS) bevezetése Supabase migrációval, a már meglévő dokumentációval összhangban.

---

## 🎯 Funkció

Hozzuk létre és rögzítsük a bónuszrendszer DB-alapját:

* `reward_definitions` – bónusz definíciók (repo+migrációval változtatható; kliens nem fér hozzá)
* `reward_grants` – jóváírás napló (append-only; user csak a sajátját olvassa)
* `user_stats` – TippCoin egyenleg (append-only log alapján frissül; user csak olvassa)
* `user_events` – in-app inbox/idővonal (user olvas; csak `read_at` írható)

**Kötelező:** a `signup_bonus` duplázás-védelem DB-szinten (user + code egyediség), és minden érintett táblán RLS beállítás a `docs/core_logic/bonus_system.md` szerint.

### Nem cél

* Edge Function / RPC / trigger-alapú grant pipeline implementáció (külön task).
* Flutter UI módosítás.
* A `signup_bonus` összegének véglegesítése (ha most csak bootstrap értéket adunk, később migrációval állítjuk be).

---

## 🧠 Fejlesztési részletek

### Talált releváns fájlok (forrás-igazság)

* `docs/core_logic/bonus_system.md` – bónuszrendszer invariánsok + RLS elv + email verified triggerpont.
* `docs/data_model/reward_definitions_table_doc.md`
* `docs/data_model/reward_grants_table_doc.md`
* `docs/data_model/user_stats_table_doc.md`
* `docs/data_model/user_events_table_doc.md`
* `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` – minta RLS/grant stílusra.
* `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – minta SQL checks stílusra.
* `scripts/supabase.sh` – Supabase CLI wrapper.
* `scripts/check.sh` – repo standard gate.

### Preflight + MCP

* `codex mcp list`/resource lookup (read-only) a cél DB-t célozza: a cél az, hogy a reward_* / user_* táblák jelenleg nem léteznek, de ha az MCP OAuth handshaking blokkolja a lekérést, a hibaüzenetet a reportban dokumentáljuk, és a további munkát helyi, `.env.local` alapú push/check párossal végezzük.
* A `supabase` CLI + `./scripts/supabase.sh db push` lesz a „tényleges” preflight, csak azután futtatjuk, hogy a migráció/check fájlok készen állnak.

### Implementációs elvárások (SQL)

**Új migráció fájl:**

* `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`

**Tartalom (minimum):**

1. Biztosítsd a uuid defaultot (javaslat: `pgcrypto`):

   * `create extension if not exists "pgcrypto";`

2. Táblák létrehozása **idempotensen** (`create table if not exists`), a docs szerinti mezőkkel és constraint-ekkel:

* `public.reward_definitions`

  * `code text primary key` (regex check: `^[a-z0-9_]{3,40}$`)
  * `amount integer not null` (check `amount >= 0`)
  * `enabled boolean not null default true`
  * `created_at timestamptz not null default now()`
  * `updated_at timestamptz not null default now()`

* `public.reward_grants`

  * `id uuid primary key default gen_random_uuid()`
  * `user_id uuid not null references auth.users(id) on delete cascade`
  * `code text not null references public.reward_definitions(code)`
  * `amount integer not null` (check `amount >= 0`)
  * `reason text null`
  * `created_at timestamptz not null default now()`
  * **egyediség:** unique index `(user_id, code)` (MVP: `signup_bonus` duplázás-védelem)
  * indexek: `(user_id, created_at desc)` a listázáshoz

* `public.user_stats`

  * `user_id uuid primary key references auth.users(id) on delete cascade`
  * `tippcoins integer not null default 0` (check `tippcoins >= 0`)
  * `created_at timestamptz not null default now()`
  * `updated_at timestamptz not null default now()`

* `public.user_events`

  * `id uuid primary key default gen_random_uuid()`
  * `user_id uuid not null references auth.users(id) on delete cascade`
  * `type text not null` (regex check: `^[a-z0-9_]{3,40}$`)
  * `code text null` (ha nem null, regex check ugyanaz)
  * `amount integer null` (ha nem null, check `amount >= 0`)
  * `payload jsonb null`
  * `created_at timestamptz not null default now()`
  * `read_at timestamptz null`
  * indexek: `(user_id, created_at desc)`

3. `updated_at` frissítés (csak ott, ahol van):

* Közös trigger function (ha még nincs): `public.set_updated_at()`
* Triggerek: `reward_definitions`, `user_stats`.

4. RLS + policy + privilege (a bonus_system.md szerint):

* `reward_definitions`: RLS ON, **nincs policy** (kliens nem olvashat).
* `reward_grants`: RLS ON, `SELECT` policy: `user_id = auth.uid()`.
* `user_stats`: RLS ON, `SELECT` policy: `user_id = auth.uid()`.
* `user_events`: RLS ON

  * `SELECT` policy: `user_id = auth.uid()`
  * `UPDATE` policy: `user_id = auth.uid()` (és **grant csak** `read_at` oszlopra)

**GRANT (a minimális kliens-jogok rögzítéséhez):**

* `grant select on public.reward_grants to authenticated;`
* `grant select on public.user_stats to authenticated;`
* `grant select on public.user_events to authenticated;`
* `grant update (read_at) on public.user_events to authenticated;`
* `reward_definitions`: ne adj `select` grantet.

5. Bootstrap adat (MVP):

* `reward_definitions` kapjon `signup_bonus` sort `on conflict do nothing` mintával.

  * Ha az összeg még nincs rögzítve, akkor **ideiglenes** összeget használj (pl. 0), és írd le a reportban, hogy később migrációval állítjuk be.

### SQL checks

**Új checks fájl:**

* `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`

Minimum ellenőrzések (psql-ben futtatható):

* táblák léteznek (`to_regclass(...) is not null`)
* RLS engedélyezve (`pg_class.relrowsecurity`)
* policy-k léteznek (`pg_policies`)
* kritikus indexek léteznek (`pg_indexes`)
* `reward_definitions` tartalmazza a `signup_bonus` rekordot

### Seed fájl

A `supabase/config.toml` seedelést vár (`./seed.sql`), de a fájl hiányzik. Hozz létre egy **üres/komment-only** `supabase/seed.sql`-t, hogy a lokális `db reset` ne bukjon el.

### Pipálható teendők

* [ ] Preflight: ellenőrizd (MCP vagy `psql`) hogy a 4 tábla még nem létezik a cél DB-ben.
* [ ] Új migráció fájl létrehozása a fenti sémával + RLS + grant.
* [ ] SQL checks fájl létrehozása.
* [ ] `supabase/seed.sql` placeholder létrehozása.
* [ ] `./scripts/supabase.sh db push` futtatása (env: `.env.local`), majd `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`.
* [ ] `./scripts/check.sh` futtatása.
* [ ] Codex checklist + report kitöltése (parancsok, kimenet, fájllista).

### Kockázatok + rollback

* **Kockázat:** a távoli DB-ben már léteznek részben táblák/constraint-ek → `db push` fail. **Rollback:** a migrációt módosítsd idempotensre (IF NOT EXISTS + drop policy if exists), vagy írj új follow-up migrációt a kompatibilizálásra.
* **Kockázat:** túl széles jogosultság (pl. `user_events` update több oszlopra). **Rollback:** explicit `grant update (read_at)` + policy szűkítés, és a reportban dokumentált ellenőrzés.
* **Kockázat:** uuid default hiány (extension). **Rollback:** `pgcrypto`/uuid-ossp explicit bekapcsolása a migráció elején.

---

## 🧪 Tesztállapot

Kötelező futtatások és dokumentálás a reportban:

* `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
* `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
* `./scripts/check.sh`

---

## 🌍 Lokalizáció

* Nem érint UI szöveget.

---

## 📎 Kapcsolódások

* `docs/core_logic/bonus_system.md`
* `docs/core_logic/registration_flow.md`
* `docs/data_model/reward_definitions_table_doc.md`
* `docs/data_model/reward_grants_table_doc.md`
* `docs/data_model/user_stats_table_doc.md`
* `docs/data_model/user_events_table_doc.md`
* `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
* `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
* `scripts/supabase.sh`
* `scripts/check.sh`
