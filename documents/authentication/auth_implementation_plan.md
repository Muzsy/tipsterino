# 🎯 Funkció

Egy **működő autentikációs alap** felépítése a jelenlegi, szinte üres Tipsterino repo-ban:

* **Regisztráció**: 3 lépéses wizard (Email/Jelszó → Nickname/Avatar → Jóváhagyás)
* **Nincs AUTH_NO_PROFILE**: a signup csak a legvégén fut, és DB-szinten garantált a kötelező profil (nickname+avatar)
* **VerifyEmailPending + magic link / deep link** beléptetés
* **Guest mód**: a GUEST felhasználó nem kényszerül loginra; elér 3 oldalt (Home/Bets/Forum) + GUEST-only info
* **Supabase bootstrap**: üres DB-ből indulunk, első migrációk, RLS, trigger-ek

**Javasolt dokumentum helye (repo):** `docs/core_logic/auth_implementation_plan.md`
(Megjegyzés: a `docs/README.md` hivatkozik `core_logic/` mappára, de a zip-ben még nem létezik → létrehozzuk.)

---

# 🧠 Fejlesztési részletek

## 0) Kiinduló állapot (amit most ténylegesen látunk a repo-ban)

* Flutter app: `app/` (Riverpod + GoRouter + supabase_flutter)
* Jelenleg létező auth képernyők (régi mappában):

  * `app/lib/src/screens/auth/login_screen.dart`
  * `app/lib/src/screens/auth/register_screen.dart`
* Auth állapot: `app/lib/src/providers/auth_provider.dart`
* Router: `app/lib/src/router/app_router.dart` (jelenleg *minden* nem-auth route loginra redirectel)
* Dokumentációs struktúra: `docs/README.md` már felsorolja a `core_logic/` témát, de a mappa hiányzik.
* Feature-first szabvány kötelező: `docs/architect/project_structure.md` szerint **új fájlok csak feature-first alá** kerülhetnek.

**Következmény:** az auth-hoz kapcsolódó új kódot már a feature-first struktúrában hozzuk létre, és a meglévő auth fájlokat oda átköltöztetjük.

---

## 1) Munkafázisok és feladatbontás (Te vs Codex)

### FÁZIS A – Supabase projekt bootstrap (külső lépések)

**Cél:** legyen Supabase projekt + auth beállítás + kulcsok, amivel futtatható a flow.

**Te (Ákos) feladataid**

* [ ] Hozz létre egy új Supabase projectet (Dashboard).
* [ ] Auth beállítások:

  * [ ] Email confirmation bekapcsolva.
  * [ ] Site URL + Redirect URLs beállítva a magic linkhez (dev környezethez is).
  * [ ] (később) email template branding – most elég a default.
* [ ] Add át/mentsd ki:

  * [ ] `SUPABASE_URL`
  * [ ] `SUPABASE_ANON_KEY`
