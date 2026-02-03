# Supabase – `user_stats` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/user_stats_table_doc.md`

Ez a dokumentum a `user_stats` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `user_stats` tábla a felhasználóhoz tartozó **játékon belüli állapotot és statisztikákat** tárolja.

**MVP cél:** a felhasználó **TippCoin egyenlegének** megbízható, tranzakcióbiztos nyilvántartása.

A tábla nem közösségi profiladat: **nem publikus**. Az anon felhasználók nem férhetnek hozzá.

## 🧠 Fejlesztési részletek

### Tábla: `public.user_stats`

- **Kapcsolat az Auth-hoz / profilhoz:** `user_stats.user_id` megegyezik az `auth.users.id` értékkel (és ezzel együtt a `profiles.id`-val is).
- **Kardinalitás:** 1 user → 1 user_stats rekord.
- **Törlés:** ha az auth user törlődik, a hozzá tartozó user_stats rekord is törlődik.

### Mezők

#### 1) `user_id` (uuid)
**Szerep:**
- elsődleges kulcs (PK)
- külső kulcs az `auth.users(id)` mezőre (FK)

**Logika:**
- kizárólag a bejelentkezett felhasználó `auth.uid()` értéke lehet.
- **immutábilis** (nem módosítható).

#### 2) `tippcoins` (integer)
**Szerep:**
- a felhasználó aktuális TippCoin egyenlege

**Logika:**
- kötelező, nem lehet `NULL`.
- alapértelmezett érték: **0**.
- nem lehet negatív.

**Frissítés szabálya (kötelező):**
- a `tippcoins` értékét a kliens **nem** módosíthatja közvetlenül.
- minden változás **szerveroldali műveleten** keresztül történik (Edge Function / RPC), atomikusan (increment/decrement).

#### 3) `created_at` (timestamptz, default `now()`)
**Szerep:**
- audit és belső nyilvántartás

**Logika:**
- kizárólag a DB állítja be alapértelmezett értékként.
- **nem módosítható**.

#### 4) `updated_at` (timestamptz, default `now()`)
**Szerep:**
- utolsó statisztika-változás időpontja

**Logika:**
- minden szerveroldali frissítésnél aktualizálódik.
- a kliens nem kezeli.

### Rekord létrehozása (MVP)
A `user_stats` rekord létrehozása **nem kliens oldali művelet**.

Kötelező szabály:
- A `user_stats` rekordot a szerveroldali post-auth init logika hozza létre, amint a user `email_verified` státusza igaz, a kapcsolódó `profiles` adatok (nickname + avatar_key) rendelkezésre állnak, és az első authenticated session szinkronizációja befejeződött.
- A rekord létrehozását atomikusan végrehajtott DB művelet végzi (trigger / security definer logika), így a kliens nem tudja manipulálni az induló állapotot.

Létrehozáskori állapot:
- `user_id = auth.uid()`
- `tippcoins = 0`

Kapcsolat a signup bónusszal:
- A signup bónusz jóváírása ugyanaz a post-auth init logika hajtja végre, amely létrehozza a `user_stats` rekordot; a bónusz akkor aktiválódik, amikor a `email_verified` státusz igaz, és az első authenticated session szerveroldali inicializációja lezárult.
  - `user_stats` rekord biztosítása (create, ha nem létezik)
  - TippCoin jóváírás (atomikus növelés)
  - esemény rögzítése a felhasználói eseményfolyamba

## 🛡️ RLS / Policy logika (kód nélkül)

### RLS állapot
- A `user_stats` táblán RLS **bekapcsolva**.

### Alapelv
- **Olvasás:** a felhasználó a saját statisztikáit olvashatja.
- **Írás:** a kliens **nem** írhat közvetlenül statot; a módosítás szerveroldalon történik.

### SELECT (olvasás)
- `authenticated` felhasználó olvashatja a **saját** rekordját (`user_id = auth.uid()`).
- anon felhasználó nem olvashat.

