# Supabase – `profiles` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/profiles.md`

Ez a dokumentum a `profiles` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `profiles` tábla a felhasználó alkalmazáson belüli identitását tárolja, és 1:1-ben kapcsolódik a Supabase Auth felhasználóhoz (`auth.users`).

**Publikusság (kötelező elv):**
- A `nickname` és az `avatar_key` **publikus profiladat**.
- Ezek az adatok **bárki számára elérhetők** (bejelentkezés nélkül is), mert az alkalmazás anon felhasználóinak is megjelenhetnek közösségi felületeken.

Következmény:
- A `public_profiles` view olvasása anon módon is engedélyezett.
- A Storage-ban az avatarok (beleértve a default avatart) **public read** hozzáférésűek.

## 🧠 Fejlesztési részletek

### Tábla: `public.profiles`

- **Kapcsolat az Auth-hoz:** `profiles.id` pontosan megegyezik az `auth.users.id` értékkel.
- **Kardinalitás:** 1 auth user → 1 profile rekord.
- **Törlés:** ha az auth user törlődik, a hozzá tartozó profile rekord is törlődik.

### Mezők

#### 1) `id` (uuid)
**Szerep:**
- elsődleges kulcs (PK)
- külső kulcs az `auth.users(id)` mezőre (FK)
- minden további user-specifikus tábla ehhez azonosít (globális user-azonosító)

**Logika:**
- az `id` értékét kizárólag a bejelentkezett felhasználó `auth.uid()` értéke adhatja.
- az `id` **nem módosítható** (immutábilis).

#### 2) `nickname` (text)
**Szerep:**
- alkalmazáson belüli, ember által olvasható azonosító
- keresés, barátjelölés, kihívások, üzenetküldés alapja

**Követelmények:**
- **DB-szintű egyediség:** a `profiles_nickname_lower_ux` unique index a `lower(nickname)`-et ellenőrzi, így a név case-insensitiv módon marad egyedi.
- **Kanonikus formátum:** `^[a-z0-9_.]{3,20}$` – csak kisbetűs latin betűk, számok, pont és aláhúzás megengedett, 3–20 karakter között.
- **Normalizálás:** a kliens a mentés előtt kisbetűsíti, így a tárolt érték a regex logikának megfelelően néz ki.

**Miért kell DB-szintű egyediség?**
- UI oldali előellenőrzés nem védi a race condition-t (két egyidejű foglalás), ezért a végső döntést a DB hozza.

**Módosíthatóság:**
- a `nickname` **nem módosítható**. A felhasználó regisztrációkor választja ki, és a későbbiekben állandó azonosítóként szolgál.

#### 3) `avatar_key` (text)
**Szerep:**
- a felhasználó avatar presetjének kulcsazonosítója (pl. `neutral`, `golden_mask`, `arcade`)

**Logika:**
- **kötelező** (nem lehet `NULL`).
- a kliens az előre definiált preset listából választ, a kiválasztott `avatar_key` kerül a Supabase metadata mezőibe (`raw_user_meta_data`) és a trigger is ebből dolgozik.
- ha a user nem választ egyedi avatart, a default `neutral` marad, így az alkalmazásbeli preview sem marad üres.

**Default avatar kezelése regisztrációkor:**
- a profil rekord létrehozásakor az `avatar_key` mindig értéket kap; a DB trigger a `raw_user_meta_data->>'avatar_key'` mezőt használva írja be a preset kulcsot.
- a presetek asset formában a kliensben vannak, így a Supabase oldalra nem kerül Storage útvonal.

#### 4) `created_at` (timestamptz, default `now()`)
**Szerep:**
- audit és belső nyilvántartás

**Logika:**
- kizárólag a DB állítja be alapértelmezett értékként.
- **nem módosítható**.

## 🛡️ RLS / Policy logika (kód nélkül)

### RLS állapot
- A `profiles` táblán RLS **bekapcsolva**.

### Alapelv
- **Olvasás:** minden bejelentkezett felhasználó meg tudja nézni a publikus profiladatokat (kereséshez és közösségi funkciókhoz szükséges).
- **Írás:** minden felhasználó kizárólag a saját profil rekordját hozhatja létre és módosíthatja.

### Publikus olvasás: `public_profiles` view
A közösségi használatra és keresésre a kliens nem közvetlenül a `profiles` táblát olvassa, hanem egy dedikált view-t.

- **View neve:** `public.public_profiles`
- **A view kizárólag az alábbi mezőket adja vissza:**
-  - `id`
-  - `nickname`
-  - `avatar_key`

**Publikusság:**
- A `public_profiles` view olvasása **anon** és **authenticated** felhasználók számára is engedélyezett.
- A view-ban szereplő adatok publikus profiladatnak minősülnek.

### SELECT (olvasás)
- **`public_profiles` view:**
  - bárki olvashatja (anon + authenticated).
  - cél: keresés, lista, profil-kártyák.
- **`profiles` tábla (közvetlen):**
  - a kliens csak a saját rekordját olvassa közvetlenül (profil beállítások, saját profil részletek).

**Mezőszintű elvárás:**
- Más felhasználó felé kizárólag `id`, `nickname`, `avatar_key` jeleníthető meg.

