# Supabase – `reward_grants` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/reward_grants.md`

Ez a dokumentum a `reward_grants` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `reward_grants` tábla a TippCoin jutalmak **jóváírásainak naplója** (ledger-szerű log).

Feladata:
- rögzíti, hogy **mikor**, **melyik user** milyen **jutalmat** kapott
- biztosítja az **egyszeri** jutalmak (pl. signup bónusz) duplázás elleni védelmét
- audit és hibakeresés alapja

A `reward_grants` nem publikus. Anon felhasználó nem férhet hozzá.

## 🧠 Fejlesztési részletek

### Tábla: `public.reward_grants`

- A tábla eseményszerű, append-only jellegű napló.
- A rekordok szerveroldali folyamatokból jönnek létre (trigger / Edge Function / RPC).
- A kliens közvetlenül nem hozhat létre grantot.

### Mezők

#### 1) `id` (uuid)
**Szerep:**
- elsődleges azonosító (PK)

**Logika:**
- DB generálja (uuid default), a kliens nem adja meg.

#### 2) `user_id` (uuid)
**Szerep:**
- a jutalmat kapó felhasználó azonosítója

**Logika:**
- FK az `auth.users(id)` mezőre.
- kötelező, nem lehet `NULL`.

#### 3) `code` (text)
**Szerep:**
- a jutalom típusa (hivatkozás a definícióra)

**Logika:**
- FK a `reward_definitions(code)` mezőre.
- kötelező, nem lehet `NULL`.

#### 4) `amount` (integer)
**Szerep:**
- a jóváírt TippCoin összeg a grant pillanatában

**Logika:**
- kötelező, nem lehet `NULL`.
- nem lehet negatív.
- a `reward_definitions.amount` értékéből származik, de **külön mezőben rögzítjük**, hogy a későbbi definíció-változtatások ne írják át a múltat.

#### 5) `reason` (text)
**Szerep:**
- opcionális, rövid technikai ok/kategória (pl. `registration_complete`, `manual_grant`, `daily_claim`)

**Logika:**
- opcionális, üres lehet.
- célja a későbbi analitika és admin megkülönböztetés.

#### 6) `created_at` (timestamptz, default `now()`)
**Szerep:**
- mikor történt a jóváírás

**Logika:**
- DB default.
- nem módosítható.

### Egyediség és duplázás elleni védelem

#### Signup bónusz (MVP)
- A `signup_bonus` jóváírás **egyszeri**.
- Kötelező szabály: egy user csak egyszer kaphatja meg.
- Ezt DB-szinten egy egyedi szabály garantálja (user + code szinten).

#### Későbbi jutalmak
- Napi bónusz esetén a duplázás elleni védelem napra bontott (user + code + dátum), ezt későbbi bővítéskor vezetjük be.

## 🛡️ RLS / Policy logika (kód nélkül)

### RLS állapot
- A `reward_grants` táblán RLS **bekapcsolva**.

### Alapelv
- Anon felhasználó nem olvashat.
- Bejelentkezett felhasználó csak a saját grantjait olvashatja.
- A kliens nem hozhat létre grantot és nem módosíthat.

### SELECT
- `authenticated` felhasználó olvashatja a saját rekordjait (`user_id = auth.uid()`).
- anon tiltott.

### INSERT
- a kliens számára **tiltott**.
- kizárólag szerveroldali folyamat hozhat létre rekordot.

### UPDATE
- tiltott (append-only napló).

### DELETE
- tiltott.

## 🧩 Jóváírás folyamata (szerveroldali logika)
Minden jutalom jóváírása ugyanazon mintát követi:

1) A folyamat kiválasztja a jutalom `code`-ját.
2) A folyamat beolvassa a `reward_definitions` rekordot:
   - ha hiányzik vagy `enabled=false`, a jóváírás nem történhet meg.
3) A folyamat beszúr egy `reward_grants` rekordot:
   - `user_id`
   - `code`
   - `amount` (a definíció alapján)
4) A folyamat atomikusan növeli a `user_stats.tippcoins` értékét.
5) A folyamat létrehoz egy `user_events` rekordot a felhasználó eseményfolyamába:
   - type: `tippcoin_credit`
   - code: a jutalom kódja
   - amount: a jóváírt összeg

### Signup bónusz (MVP)
- A signup bónusz jóváírás a regisztráció **utolsó lépése**.
- Trigger pont: a `profiles` rekord sikeres beszúrása után.

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- anon nem tud SELECT-et.
- authenticated user csak a saját grantjait tudja olvasni.
- kliens nem tud INSERT/UPDATE/DELETE műveletet.
- egy user a `signup_bonus` kódot csak egyszer kaphatja meg.
- jóváírás után a `user_stats.tippcoins` növekedett, és `user_events` bejegyzés létrejött.

## 🌍 Lokalizáció
A tábla nem tárol lokalizált szöveget.

Megjelenítés:
- a kliens a `code` (pl. `signup_bonus`) alapján lokalizálja az esemény címkét.

## 📎 Kapcsolódások
- `reward_definitions`:
  - `reward_grants.code` → `reward_definitions.code`
- `user_stats`:
  - a `reward_grants` létrejötte atomikusan növeli a `user_stats.tippcoins` mezőt
- `user_events`:
  - minden grant kötelezően generál egy eseményt
- Regisztráció:
  - `profiles` insert után automatikus `signup_bonus` grant

