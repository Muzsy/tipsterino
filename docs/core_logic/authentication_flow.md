# 🎯 Funkció

A Tipsterino authentikációs rendszere két állapotot támogat:

* **GUEST**: nincs aktív Supabase session
* **AUTH_READY**: van aktív session **ÉS** a kötelező profil mezők garantáltan léteznek (**nickname + avatar**)

**AUTH_NO_PROFILE állapot nem létezhet**: a regisztráció csak akkor tekinthető sikeresnek, ha a kötelező mezők már a user létrehozásának pillanatában rögzítve vannak és adatbázis-szinten enforce-olva vannak.

A dokumentáció célja:

* a regisztráció/belépés/verifikáció teljes folyamata
* a vendég vs regisztrált hozzáférések és UI-guardok
* a kötelező profilmezők DB-s garanciája

**Mentési hely (repo):** `docs/core_logic/authentication_flow.md`
Megjegyzés: ha a `docs/core_logic/` mappa még nem létezik a repóban, hozzuk létre (a `docs/README.md` szerint ez a logikai helye).

---

# 🧠 Fejlesztési részletek

## 1) Állapotmodell és alapelvek

### 1.1 Állapotok

* **GUEST**

  * nincs session
  * engedélyezett: Főoldal, Fogadások, Fórum, + a GUEST-only tájékoztató oldal
* **AUTH_READY**

  * van session
  * `profiles.nickname` és `profiles.avatar_*` mezők **mindig** kitöltve
  * engedélyezett: minden oldal a listából (1–9), kivéve a GUEST-only tájékoztató oldal

### 1.2 Kötelező profil mezők (hard rule)

* Nickname: **kötelező + egyedi**
* Avatar: **kötelező**

**Tiltott megoldás:** UI oldali fallback / „majd később kitölti” / placeholder nickname.

## 2) Oldal-hozzáférések (navigáció + UI)

### 2.1 Oldalak

1. Főoldal
2. Fogadások
3. Szelvényeim
4. Profil
5. Beállítások
6. Barátok
7. Klubok
8. Események
9. Fórum

* **GUEST-only:** „Miért érdemes regisztrálni?” (tájékoztató / upsell)

### 2.2 Vendég hozzáférés

GUEST elérheti:

* **Főoldal** (guest variáns)
* **Fogadások** (csak böngészés)
* **Fórum** (ugyanaz a tartalom, mint regisztráltnál)
* **GUEST-only tájékoztató oldal**

GUEST nem érheti el (menüből se látszódjon):

* Szelvényeim, Profil, Beállítások, Barátok, Klubok, Események

### 2.3 Regisztrált hozzáférés

AUTH_READY elérheti:

* mind a 1–9 oldal

AUTH_READY nem érheti el:

* **GUEST-only tájékoztató oldal** (route-guard: redirect Home)

### 2.4 Guard szabályok (kötelező)

* **UI guard**: menü, bottom nav, gombok, csempék állapota (látható/tiltott) a user állapot alapján.
* **Route guard**: deep link / kézi route hívás esetén is enforce.
* **Backend guard (RLS)**: amit guest nem használhat, azt DB szinten sem tudja.

## 3) Fórum – mindenki ugyanazt látja, de a tiltott linkek nem kattinthatók

* A Fórum tartalom (lista + részletek) mindenki számára ugyanaz.
* Vendég esetén:

  * minden olyan UI elem, ami vendég által tiltott oldalra vezetne → **disabled** (nincs tap handler)
  * vizuálisan jelzett „locked” állapot (ikon/opacity), opcionális tooltip/bottom sheet: „Regisztráció után elérhető”.
* Írási műveletek (ha vannak): vendégnél disabled vagy auth gate.

## 4) Főoldal – userstat csempe vs regisztrációs CTA csempe

* AUTH_READY:

  * **UserStat csempe** (TippCoin, win ratio, leaderboard hely, stb.)
* GUEST:

  * **Regisztrációt ösztönző CTA csempe** ugyanazon a helyen
  * kattintás → GUEST-only tájékoztató oldal

További csempék:

* legyen deklaratív konfiguráció: `visible_for: guest|auth|both`, `enabled_for: guest|auth|both`
* vendég számára:

  * egyes csempék látszanak, de nem kattinthatók
  * egyes csempék nem látszanak

## 5) Fogadások oldal – minden esemény látszik, de fogadás tiltva/rejtve

GUEST:

* eseménylista + keresés + szűrés: **engedélyezett**
* fogadás / szelvényre rakás / tipp létrehozás: **tiltott**

  * vagy teljesen **elrejtve**
  * vagy látszik, de **disabled + CTA** („Jelentkezz be a fogadáshoz”)

AUTH_READY:

* teljes funkcionalitás

## 6) Regisztrációs folyamat (email+jelszó + email verifikáció deep linkkel)

### 6.1 Cél

A felhasználó létrehozása során a kötelező profilmezők **már a signup pillanatában** rögzüljenek, így a session megszerzése után mindig AUTH_READY állapot álljon elő.

### 6.2 UI flow (javasolt sorrend)

**A regisztrációs képernyőn a teljes kötelező csomag egyben van összegyűjtve, és a legvégén történik a Supabase `signUp`:**

1. Nickname (kötelező)
2. Avatar választás (kötelező; első körben preset/asset alapú)
3. Email (kötelező)
4. Jelszó (kötelező)
5. ÁSZF/Adatkezelés elfogadás (kötelező)
6. Submit → **Supabase signUp**

