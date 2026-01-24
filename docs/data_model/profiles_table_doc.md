# Supabase – `profiles` tábla dokumentáció

**Fájl helye a repóban:** `docs/data_model/profiles.md`

Ez a dokumentum a `profiles` tábla felépítését és a hozzá tartozó hozzáférési logikát rögzíti (kód és migráció nélkül).

## 🎯 Funkció
A `profiles` tábla a felhasználó alkalmazáson belüli identitását tárolja, és 1:1-ben kapcsolódik a Supabase Auth felhasználóhoz (`auth.users`).

**Publikusság (kötelező elv):**
- A `nickname` és az `avatar_path` **publikus profiladat**.
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
- **DB-szintű egyediség:** két user nem kaphat azonos nickname-et.
- **Kanonikus formátum:**
  - csak kisbetűs latin betűk, számok és aláhúzás: `a-z`, `0-9`, `_`
  - hossz: **3–20** karakter
  - ékezet, szóköz, kötőjel, pont és egyéb karakter nem engedett
- **Normalizálás:** a kliens a mentés előtt kisbetűsíti.

**Miért kell DB-szintű egyediség?**
- UI oldali előellenőrzés nem védi a race condition-t (két egyidejű foglalás), ezért a végső döntést a DB hozza.

**Módosíthatóság:**
- a `nickname` **nem módosítható**. A felhasználó regisztrációkor választja ki, és a későbbiekben állandó azonosítóként szolgál.

#### 3) `avatar_path` (text)
**Szerep:**
- a felhasználó avatarjának Storage útvonala

**Logika:**
- **kötelező** (nem lehet `NULL`).
- ha a felhasználó nem tölt fel / nem választ avatart, akkor **default avatart** kap regisztrációkor.
- egységes útvonal-séma:
  - bucket: `avatars`
  - object path: `avatars/{userId}/avatar` (kiterjesztéssel vagy stabil névvel; a lényeg, hogy a userId alapján egyértelmű legyen)

**Default avatar kezelése regisztrációkor:**
- a profil rekord létrehozásakor az `avatar_path` mindig értéket kap.
- a default avatar egy **globális** Storage objektum, amit minden user használ, ha nem választ saját avatart:
  - pl. `avatars/default/avatar.png`
- ezt az objektumot a Storage-ban előre biztosítani kell.

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
  - `id`
  - `nickname`
  - `avatar_path`

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
- Más felhasználó felé kizárólag `id`, `nickname`, `avatar_path` jeleníthető meg.

### INSERT (profil létrehozás)
- csak `authenticated`.
- csak akkor engedett, ha a beszúrt rekord `id` mezője megegyezik a bejelentkezett user `auth.uid()` értékével.
- kötelezően megadandó mezők:
  - `nickname`
  - `avatar_path` (regisztrációkor: választott vagy default)
- `created_at` DB default, a kliens nem állítja.

### UPDATE (profil módosítás)
- csak `authenticated`.
- csak a saját rekord módosítható (`id = auth.uid()`).
- módosítható mezők:
  - `avatar_path`
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
- A kliens végezhet foglaltsági előellenőrzést (pl. regisztráció közben), de ez **nem** garantálja a foglalást.
- A végső döntés a DB-szintű egyediség:
  - ha a profil beszúrása `nickname` ütközés miatt hibára fut, a kliens kötelezően új nick választását kéri.
- A kliensnek a foglaltság-ellenőrzést és a végső DB hibát **ugyanarra** az UI üzenetre kell leképeznie ("foglalt").

## 🧩 Regisztrációs flow (profil létrehozás)
A regisztráció sikeres Auth signup-ja után a kliens feladata, hogy létrehozza a profilt, és garantálja az `avatar_path` kitöltését.

Kötelező sorrend:
1) Auth signup/login sikeres → rendelkezésre áll a `userId`.
2) Kliens kiválasztja a `nickname`-et (formátum ellenőrzés kliensben is).
3) Kliens meghatározza az `avatar_path` értékét:
   - ha a felhasználó nem választ / nem tölt fel avatart: **`avatars/default/avatar.png`** kerül a profilba.
   - ha a felhasználó feltölt avatart: a feltöltés célútvonala `avatars/{userId}/avatar...`, és ez kerül a profilba.
4) Kliens beszúrja a `profiles` rekordot (`id=userId`, `nickname`, `avatar_path`).

Hibakezelés (kötelező):
- Ha a `profiles` INSERT sikertelen (pl. foglalt nickname):
  - a kliens nem tekinti késznek a regisztrációt az alkalmazáson belül,
  - a felhasználót visszaviszi nickname választásra és újrapróbálkozik.
- Ha avatar feltöltés sikertelen:
  - a kliens **default avatarral** folytatja (`avatars/default/avatar.png`),
  - és a felhasználó később a profil/beállításokban cserélhet.

## 🖼️ Default avatar szabály
- A default avatar **globális** Storage objektum: `avatars/default/avatar.png`.
- Ha a felhasználó nem állít be saját avatart, a `profiles.avatar_path` **mindig** erre mutat.
- A default objektum a Storage-ban előre létezik, és public read elérhető.

## 🔐 Publikus adatok szabálya
Mivel a `public_profiles` view anon módon is olvasható:
- a view **kizárólag** publikus mezőket tartalmazhat (`id`, `nickname`, `avatar_path`).
- tilos bármilyen későbbi, érzékeny mezőt ebbe a view-ba beemelni.

## 🧪 Tesztállapot
Kötelező ellenőrzések:
- két külön user nem hozhat létre azonos `nickname`-ot.
- user nem tud más user profilját módosítani.
- user nem tudja módosítani az `id` és `created_at` mezőket.
- a `public_profiles` view csak `id`, `nickname`, `avatar_path` mezőket ad vissza.
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

