# Supabase – `reward_definitions` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/reward_definitions.md`

Ez a dokumentum a `reward_definitions` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `reward_definitions` tábla a TippCoin-hoz kapcsolódó **jutalomtípusok központi katalógusa**.

Feladata:
- rögzíti az egyes jutalmak **kódját** és **összegét** (TippCoin)
- lehetővé teszi a jutalmak **repo+migráció** alapú, kontrollált változtatását
- garantálja, hogy a jutalom összege **nem a kliens döntése**

A `reward_definitions` nem publikus. A kliens nem olvassa.

## 🧠 Fejlesztési részletek

### Tábla: `public.reward_definitions`

- A tábla „konfigurációs adatot” tárol: fix kódok és összegek.
- A rekordok száma kicsi, ritkán változik.
- A tartalom kizárólag **repo+migráció** útján módosítható.

### Mezők

#### 1) `code` (text)
**Szerep:**
- elsődleges kulcs (PK)
- stabil azonosító, amit a szerveroldali folyamatok használnak

**Szabályok:**
- csak kisbetűs latin betűk, számok és aláhúzás: `a-z`, `0-9`, `_`
- ajánlott hossz: 3–40
- példa: `signup_bonus`, `daily_bonus`

#### 2) `amount` (integer)
**Szerep:**
- a jutalom TippCoin összege

**Szabályok:**
- kötelező, nem lehet `NULL`
- **nem lehet negatív**
- 0 megengedett (pl. ideiglenes kikapcsolás esetén), de a kikapcsolás elsődleges módja az `enabled`

#### 3) `enabled` (boolean)
**Szerep:**
- a jutalom aktiválhatósága

**Szabályok:**
- kötelező
- ha `false`, a szerveroldali folyamatok nem adhatják a jutalmat (még ha létezne is kód).

#### 4) `created_at` (timestamptz, default `now()`)
**Szerep:**
- audit (mikor került be a katalógusba)

**Szabályok:**
- DB default
- nem módosítható

#### 5) `updated_at` (timestamptz, default `now()`)
**Szerep:**
- audit (mikor változott utoljára az összeg/állapot)

**Szabályok:**
- szerveroldalon frissül (trigger vagy migráció frissíti)
- kliens nem kezeli

### Kötelező induló rekordok (MVP)
Az MVP-ben a következő kódoknak létezniük kell:
- `signup_bonus` (enabled=true)

A pontos összeg kizárólag migrációval állítható.

## 🛡️ RLS / Policy logika (kód nélkül)

### RLS állapot
- A `reward_definitions` táblán RLS **bekapcsolva**.

### Alapelv
- A kliens (anon és authenticated) **nem** olvashatja.
- A kliens **nem** írhatja.
- A tábla módosítása kizárólag migrációval történik.

### SELECT
- tiltott anon és authenticated számára.

### INSERT / UPDATE / DELETE
- tiltott anon és authenticated számára.
- kizárólag migráció / admin jellegű folyamat (DB owner) módosíthat.

## 🧩 Használat szerveroldalon
A jutalomösszeg felhasználása kizárólag szerveroldali folyamatban történik.

Kötelező elvek:
- a jutalom jóváírásakor a folyamat a `reward_definitions`-ből olvassa a `amount`-ot a `code` alapján.
- ha a rekord nem létezik vagy `enabled=false`, a jóváírás nem történhet meg.

MVP kötelező folyamat:
- a regisztráció lezárásakor (a `profiles` rekord beszúrása után) a folyamat `signup_bonus` kóddal olvas összeget és jóváírja.

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- anon felhasználó nem tud SELECT-et.
- authenticated felhasználó nem tud SELECT-et.
- kliens nem tud INSERT/UPDATE/DELETE műveletet.
- szerveroldali folyamat hibát kezel, ha hiányzik a `signup_bonus` rekord vagy `enabled=false`.

## 🌍 Lokalizáció
A `reward_definitions` nem tartalmaz lokalizált szöveget.

A kliens oldali megjelenítéshez a `code` alapján kell lokalizálni (pl. `signup_bonus` → „Regisztrációs bónusz”).

## 📎 Kapcsolódások
- `reward_grants`: a jóváírások naplója `code` alapján hivatkozik a jutalom definícióra
- `user_stats`: a TippCoin egyenleg módosítása a definícióban rögzített `amount` alapján történik
- `user_events`: minden jóváírás eseményt generál (type + code + amount)
- Regisztráció:
  - a `profiles` rekord sikeres létrejötte után automatikus signup bónusz jóváírás a `signup_bonus` definíció alapján

