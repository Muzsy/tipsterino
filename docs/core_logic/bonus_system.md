# Bonus rendszer (Rewards) – rendszerleírás

## 🎯 Funkció

Egységes, auditálható bónusz- és jóváírási rendszer, ahol:

* a bónuszok szabályai **csak repo + migrációval** módosíthatók,
* a jóváírások **ledger-szerűen** naplózódnak,
* a felhasználó felé minden releváns esemény megjelenik **in-app inbox** (user_events) formában,
* a kiosztás **idempotens** és visszakövethető.

Kiemelt use-case: **regisztrációs (signup) bónusz**, ami **csak email verifikáció után** jár.

---

## 🧠 Fejlesztési részletek

### Alapfogalmak

* **reward definition**: a jutalom típusa és alap paraméterei (pl. `signup_bonus`, összeg, enabled)
* **reward grant**: egy konkrét kiosztás egy usernek (mikor, mennyi, milyen okból)
* **user event**: felhasználó felé megjelenő esemény (pl. TippCoin jóváírás értesítése)

### Invariánsok (nem alkuképes szabályok)

1. A bónusz összege és elérhetősége **nem kliens-döntés**.

   * `reward_definitions` tartalma migrációval változik.
2. Kliens **nem** hozhat létre `reward_grants` rekordot, és nem módosíthat `user_stats.tippcoins`-t.
3. A kiosztás **idempotens**:

   * `signup_bonus` ugyanannak a usernek **maximum 1×**.
4. Minden TippCoin jóváírásról legyen user event (in-app értesítés).
5. A múltbeli kiosztások nem változnak meg attól, hogy a definíció összege később módosul:

   * `reward_grants.amount` a kiosztáskori érték.

### Signup bónusz – jogosultsági feltételek

A `signup_bonus` kizárólag akkor kerül kiosztásra, ha **minden** feltétel teljesül:

* **Email verifikáció megtörtént** (az auth user verified állapotban van).
* A regisztrációs flow **profil-kötelező részei megvannak** (nickname + avatar), azaz a profil „complete” állapotban van.
* A bónusz definíció engedélyezett: `reward_definitions.code = 'signup_bonus'` és `enabled = true`.
* A user még **nem kapta meg** (DB-szintű duplázásvédelem).

> Megjegyzés: ha a profiladatok (nickname/avatar) már a signup során bekerülnek a meta-ba, a „profil complete” feltétel attól még kötelező, csak könnyebb teljesül.

### Triggerpont és végrehajtási elv

A bónusz kiosztása **nem a signUp pillanatában**, hanem az email verifikáció után történik.
Ajánlott szerződés-szintű trigger:

* **„Verified + első érvényes belépés / session”** eseménykor (a user már verified és van aktív session).

A konkrét megvalósítás lehet:

* Edge Function / RPC meghívás a kliensből az első verified session után (a szerver oldalon ellenőriz mindent), vagy
* szerveroldali folyamat, ami a verified állapot detektálásakor fut.

A lényeg: **a kliens csak kiváltja**, a kiosztás **mindig szerveroldalon** dől el és történik.

### Standard „grant pipeline” (általánosítható)

Bármely jövőbeli bónusz (pl. daily bonus, challenge reward) ugyanazt a sémát használja:

1. `reward_definitions` → a `code` alapján a kiosztandó összeg/paraméterek meghatározása
2. `reward_grants` beszúrás **duplázásvédelemmel**
3. `user_stats.tippcoins` frissítés (atomikusan)
4. `user_events` beszúrás (in-app értesítés)

### Biztonság és jogosultságok (RLS elv)

* `reward_definitions`: kliens semmit nem csinálhat (read/insert/update/delete tiltva)
* `reward_grants`: kliens csak a saját kiosztásait olvashatja
* `user_stats`: kliens csak a saját statját olvashatja
* `user_events`: kliens a saját eseményeit olvashatja; csak `read_at` módosítható

### Daily bonus (spec link)

- Részletes specifikáció a `documents/bonus_system/daily_bonus.md` fájlban található; minden új szabályt ott kell átvezetni.
- A daily bonus a standard grant pipeline-t használja, napi (UTC) idempotencia mellett.
- Az implementáció (reward definition, migráció, RPC, UI) külön járatokban készül; jelen dokumentáció csak a szerződést dokumentálja, nem feltételez kész állapotot.

### Értesítések / inbox (user_events)

Az „értesítés” itt **nem push**, hanem **in-app inbox**.
Minimum eseménytípus:

* `tippcoin_credit`

Signup bónusz esemény szerződése:

* `type = 'tippcoin_credit'`
* `code = 'signup_bonus'`
* `amount = <kiosztott összeg>`
* `read_at = NULL` (alapból olvasatlan)
* `payload` opcionális meta adatokhoz

### Változtatási szabály

Új bónusz / összegmódosítás kizárólag:

* új migráció (`reward_definitions` insert/update),
* és szükség esetén a szerveroldali grant logika bővítése.

---

## 🧪 Tesztállapot

DoD (Definition of Done) a signup bónuszra, **email verifikáció után**:

* [ ] Verified állapot **előtt** nem jár a bónusz (nincs grant, nincs stat update, nincs event)
* [ ] Verified állapot **után** (első érvényes session) a bónusz 1× kiosztódik
* [ ] `reward_grants` rekord létrejön, `amount` helyes
* [ ] `user_stats.tippcoins` megfelelően nő
* [ ] `user_events` rekord létrejön, `read_at` NULL
* [ ] Idempotencia: többszöri trigger esetén sincs duplázás
* [ ] RLS: kliens nem tud grant-et létrehozni / statot írni / definitions-t olvasni
* [ ] Kliens oldalon eseménylista lapozható, olvasottá tehető (`read_at`)

---

## 🌍 Lokalizáció

A UI a `type + code` alapján választ szöveget.
Javasolt kulcsstruktúra:

* `events.tippcoin_credit.signup_bonus.title`
* `events.tippcoin_credit.signup_bonus.body`

---

## 📎 Kapcsolódások

Kapcsolódó tábladokuk:

* `docs/data_model/reward_definitions_table_doc.md`
* `docs/data_model/reward_grants_table_doc.md`
* `docs/data_model/user_stats_table_doc.md`
* `docs/data_model/user_events_table_doc.md`

Kapcsolódó folyamatdoksi (ha van):

* `docs/core_logic/registration_flow.md`

Ajánlás a tábladokuk elejére:

* 1 soros hivatkozás erre a rendszerszintű doksira (single source of truth).