### INSERT (profil létrehozás)
- csak `authenticated`.
- a kliens számára tiltott; a `create_profile_on_signup()` trigger hozza létre a rekordot a Supabase `auth.users` metadatáiból.
- csak akkor engedett, ha a beszúrt rekord `id` mezője megegyezik a bejelentkezett user `auth.uid()` értékével.
- kötelezően megadandó mezők:
-  - `nickname`
-  - `avatar_key` (regisztrációkor: a kiválasztott preset kulcs)
- `created_at` DB default, a kliens nem állítja.

### UPDATE (profil módosítás)
- csak `authenticated`.
- csak a saját rekord módosítható (`id = auth.uid()`).
- módosítható mezők:
-  - `avatar_key`
- nem módosítható mezők:
  - `id`
  - `nickname`
  - `created_at`

### DELETE
- a kliens számára **tiltott**.
- felhasználó törlés esetén a kapcsolt rekord eltűnését az Auth törlés + cascade kezeli.

## 🔎 Kereshetőség (alkalmazáslogika)
A nickname keresés kizárólag a `public_profiles` view-n történik.

Kötelező szabályok:
- minimum keresési hossz: **3 karakter**
- pagination: kötelező (limit + offset vagy cursor)
- rendezés: `nickname` szerint
- egyezés: prefix + részleges egyezés támogatott

### Nickname foglaltság és ütközéskezelés
- A kliens végezhet foglaltsági előellenőrzést (pl. regisztráció közben) a `public.check_nickname_available(nickname)` RPC segítségével, de ez **nem** garantálja a foglalást.
- A végső döntés a DB-szintű egyediség:
  - ha a profil beszúrása `nickname` ütközés miatt hibára fut, a kliens kötelezően új nick választását kéri.
- A kliensnek a foglaltság-ellenőrzést és a végső DB hibát **ugyanarra** az UI üzenetre kell leképeznie ("foglalt").

### `check_nickname_available` RPC
- A `public.check_nickname_available(text)` függvény `SECURITY DEFINER`-ként fut, a `search_path` pedig a `public, auth` schema, így a RLS aktív táblán is teljes tartalmat lát.
- Anon és authenticated felhasználók számára `grant execute` van beállítva, így a wizard mindkét állapota képes lekérdezni a nick foglaltságát.
- A függvény csak boolean ellenőrzést ad, a végső versenyhelyzetet a trigger + unique index dobja.

## 🧩 Regisztrációs flow (profil létrehozás)
A Supabase `auth.users` INSERT után a `create_profile_on_signup` trigger automatikusan létrehozza a `profiles` rekordot a `raw_user_meta_data->>'nickname'` és `->>'avatar_key'` mezők alapján, tehát a kliens **nem** futtat INSERT-et közvetlenül.

Kötelező sorrend:
1) Auth signup sikeres → elérhető a `userId`.
2) A kliens kiválasztja a `nickname`-et (format validation a kliens oldalon is).
3) A kliens beállítja az `avatar_key` értéket a preset listából (default `neutral`).
4) A `signUp` metadata mezői (`nickname`, `avatar_key`) átkerülnek a `auth.users` rekordba, a trigger pedig ezeket használva beszúrja a `profiles` rekordot.

Hibakezelés (kötelező):
- Ha a trigger hiányzó metadata miatt exception-t dob, a kliens visszaugrik a profil lépésre és felajánlja a `nickname`/`avatar_key` beállítást.
- Nickname ütközés (UNIQUE) esetén a trigger hiba és a kliens ugyanoda navigál, hogy új nick-et válasszon.
- Ha a preset kiválasztás hiányzik, a trigger alapértelmezett `neutral` értéket használ, így mindig van valid `avatar_key`.

## 🖼️ Default avatar szabály
- A default avatar preset kulcsa: `neutral`. A preset asset a kliensben található, a Supabase oldalra csak az `avatar_key` kerül.
- Ha a felhasználó nem választ saját avatart, a `profiles.avatar_key` **mindig** `neutral`.
- A presetek (including `neutral`) public preview képek lehetnek a kliensben, de az adatbázis nem tárol Storage útvonalat.

## 🔐 Publikus adatok szabálya
Mivel a `public_profiles` view anon módon is olvasható:
- a view **kizárólag** publikus mezőket tartalmazhat (`id`, `nickname`, `avatar_key`).
- tilos bármilyen későbbi, érzékeny mezőt ebbe a view-ba beemelni.

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- két külön user nem hozhat létre azonos `nickname`-ot.
- user nem tud más user profilját módosítani.
- user nem tudja módosítani az `id` és `created_at` mezőket.
- a `public_profiles` view csak `id`, `nickname`, `avatar_key` mezőket ad vissza.
- keresésnél a minimum 3 karakteres szabály érvényesül a kliensben (UI/UX szinten).

## 🌍 Lokalizáció
Kötelező UI üzenetek (HU/EN):
- „A becenév foglalt.”
- „A becenév csak kisbetűt, számot és _ karaktert tartalmazhat (3–20).”
- „Sikertelen profilmentés.”
- „Sikertelen avatar feltöltés.”

## 📎 Kapcsolódások
- Supabase Auth: `auth.users`
- Supabase Storage: `avatars` bucket
  - **public read** (bárki letöltheti/megnézheti)
  - **write csak authenticated + csak saját user mappa**
  - default avatar objektum: publikus, előre feltöltve
- UI képernyők:
  - regisztráció: nickname választás + avatar választás/feltöltés vagy default
  - profil/beállítások: avatar csere
  - közösség: keresés `public_profiles` view-n keresztül