* [ ] Dev futtatás: `cd app && flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

**Codex feladatai**

* [ ] Adj hozzá Supabase CLI struktúrát a repo gyökerébe (`supabase/`), ha nincs.
* [ ] Készíts migrációs fájlokat (SQL) a következő fázisokhoz.

**Kimenetek**

* Supabase projekt él, auth működik, URL+key megvan.

---

### FÁZIS B – DB séma + RLS + trigger (AUTH_NO_PROFILE kizárás)

**Cél:** üres DB-ből felépíteni a minimális auth-hoz szükséges adatmodellt.

#### B1) `profiles` tábla és publikus view

**Döntés (most):** avatar **preset** → DB-ben `avatar_key` (nem Storage path). (Storage később bővíthető.)

**Codex feladatai**

* [ ] Migráció: `public.profiles`

  * `id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE`
  * `nickname text NOT NULL UNIQUE` + CHECK (3–20, engedélyezett karakterek)
  * `avatar_key text NOT NULL`
  * `created_at timestamptz NOT NULL DEFAULT now()`
* [ ] Migráció: `public.public_profiles` view (anon olvashatja)

  * mezők: `id`, `nickname`, `avatar_key`
* [ ] RLS bekapcsolás + policy-k:

  * `profiles`:

    * SELECT: csak saját rekord (authenticated)
    * UPDATE: csak saját rekord (avatar_key módosítható, nickname nem)
    * INSERT: kliensnek tiltva (mert trigger csinálja) **vagy** csak saját id-vel engedett (ha mégis kliens csinálja)
  * `public_profiles` view: anon SELECT engedett
* [ ] (Opcionális) RPC: `check_nickname_available(nickname)` → bool (gyors UX ellenőrzés)

**Te (Ákos) feladataid**

* [ ] A migrációkat futtasd fel a Supabase-ra (CLI vagy SQL Editor).
* [ ] Ellenőrzés:

  * [ ] `profiles` létrejött, constraint-ek élnek
  * [ ] `public_profiles` view olvasható anon módon
  * [ ] RLS nem enged „más user módosítást”

#### B2) Trigger: profile auto-create auth signup pillanatában

**Kulcs:** a signup request `user_metadata` mezőiben küldjük a `nickname` + `avatar_key` értékeket. Trigger ezekből hozza létre a profilt.

**Codex feladatai**

* [ ] Migráció: `create_profile_on_signup()` trigger function

  * meta forrás: `raw_user_meta_data->>'nickname'`, `raw_user_meta_data->>'avatar_key'`
  * insert: `profiles(id, nickname, avatar_key)`
  * ha hiányzik bármelyik → `RAISE EXCEPTION`
  * ha nickname unique ütközés → DB hibával elhasal
* [ ] Migráció: trigger `AFTER INSERT ON auth.users` → hívja a functiont

**Te (Ákos) feladataid**

* [ ] Migrations apply után csinálj 1 teszt signupot (később UI-ból).
* [ ] Ellenőrizd, hogy a `profiles` rekord automatikusan létrejön.

**Kimenetek**

* AUTH_NO_PROFILE technikailag kizárva.

---

### FÁZIS C – Feature-first struktúra + auth modul „rendbe rakása”

**Cél:** ne bővítsük tovább a régi `src/screens|providers|router` gyűjtőket.

**Codex feladatai**

* [ ] Hozd létre a feature-first mappákat:

  * `app/lib/src/features/auth/presentation/screens/`
  * `app/lib/src/features/auth/presentation/state/`
  * `app/lib/src/features/auth/presentation/widgets/`
  * `app/lib/src/app/router/` (ha a router migrációt is megcsináljuk most)
  * `app/lib/src/core/` (supabase/auth cross-cutting)
* [ ] Költöztesd át a meglévő auth képernyőket:

  * `login_screen.dart` → auth feature
  * a régi `register_screen.dart` helyére új wizard kerül
* [ ] Költöztesd/migráld a cross-cutting auth állapotot:

  * `src/providers/auth_provider.dart` → `src/core/auth/` (vagy `features/auth/presentation/state/`, ha ott marad)
  * `src/providers/supabase_provider.dart` → `src/core/config/` (vagy hasonló)
* [ ] Frissítsd az importokat, futtasd: `flutter analyze`.

**Te (Ákos) feladataid**

* [ ] Csak review: ellenőrizd, hogy az új fájlok tényleg a feature-first szabvány szerint kerültek-e be.

---

### FÁZIS D – Regisztráció wizard UI (3 lépés, v2)

**Cél:** a korábban rögzített v2 flow pontos UI + state + validáció.

#### D1) Wizard state modell

**Codex**

* [ ] Készíts `SignUpWizardController`-t (Riverpod StateNotifier) ami tartja:

  * step index (0..2)
  * email
  * password
  * nickname
  * avatar_key (default: `neutral`)
  * consents: termsAccepted, privacyAccepted
  * loading/error state

#### D2) 1. képernyő – Email + Jelszó (plaintext)

**Codex**

* [ ] Email validáció marad (legalább `@` ellenőrzés + később szigorítható).
* [ ] Jelszó mező **látható** (nem obscure).
* [ ] Jelszó szabály lista a mező alatt:

  * min 8 karakter
  * 1 betű
  * 1 szám
  * nincs szóköz
* [ ] A lista elemei **eltűnnek** ahogy teljesülnek.
* [ ] `Tovább` disabled, amíg a fenti feltételek nem teljesülnek.

**Te (Ákos)**

* [ ] Döntsd el, hogy a jelszó szabályok pontosan ezek-e (ha változtatni akarsz, most a legolcsóbb).

#### D3) 2. képernyő – Nickname + Avatar

**Codex**

* [ ] Nickname követelmények kiírása (3–20, engedélyezett karakterek, unique)
* [ ] Nickname availability check (RPC ha már kész; ha nincs, akkor csak lokális validáció + majd DB hibára kezelünk)
* [ ] Avatar:

  * default neutral avatar preview
  * preview tap → bottom sheet/dialog grid
  * grid választás mentése → `avatar_key`
* [ ] `Tovább` disabled, amíg nickname valid + szabad.

**Te (Ákos)**

* [ ] Adj 8–16 db preset avatar listát (id + megjelenítés). Ha nincs még, Codex csinál ideiglenes placeholder listát.

#### D4) 3. képernyő – Jóváhagyás + Submit

**Codex**

* [ ] ÁSZF + Adatkezelés checkbox kötelező.
* [ ] Összefoglaló (avatar, nickname, email).
* [ ] Submit → hívja az auth layer `signUp`-ot **csak itt**.

**Te (Ákos)**

* [ ] Add meg az ÁSZF / adatkezelés megjelenítés módját (route / modal / webview). Ha nincs még, legyen stub screen.

---

### FÁZIS E – Auth layer: `signUp` metadata + hibatérkép

**Cél:** a DB trigger miatt a signup payloadban kötelezően benne legyen `nickname` + `avatar_key`.

**Codex feladatai**

* [ ] `AuthNotifier.register(...)` bővítése:

  * param: email, password, nickname, avatarKey
  * call: `client.auth.signUp(email: ..., password: ..., data: {'nickname': ..., 'avatar_key': ...})`
* [ ] Hiba mapping:

  * email foglalt → UI üzenet + login CTA
  * nickname ütközés → wizard step 2-re vissza + field error
  * általános / network / rate limit

**Te (Ákos)**

* [ ] Egyeztesd a hibaüzenetek hangnemét (HU).

---

### FÁZIS F – VerifyEmailPending + deep link beléptetés

**Cél:** signup után a user tudja, hogy verifikálnia kell, és a link megnyitása után belép.

**Codex feladatai**

* [ ] Új képernyő: `VerifyEmailPendingScreen`

  * email megjelenítés (maszkolt)
  * resend (throttle)
  * segítség szöveg
* [ ] Deep link kezelési stratégia (1-et választunk):

  1. **supabase_flutter built-in** callback kezelés (ha elég)
  2. plusz dependency: `app_links` a bejövő linkek biztos feldolgozására
* [ ] Router route-ok:

  * `/auth/verify-pending`
  * (ha kell) `/auth/callback`

**Te (Ákos) feladataid**

* [ ] Supabase Dashboard-ben redirect URL-eket pontosan beállítod (külön android/ios/web dev).
* [ ] Android/iOS platform beállítások (ha a deep linkhez kell):

  * Android intent-filter
  * iOS associated domains
    *(Codex előkészíti a fájlokat, de a „ténylegesen működik-e” validáció nálad fut.)*

---

### FÁZIS G – Router + GUEST mód + minimál shell (mert jelenleg nincs főképernyő)

**Cél:** ne dobjon mindig loginra; guestnek legyen 3 elérhető oldal.

**Codex feladatai**

* [ ] GoRouter redirect új szabályok:

  * **GUEST** (unauthenticated) engedélyezett útvonalak: `/home`, `/bets`, `/forum`, `/guest-info`, `/auth/*`
  * minden más → `/auth/login`
  * **AUTH_READY**: `/guest-info` → redirect `/home`
* [ ] Kétféle bottom nav:

  * Guest tabs: Home / Bets / Forum
  * Auth tabs (később bővül): Home / Tickets / Leaderboard / Settings *(ideiglenesen maradhat)*
  * Megoldás: `AppShell` dinamikus tab listával auth státusz alapján **vagy** külön `GuestShell`.
* [ ] Új stub képernyők, hogy legyen hova navigálni:

  * `BetsScreen` (guest: browse only, auth: később)
  * `ForumScreen` (guest & auth ugyanaz, de tiltott linkek disabled)
  * `GuestInfoScreen` (csak guest)
* [ ] Home minimális tartalom:

  * guest: regisztrációs CTA csempe → `/guest-info`
  * auth: userstat tile placeholder

**Te (Ákos) feladataid**

* [ ] Add meg a GuestInfoScreen szöveg vázát (milyen funkciók nyílnak reg után).

---

### FÁZIS H – Lokalizáció + tesztek

**Codex feladatai**

* [ ] i18n kulcsok hozzáadása: `app/lib/l10n/app_hu.arb`, `app_en.arb`

  * signup step címek
  * password rule sorok
  * nickname rule sorok
  * avatar change
  * verify pending szövegek
  * guest info + CTA
* [ ] Widget tesztek:

  * password rules dinamikus eltűnés
  * step enable/disable
* [ ] Router teszt (ha van keret): guest → protected redirect
* [ ] Integration teszt frissítése (`app/integration_test/app_test.dart`):

  * offline eset: maradhat login screen check
  * configured eset: most már **home/guest** is lehet első képernyő (nem csak login)

**Te (Ákos) feladataid**

* [ ] Futtasd: `flutter analyze`, `flutter test`, `flutter test integration_test/app_test.dart -d <device>`
* [ ] Ha piros, küldd a logot a javításhoz.

---

## 2) Elfogadási kritériumok (Definition of Done)

* [ ] Guest indításkor nem kényszerül loginra; eléri Home/Bets/Forum.
* [ ] Regisztráció wizard végigvihető; a `signUp` csak a 3. lépésben fut.
* [ ] Signup payload tartalmaz `nickname` + `avatar_key` metadata mezőket.
* [ ] DB trigger miatt profil rekord automatikusan létrejön; hiányzó meta esetén a signup elhasal.
* [ ] VerifyEmailPending képernyő működik (resend throttle).
* [ ] Email link megnyitása után a session helyreáll és AUTH_READY állapot jön létre.
* [ ] `flutter analyze` + `flutter test` zöld.

---

# 🧪 Tesztállapot

Induló státusz: **0%** (minden üres vagy placeholder).

Kötelező minimál tesztek a végén:

* [ ] Offline mode: login/registration CTA disabled + offline notice
* [ ] Configured mode: guest home elérhető
* [ ] Signup: végigfut, verify pending megjelenik
* [ ] Auth state váltás: login → home (auth) és logout → guest

---

# 🌍 Lokalizáció

A jelenlegi kulcsok csak login/register alapok. Bővítendő:

* `auth_signup_step_account`, `auth_signup_step_profile`, `auth_signup_step_consents`
* `auth_password_rule_min_len`, `auth_password_rule_has_letter`, `auth_password_rule_has_number`, `auth_password_rule_no_space`
* `auth_nickname_rules_*`
* `auth_avatar_change`
* `auth_verify_pending_*`
* `guest_info_*`, `guest_cta_*`

---

# 📎 Kapcsolódások

* Feature-first szabvány: `docs/architect/project_structure.md`
* Supabase futtatás: `documents/supabase_configuration.md`
* Jelenlegi auth kód (migrálandó):

  * `app/lib/src/providers/auth_provider.dart`
  * `app/lib/src/screens/auth/login_screen.dart`
  * `app/lib/src/screens/auth/register_screen.dart`
  * `app/lib/src/router/app_router.dart`
* Data model alap (frissítendő a triggeres megoldásra): `docs/data_model/profiles_table_doc.md`