**Nickname elérhetőség ellenőrzés**

* UX: már gépelés közben vagy blur-re RPC-val ellenőrizni
* DB: unique constraint az utolsó szó (race condition ellen)

### 6.3 SignUp API kötelező tartalma

* `auth.signUp(email, password, data: { nickname, avatar_key })`
* A `nickname` és `avatar_key` a Supabase `raw_user_meta_data`-ba kerül, amit a DB trigger felhasznál.

### 6.4 Verify pending

SignUp után:

* `VerifyEmailPendingScreen`

  * maszkolt email
  * újraküldés gomb throttle-lal (pl. 60 mp)
  * tippek: spam/promóciók

### 6.5 Email verifikáció + deep link beléptetés

* A verifikációs email CTA magic link, ami deep linkre / web route-ra visz.
* App/Web oldalon `AuthLinkHandler`:

  * bejövő URI parse
  * session recover/verify
  * siker → belépés (AUTH_READY)
  * hiba → lokalizált hibaüzenet + újraküldés opció

### 6.6 Kötelező platform beállítások (rövid)

* Android: intent-filter a custom scheme-re + applink domainre
* iOS: Associated Domains (applinks)
* Web: `/auth/verify` route + well-known fájlok (assetlinks / apple-app-site-association)

## 7) Belépés (email + jelszó)

* `auth.signInWithPassword(email, password)`
* Ha az email nincs verifikálva:

  * állapot: `VERIFY_PENDING`
  * UI: banner + „újraküldés”

## 8) Jelszó reset

* `forgot password` → email reset link
* link megnyitás → új jelszó beállítás → belépés vagy vissza a loginra

## 9) DB-s garanciák (AUTH_NO_PROFILE kizárásának lényege)

### 9.1 `profiles` tábla constraint-ek

* `id` = auth user id (PK)
* `nickname`:

  * `NOT NULL`
  * `UNIQUE`
* `avatar_key` (vagy `avatar_url`/`avatar_id`):

  * `NOT NULL`

### 9.2 Trigger: profile auto-create auth user létrehozásakor

* Trigger az `auth.users` INSERT-re
* Feladat:

  * `raw_user_meta_data.nickname` + `raw_user_meta_data.avatar_key` kiolvasása
  * `INSERT INTO public.profiles (id, nickname, avatar_key, ...) VALUES (...)`
  * ha hiányzik mező vagy ütközik a unique nickname → `RAISE EXCEPTION`

**Eredmény:** ha nincs kötelező adat, a signup tranzakció elhasal → nem jön létre „félkész” user.

## 10) Auth utáni kötelező app-lépés: user-context prefetch + cache (SWR)

Belépés után (first authenticated frame):

* `prefetchUserContext()`

  * profile, settings, coins snapshot, stb. cache-first + háttér refresh
* Logoutnál: user-scoped cache purge

*(A részletes cache/prefetch specifikáció külön docban élhet, de itt rögzítjük, hogy ez a belépés standard része.)*

## 11) Supabase RLS (minimum elvárások)

* GUEST (anon):

  * SELECT engedély a publikus olvasási adatforrásokra (fogadási események, fórum olvasás)
  * minden user-érzékeny táblára: nincs hozzáférés
* AUTH_READY:

  * saját adatok: `auth.uid()` alapú policy
  * közösségi adatok: csak a szükséges public mezők / view-k

---

# 🧪 Tesztállapot

## Manuális tesztek

* [ ] App cold start session nélkül → GUEST navigáció (Home/Bets/Forum + guest-only info)
* [ ] Guest tiltott oldal route → auth gate screen (nincs „részleges” megjelenés)
* [ ] Regisztráció: nickname+avatar+email+jelszó → verify pending → magic link → belépés
* [ ] Belépés verifikálatlan emaillel → verify pending + újraküldés
* [ ] Fórum: tiltott linkek vendégnél nem kattinthatók
* [ ] Fogadások: vendég böngészhet, fogadás gomb rejtett/disabled
* [ ] AUTH_READY: guest-only tájékoztató oldal route → redirect Home
* [ ] Logout → vissza GUEST állapot, cache törölve

## Automatizált tesztek (minimum)

* [ ] AuthLinkHandler unit tesztek (happy path + lejárt/hibás link)
* [ ] Router guard tesztek: guest → protected route redirect
* [ ] DB migration teszt: profiles constraint + trigger enforce (hiányzó meta → fail)

---

# 🌍 Lokalizáció

Új/érintett i18n kulcsok (irányelv):

* `auth.signup_title`, `auth.signin_title`
* `auth.nickname_label`, `auth.avatar_label`
* `auth.verify_pending_title`, `auth.resend_email`, `auth.resend_in`
* `auth.link_expired`, `auth.link_invalid`
* `guest.cta_register_title`, `guest.cta_register_body`
* `guest.only_info_title`, `guest.only_info_cta`
* `access.locked_feature`, `access.login_required`

---

# 📎 Kapcsolódások

* UI képernyők: SignUp, SignIn, VerifyPending, ForgotPassword, GuestOnlyInfo
* Router: route guard (GUEST/AUTH_READY) + deep link route (`/auth/verify` vagy `tipsterino://auth/verify`)
* Supabase:

  * Auth: email confirmations + magic link
  * DB: `profiles` constraint + trigger
  * RLS: guest read vs auth write
* Post-auth: user-context prefetch + local cache (SWR)
