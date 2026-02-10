# 🎯 Funkció

A Tipsterino regisztráció **3 lépéses wizard** formában történik, úgy hogy **AUTH_NO_PROFILE állapot ne jöhessen létre**.

**Kötelező alapelv:** a Supabase `signUp` hívás **csak a legvégén** történik meg, amikor már minden kötelező adat rendelkezésre áll:

* Email
* Jelszó
* Nickname (kötelező + egyedi)
* Avatar (kötelező; először preset, neutral defaultból indul)
* ÁSZF + Adatkezelés elfogadás

Sikeres regisztráció után a felhasználó **VerifyEmailPending** képernyőre kerül, és email verifikáció (magic link / deep link) után lép be.

**Dokumentum mentési hely (repo):** `docs/core_logic/registration_flow.md`

---

# 🧠 Fejlesztési részletek

## 0) Áttekintés

### Lépések sorrendje

1. **Fiók adatok**: Email + Jelszó
2. **Profil**: Nickname + Avatar
3. **Jóváhagyás**: ÁSZF + Adatkezelés + Submit

**Fontos:** a 1. és 2. lépésben csak lokálisan gyűjtünk adatot. A Supabase user létrehozás (signUp) **a 3. lépés CTA-jánál** fut.

### Legacy minimal register út (P0 döntés)

`AuthNotifier.register()` metadata nélküli, email+jelszó alapú signup ága kivezetésre került.
Kötelező szabály: a kliensben nincs külön "minimal register" út, a `/auth/register`
mindig a `SignUpWizardScreen`-re mutat, ahol a `nickname` + `avatar_key` kötelező
adatok a signup payload részei.

---

## 1) 1. lépés – Email + Jelszó

### UI elemek

* AppBar cím: `Regisztráció`
* Stepper: `1/3 – Fiók`
* **Email input**

  * validáció: alap email forma ("@" + domain)
  * hiba: `Érvénytelen email`
* **Jelszó input (látható beíráskor)**

  * alapértelmezetten **nem maszkos** (plaintext)
  * opcionális: szem ikon *megengedett*, de default állapot: látható

### Jelszó kritériumok (dinamikus checklist)

A jelszó mező alatt egy **kritérium lista**, ami a gépelés közben **eltűnik** tételenként, ahogy teljesül.

Javasolt kritériumok (minimálisan fájdalommentes, de értelmes):

  * [ ] **Minimum 8 karakter**
  * [ ] **Legalább 1 kisbetű**
  * [ ] **Legalább 1 nagybetű**
  * [ ] **Legalább 1 speciális karakter**

Megjelenítés:

* kezdetben mind látszik
* teljesüléskor az adott sor:

  * vagy eltűnik (preferált),
  * vagy átvált pipára és csak a nem teljesülők maradnak (vizuálisan stabilabb)

### CTA

* Gomb: `Tovább`
* Disabled amíg:

  * email valid
  * jelszó minden kritériumnak megfelel

### Nincs jelszó megerősítés

* **Nem kérünk jelszó ismétlést**.
* Hibamegelőzés: a jelszó látható beíráskor + checklist.

---

## 2) 2. lépés – Nickname + Avatar

### UI elemek

* Stepper: `2/3 – Profil`

### Nickname input (kötelező + egyedi)

A korábban egyeztetett nickname logika marad, plusz a **formátum követelmények** kiírása.

#### Követelmények (UI-ban is látszódjon)

Javasolt szabályok:

* 3–20 karakter
* Engedélyezett: betű, szám, `_` és `.`
* Szóköz nincs
* Case-insensitive egyediség (pl. `Akos` és `akos` ütközésnek számít)

#### Elérhetőség ellenőrzés

* Debounce (pl. 500 ms)
* Állapotok:

  * `Ellenőrzés…`
  * `Szabad`
  * `Foglalt`
* Foglalt esetén: javaslatok (suffix szám, pl. `akos_12`)

### Avatar választás (kötelező, neutral defaultból indul)

#### Alapállapot

* A képernyőn egy **semleges alap avatar** van kiválasztva (pl. silhouette)
* Mellette gomb/affordance: `Módosítás`

#### Interakció

* Az alap avatart vagy a `Módosítás` gombot megnyomva felugrik egy **avatar választó grid**

  * megjelenítés: bottom sheet vagy dialog
  * grid: 3–4 oszlop, preset avatar készlet
  * kiválasztáskor highlight + pipa
  * `Mentés` / `Kész` gomb bezárja és átállítja a választást

#### Tárolt érték

  * `avatar_key` (preset azonosító, pl. `neutral`, `golden_mask`) kerül eltárolásra és később a `signUp` metadata része; a kliens a preset listából választja ki, nem Storage útvonalat küld.

### CTA

* Gomb: `Tovább`
* Disabled amíg:

  * nickname valid + szabad
  * avatar_key be van állítva (neutral default már teljesíti)

---

## 3) 3. lépés – Jóváhagyás + Submit

### UI elemek

* Stepper: `3/3 – Jóváhagyás`

### Kötelező checkboxok

* [ ] ÁSZF elfogadása (link/modal/webview)
* [ ] Adatkezelési tájékoztató elfogadása (link/modal/webview)

### Opcionális

* [ ] Marketing / értesítések (későbbi döntés)

### Összefoglaló

* Avatar preview
* Nickname
* Email (opcionálisan maszkolva)

### Fő CTA

* Gomb: `Fiók létrehozása`
* Kattintáskor:

  * loading state (spinner)
  * input lock

### Supabase signUp (kötelező payload)

A hívás csak itt történik:

