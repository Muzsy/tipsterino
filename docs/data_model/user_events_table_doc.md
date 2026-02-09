# Supabase – `user_events` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/user_events_table_doc.md`

Ez a dokumentum a `user_events` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `user_events` tábla a felhasználót érintő események **egységes idővonalát** (inbox / feed) tárolja.

Cél:
- egyetlen helyen listázhatóak legyenek a felhasználót érintő események:
  - TippCoin jóváírások/levonások
  - üzenetek
  - barátjelölések
  - kihívások
  - egyéb gamification események

**MVP fókusz:** TippCoin jóváírás események rögzítése (`tippcoin_credit`) a verifikáció utáni signup bónuszhoz, amelyet az email-verified + első authenticated session információi hajtanak.

A `user_events` nem publikus. Anon felhasználó nem férhet hozzá.

## 🧠 Fejlesztési részletek

### Tábla: `public.user_events`

- Események append-only jellegűek: létrejönnek és utólag csak olvasottság jelölés változik.
- A rekordok többségét szerveroldali folyamatok hozzák létre (trigger / Edge Function / RPC).
- A kliens csak olvassa és a saját olvasottságát jelölheti.

### Mezők

#### 1) `id` (uuid)
**Szerep:**
- elsődleges azonosító (PK)

**Logika:**
- DB generálja (uuid default), a kliens nem adja meg.

#### 2) `user_id` (uuid)
**Szerep:**
- az esemény címzettje

**Logika:**
- FK az `auth.users(id)` mezőre.
- kötelező, nem lehet `NULL`.

#### 3) `type` (text)
**Szerep:**
- az esemény kategóriája (a kliens UI komponenseit ez választja ki)

**Kötelező értékek (MVP-ben használt):**
- `tippcoin_credit` (jóváírás)

**Későbbi bővítéshez tervezett értékek (név konvenció):**
- `tippcoin_debit`
- `message`
- `friend_request`
- `challenge`

#### 4) `code` (text)
**Szerep:**
- az esemény oka/altípusa (lokalizálható címke kulcsa)

**MVP-ben használt:**
- `signup_bonus`

**Logika:**
- TippCoin eseményeknél a `code` tipikusan a jutalom/bónusz kódja.

#### 5) `amount` (integer, nullable)
**Szerep:**
- TippCoin eseményeknél a jóváírt/levont összeg

**Logika:**
- csak TippCoin típusoknál kötelező.
- más event típusoknál `NULL`.

#### 6) `payload` (jsonb, nullable)
**Szerep:**
- bővíthető adatszerkezet extra információkhoz (pl. küldő user, messageId, challengeId)

**Logika:**
- opcionális.
- a kliens csak olyan adatot kapjon, ami az adott típus UI megjelenítéséhez kell.

#### 7) `created_at` (timestamptz, default `now()`)
**Szerep:**
- esemény időpontja

**Logika:**
- DB default.
- nem módosítható.

#### 8) `read_at` (timestamptz, nullable)
**Szerep:**
- olvasottság jelölése

**Logika:**
- `NULL` = olvasatlan
- érték = mikor olvasta el a user
- a kliens csak a saját eseményein állíthatja.

## 🛡️ RLS / Policy logika (kód nélkül)

### RLS állapot
- A `user_events` táblán RLS **bekapcsolva**.

### Alapelv
- Anon felhasználó nem olvashat.
- Bejelentkezett felhasználó csak a saját eseményeit olvashatja.
- A kliens nem hozhat létre eseményt.
- A kliens csak a `read_at` mezőt módosíthatja a saját rekordjain.

### SELECT
- `authenticated` felhasználó olvashatja a saját rekordjait (`user_id = auth.uid()`).
- anon tiltott.

### INSERT
- a kliens számára **tiltott**.
- kizárólag szerveroldali folyamat hozhat létre eseményt.

### UPDATE
- `authenticated` felhasználó csak a saját rekordjain frissítheti a `read_at` mezőt.
- minden más mező módosítása tiltott.

### DELETE
- tiltott.

## 🧩 Esemény létrehozás szabály (TippCoin)
Minden TippCoin változás eseményt generál.

Kötelező mintázat:
- ha `user_stats.tippcoins` nő:
  - `type = tippcoin_credit`
  - `code = <jutalom kód>` (pl. `signup_bonus`)
  - `amount = <jóváírt összeg>`
  - `payload` opcionális

MVP kötelező esemény:
- signup bónusz jóváírásakor esemény jön létre a post-auth init logika részeként; a trigger csak akkor indul el, ha az adott user email verified és az első authenticated session szerveroldali inicializációja lezárult.

## 🔎 Lekérdezés az "Események" képernyőhöz
Kötelező szabályok:
- csak a saját események listázása (`user_id = auth.uid()`)
- rendezés: `created_at` csökkenő (legújabb elöl)
- pagination kötelező
- olvasatlan jelölés: `read_at is null`

### Index szerzodes (P1 teljesitmeny)
- `user_events_user_created_at_idx`:
  altalanos user esemeny lista (`user_id`, `created_at desc`).
- `user_events_user_unread_created_at_idx`:
  olvasatlan lista lekero partial index (`user_id`, `created_at desc`)
  `where read_at is null` predicate-del.

Rationale:
- Az olvasatlan lista a user feed forro utvonala; a partial index csokkenti a
  scanelt rekordok szamat, mikozben megtartja a rendezesi kulcsot.

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- anon nem tud SELECT-et.
- authenticated user csak a saját eseményeit látja.
- kliens nem tud INSERT-et.
- kliens nem tud módosítani mást, csak a `read_at` mezőt.
- signup bónusz után `user_events` rekord létrejön és listázható.

## 🌍 Lokalizáció
A tábla nem tárol lokalizált szöveget.

Megjelenítés:
- a kliens a `type` + `code` alapján választ UI komponenst és lokalizált szöveget.
- a `payload` mező adja a dinamikus értékeket (pl. küldő nickname, összeg, stb.).

## 📎 Kapcsolódások
- `reward_grants`:
  - minden grant kötelezően generál `user_events` sort
- `user_stats`:
  - a TippCoin egyenleg változását a kliens az eseményből is tudja kommunikálni (inbox)
- UI:
  - "Események" oldal: `user_events` lista
  - később: üzenetek/barátjelölések/kihívások is ide kerülnek
- `docs/core_logic/bonus_system.md`: a bónuszrendszer single source of truth-ja; innen származik a verifikáció utáni triggerpont és a `signup_bonus` események részletes leírása