### INSERT (létrehozás)
- a kliens számára **tiltott**.
- a rekordot kizárólag szerveroldali folyamat hozhatja létre a `profiles` rekord létrejötte után (regisztráció lezárása).

### UPDATE (módosítás)
- `authenticated` felhasználónak **nincs** közvetlen update joga.
- a `tippcoins` és az `updated_at` módosítása kizárólag szerveroldali folyamaton keresztül történik (Edge Function / RPC), ahol a jogosultság és az üzleti logika ellenőrzött.

### DELETE
- a kliens számára **tiltott**.
- felhasználó törlés esetén a kapcsolt rekord eltűnését az Auth törlés + cascade kezeli.

## 🧩 TippCoin műveletek (üzleti logika)
A TippCoin egyenleg változtatására kizárólag szerveroldali műveletek használhatók (Edge Function / RPC / DB trigger), atomikusan.

Kötelező elvek:
- minden változtatásnál ellenőrzött jogosultság (a JWT alapján a saját useren történik a művelet)
- atomikus update (versenyhelyzetben sem veszhet el increment)
- negatív egyenleg nem megengedett
- minden jóváírás/levonás **kötelezően** létrehoz egy felhasználói eseményt (`user_events`) a későbbi "Események" képernyő számára

Kötelező művelet (MVP):
- **signup bónusz jóváírás** a post-auth init logika részeként történik, az email-verifikáció és az első authenticated session szerveroldali inicializációjának befejeződése után

További műveletek (későbbi bővítés):
- napi bónusz jóváírás
- jutalom jóváírás (achievement)
- költés (pl. boost / feature)

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- user létre tudja hozni a saját `user_stats` rekordját, másét nem.
- user csak a saját rekordját tudja olvasni.
- user nem tud közvetlenül `UPDATE`-et végrehajtani.
- `tippcoins` nem lehet negatív.
- szerveroldali jóváírás/levonás után a kliens olvasásból konzisztens értéket kap.

## 🌍 Lokalizáció
Kötelező UI üzenetek (HU/EN) a szerveroldali műveletekhez:
- „Sikertelen jóváírás.”
- „Sikertelen levonás.”
- „Nincs elegendő TippCoin.”

## 📎 Kapcsolódások
- Supabase Auth: `auth.users`
  - a `user_id` az Auth rekordhoz kötött, az `email_verified` státusz pedig a post-auth init logika egyik feltétele
- `profiles`: `profiles.id = user_stats.user_id`
  - a post-auth init folyamat akkor kezdi meg a `user_stats` létrehozását, amikor a kapcsolódó `profiles` rekord (nickname + avatar_key) elkészült
- Jutalmak / bónuszok:
  - `reward_definitions` (összegek, csak repo+migrációval változhat)
  - `reward_grants` (Append-only ledger, ami a signup bónusz és más TippCoin jóváírások naplója)
- `user_events`: minden TippCoin művelet eseményt rögzít, hogy az Üzenetek képernyő megbízható legyen
- `docs/core_logic/bonus_system.md`: a bónuszrendszer single source of truth-ja; ide hivatkozik minden kapcsolatban szereplő dokumentum a verifikáció utáni triggerponton és a folyamatok részleteinél
  - `reward_grants` (egyszeri/ismétlődő jóváírások naplója)
- Felhasználói eseményfolyam:
  - `user_events` (minden TippCoin jóváírás/levonás eseményt generál)
- Szerveroldali folyamat:
  - a post-auth init logika automatikusan gondoskodik a `user_stats` biztosításáról, a verifikáció utáni `signup_bonus` jóváírásról és a `user_events` sorokról
- UI:
  - Home: TippCoin egyenleg megjelenítés (csak bejelentkezett user)
  - Események oldal: TippCoin jóváírások/levonások listázása a `user_events` alapján