* `signUp(email, password, data: { nickname, avatar_key })`

**Követelmény:** DB oldalon trigger/constraint enforce-olja, hogy profil létrejön és a nickname unique + avatar not null.

### Hiba kezelés (minimum)

* Email már foglalt: `Ezzel az emaillel már van fiók` + CTA: `Bejelentkezés`
* Nickname ütközés (race condition): vissza 2. lépésre, mezőhibával
* Network / timeout: `Hálózati hiba, próbáld újra`
* Rate limit: `Próbáld később`

---

## 4) VerifyEmailPending kezelés (változatlan)

SignUp siker → `VerifyEmailPendingScreen`

* email megjelenítés (maszkolt)
* `Újraküldés` gomb (throttle, pl. 60 mp)
* deep link / magic link kezelő
* link hiba esetén: lokalizált üzenet + újraküldés

### 4.1 Deep link platform konfiguráció

* A Supabase `signUp` hívásban használt `emailRedirectTo` érték: `io.tipsterino://auth-callback/auth/callback`. Ez a deep link érkezik a kliensbe, és közvetlenül a GoRouter `/auth/callback` útvonalát hivatott megnyitni.
* A Supabase Auth Redirect URLs listájába ezért fel kell venni ezt az URI-t, különben a verifikációs link hibát dob vagy nem fut le az appban.
* Android: a `app/android/app/src/main/AndroidManifest.xml`-ben a `MainActivity` mellé meg kell adni egy `VIEW` intent-filtert, amely a `io.tipsterino` scheme-re, `auth-callback` hostra és `/auth/callback` pathPrefix-re van beállítva (DEFAULT + BROWSABLE kategóriákkal), így a CLI-s linkek és a Supabase visszahívás ugyanazzal a route-tal találkozik.

## 5) Post-auth init (signup bónusz RPC)

Az email verifikációt követő első authenticated session során a kliens egy *post-auth init* lépést futtat, amely nem blokkolja az auth állapot frissülését. Az `AuthNotifier` az auth state streamben (és inicializációkor, ha a `currentSession` már létezik) az app-szintű `PostAuthStartupNotifier`-t hívja (`app/lib/src/app/startup/post_auth_startup_provider.dart`), ami valid session esetén delegál a rewards feature `PostAuthInitNotifier`-ének.

A RPC:

* az `auth.users` email igazolt státuszát ellenőrzi (`email_confirmed_at` / `confirmed_at`)
* lefedi az idempotens `reward_grants` `/reward_grants_user_id_code_unique` konfliktusokat
* biztosítja a `user_stats` sort, növeli a TippCoin egyenleget és létrehozza a `user_events` (`tippcoin_credit` + `signup_bonus`) eseményt

A kliens csak a strukturált eredményt (`granted`, `amount`, `reason`) logolja/eltárolja, de nem jelenít meg UI üzenetet; a részletek és a trigger zajlása a serveroldali RLS és RPC lekérdezésekben zajlanak.
---

## 6) Megjegyzés a „nincs AUTH_NO_PROFILE” szabályhoz

Bár a flow első lépése email+jelszó, a user **nem jön létre** addig, amíg a nickname+avatar és a kötelező jóváhagyások nincsenek meg.

Ezért:

* nincs olyan állapot, hogy „be van lépve, de nincs profil”
* a `signUp` hívás mindig tartalmazza a kötelező metadata mezőket

---

# 🧪 Tesztállapot

## Manuális tesztek

* [ ] 1. lépés: email validáció működik
* [ ] 1. lépés: jelszó checklist tételei sorban eltűnnek teljesüléskor
* [ ] 1. lépés: nincs jelszó megerősítés, jelszó látható beíráskor
* [ ] 2. lépés: nickname format követelmények látszanak
* [ ] 2. lépés: nickname availability check állapotok működnek
* [ ] 2. lépés: neutral avatar alapból be van állítva
* [ ] 2. lépés: avatar grid felugrik, kiválasztás mentődik
* [ ] 3. lépés: kötelező checkboxok nélkül nem lehet submit
* [ ] Submit: `signUp` payload tartalmazza `nickname` + `avatar_key`
* [ ] Verify pending képernyő elérhető, resend throttle működik

## Automatizált tesztek (minimum)

* [ ] Password criteria matcher unit teszt
* [ ] Nickname format validator unit teszt
* [ ] Router/flow teszt: step enable/disable logika

---

# 🌍 Lokalizáció

Javasolt i18n kulcsok:

* `signup.step.account`, `signup.step.profile`, `signup.step.consents`
* `signup.email.label`, `signup.password.label`
* `signup.password.rules.title`, `signup.password.rules.min_len`, `signup.password.rules.has_letter`, `signup.password.rules.has_number`, `signup.password.rules.no_space`
* `signup.nickname.label`, `signup.nickname.rules.title`, `signup.nickname.rules.len`, `signup.nickname.rules.allowed`, `signup.nickname.rules.no_space`, `signup.nickname.rules.unique`
* `signup.avatar.label`, `signup.avatar.change`
* `signup.next`, `signup.create_account`

---

# 📎 Kapcsolódások

* Kapcsolódó dokumentum: `docs/core_logic/authentication_flow.md` (átfogó auth + guard + RLS)
* Képernyők:

  * `SignUpWizard` (3 lépés)
  * `VerifyEmailPendingScreen`
  * `SignInScreen` / `ForgotPassword`
* Supabase:

  * Auth signUp metadata (`nickname`, `avatar_key`)
  * DB trigger/constraint a profil automatikus létrehozására
  * RLS policy-k (guest read / auth restricted)
