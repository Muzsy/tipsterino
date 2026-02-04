# Bonus system – RPC: signup bónusz kiosztás (email verifikáció után)

**TASK_SLUG:** `bonus_system_rpc_signup_bonus`

---

## 🎯 Funkció

Ebben a feladatban a signup bónusz kiosztását a DB-ben **egy idempotens, SECURITY DEFINER RPC** végzi.

A cél, hogy az app a verifikáció utáni első authenticated session során meghívhassa az RPC-t, és a szerver:

* ellenőrizze, hogy a user **email verifikált** (`auth.users.email_confirmed_at` vagy `confirmed_at`)
* ellenőrizze, hogy a user **még nem kapta meg** a `signup_bonus`-t (unique index: `reward_grants_user_id_code_unique`)
* ha jogosult:

  * létrehozza a `reward_grants` sort (ledger)
  * biztosítja a `user_stats` sort
  * növeli a `user_stats.tippcoins` értéket
  * létrehoz egy `user_events` bejegyzést (`tippcoin_credit`, `signup_bonus`)

**Idempotencia:** többszöri meghívás sem dupláz.

---

## 🧠 Fejlesztési részletek

### Forrás-igazság

* `docs/core_logic/bonus_system.md` – triggerpont: email verified + első authenticated session
* `docs/data_model/*_table_doc.md` – táblák és RLS elvek
* `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql` – tényleges táblák, RLS, grant
* `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – ellenőrzések
* Példa stílus: `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`

### Fontos realitás

A kliens **nem** írhat grant-et/stats-ot/events-et (RLS tilt). Ezért az RPC:

* `SECURITY DEFINER`
* explicit `search_path` beállítással
* kontrollált táblaműveletekkel

### Email verifikáció ellenőrzés

A Supabase verziótól függően a mező neve eltérhet. A cél:

* `auth.users` táblában az email-confirmed státusz alapján dönteni (lokálisan `email_confirmed_at` létezik)
* tipikus mezők: `email_confirmed_at` vagy `confirmed_at`

**Elvárás:** az RPC helper `COALESCE(users.email_confirmed_at, users.confirmed_at)` mintázattal olvassa a verifikációt, és az aktuális mező nevét a reportban dokumentálja.

### Idempotencia mechanizmus

Jelen DB schema szerint a duplázás-védelem:

* `reward_grants` unique index `reward_grants_user_id_code_unique` (user_id + code)

A `reward_grants` `insert ... on conflict do nothing` logikája a `RETURNING id` alapján dönt, hogy folytatódjon-e `user_stats`/`user_events` írással vagy már `already_granted`-et adjon vissza.

### Visszatérési érték

Az RPC adjon vissza **strukturált** választ, hogy a kliens logolni tudjon:

* `granted: boolean`
* `amount: integer`
* `reason: text` (`not_authenticated` | `not_verified` | `disabled` | `already_granted` | `granted`)

---

## 🧪 Tesztállapot

Kötelező ellenőrzések:

* SQL checks: új `bonus_system_rpc_signup_bonus_checks.sql`
* Lokális/remote próbafuttatás (ha lehetséges): authenticated user hívja az RPC-t

Minőségkapu:

* `./scripts/check.sh`

---

## 🌍 Lokalizáció

A task nem módosít UI szöveget.

A `user_events` rekord mezői:

* `type = 'tippcoin_credit'`
* `code = 'signup_bonus'`
* `amount = <jóváírt összeg>`

---

## 📎 Kapcsolódások

Érintett fájlok:

* `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql` (új)
* `supabase/sql_checks/bonus_system_rpc_signup_bonus_checks.sql` (új)
* `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus.md`
* `codex/reports/bonus_system/bonus_system_rpc_signup_bonus.md`

Meglévő (referencia):

* `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
* `docs/core_logic/bonus_system.md`
