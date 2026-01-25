# 🎯 Funkció

Egy **működő autentikációs alap** felépítése a Tipsterino repóban (jelenleg minimál/üres állapotból):

* **Regisztráció (wizard, v2)**: 3 lépés (Email/Jelszó → Nickname/Avatar → Jóváhagyás)
* **AUTH_NO_PROFILE kizárva**: a `signUp` csak a legvégén fut, és DB-szinten garantált a kötelező profil (nickname + avatar)
* **VerifyEmailPending + magic link / deep link** beléptetés (Android)
* **Guest mód**: GUEST elér 3 oldalt (Home/Bets/Forum) + GUEST-only info
* **Supabase bootstrap**: üres DB-ből indulunk → migrációk, RLS, trigger-ek

**A dokumentum mentési helye (repo):** `documents/authentication/auth_implementation_plan.md`

**Kötelezően figyelembe veendő specifikációk:**

* `docs/core_logic/authentication_flow.md`
* `docs/core_logic/registration_flow.md`

---

# 🧠 Fejlesztési részletek

## 0) Rögzített tények / kiinduló állapot

* A Supabase projekt **már létezik**.
* Site URL + Redirect URLs **beállítva** a magic link / deep link folyamathoz.
* Supabase URL + ANON KEY **megvan és Codex számára be van állítva** → tudja futtatni: `cd app && flutter run`.
* A Supabase adatbázis jelenleg **üres**.
* Az appban jelenleg nincs kész főképernyő/shell; több route még stub.
* Egyelőre **csak Android** a célplatform.
* A repóban létezik a két forrásdoksi:

  * `docs/core_logic/authentication_flow.md`
  * `docs/core_logic/registration_flow.md`

**Fontos eltérés mostantól:** jelszó szabályok frissülnek (lásd D fázis) → a `docs/core_logic/registration_flow.md`-t is frissíteni kell, hogy ne legyen ellentmondás.

---

## 1) Munkafázisok és feladatbontás (Te vs Codex)

### FÁZIS A – Projekt struktúra + auth modul előkészítés (feature-first)

**Cél:** az auth fejlesztés ne a régi gyűjtő mappákba menjen, hanem a feature-first szabványba.

**Codex feladatai**

* [ ] Hozd létre / igazítsd a feature-first mappákat az auth-hoz:

  * `app/lib/src/features/auth/presentation/screens/`
  * `app/lib/src/features/auth/presentation/state/`
  * `app/lib/src/features/auth/presentation/widgets/`
  * `app/lib/src/core/` (supabase/auth cross-cutting)
* [ ] Költöztesd át a meglévő auth fájlokat a feature-first helyükre (vagy hagyj adaptert, de ne duplikálj):

  * `app/lib/src/screens/auth/login_screen.dart`
  * `app/lib/src/screens/auth/register_screen.dart` (ez cserélődik wizardra)
  * `app/lib/src/providers/auth_provider.dart`
  * `app/lib/src/router/app_router.dart` (redirect logika átírása később)
* [ ] Importok frissítése, `flutter analyze` futtatás és hibajavítás.

**Te (Ákos) feladataid**

* [ ] Review: ellenőrizd, hogy minden új fájl a feature-first struktúrába került.

---

### FÁZIS B – Supabase CLI + migrációs rendszer bekötése a repo-ba

**Cél:** a repo-ból futtatható legyen a migrációk létrehozása, futtatása és ellenőrzése (DB üres).

**Codex feladatai**

* [ ] Hozd létre a Supabase CLI struktúrát a repo gyökerében: `supabase/` (mivel a zip-ben még nincs).
* [ ] Linkeld a repót a meglévő Supabase projekthez (project ref / token a Codex környezetben már konfigurálva van).
* [ ] Készíts migrációkat (SQL) és futtasd is őket.
* [ ] Ellenőrzés:

  * [ ] migrációk után SQL ellenőrző lekérdezések futtatása (táblák, constraint-ek, trigger megléte)
  * [ ] RLS policy-k érvényesülnek (negatív teszt: más user adata ne látszódjon)

**Te (Ákos) feladataid**

* [ ] Nincs technikai teendő, csak ha a Codex nem tud linkelni (akkor a project ref-et megadod).

---

### FÁZIS C – DB séma + RLS + trigger (AUTH_NO_PROFILE kizárás)

**Cél:** üres DB-ből felépíteni a minimális auth-hoz szükséges adatmodellt.

#### C1) `profiles` tábla + publikus view

**Döntés:** avatar **preset** → DB-ben `avatar_key` (nem Storage path).

**Codex feladatai**

* [ ] Migráció: `public.profiles`

  * `id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE`
  * `nickname text NOT NULL UNIQUE` + CHECK (3–20, engedélyezett karakterek)
  * `avatar_key text NOT NULL`
  * `created_at timestamptz NOT NULL DEFAULT now()`
* [ ] Migráció: `public.public_profiles` view (anon olvashatja) mezőkkel: `id`, `nickname`, `avatar_key`
* [ ] RLS bekapcsolás + policy-k:

  * `profiles`:

    * SELECT: csak saját rekord (authenticated)
    * UPDATE: csak saját rekord
    * INSERT: kliensnek tiltva (trigger csinálja)
  * `public_profiles` view: anon SELECT engedett
* [ ] (UX támogatás) RPC: `check_nickname_available(nickname)` → bool (debounce check a kliensben)

#### C2) Trigger: profile auto-create signup pillanatában

**Kulcs:** a signup request `user_metadata` mezőiben küldjük a `nickname` + `avatar_key` értékeket. Trigger ezekből hozza létre a profilt.

**Codex feladatai**

* [ ] Migráció: `create_profile_on_signup()` trigger function

  * meta forrás: `raw_user_meta_data->>'nickname'`, `raw_user_meta_data->>'avatar_key'`
  * insert: `profiles(id, nickname, avatar_key)`
  * hiányzó meta → `RAISE EXCEPTION`
  * nickname unique ütközés → DB hibával elhasal
* [ ] Migráció: trigger `AFTER INSERT ON auth.users` → hívja a functiont

#### C3) Supabase ellenőrző tesztek

**Codex feladatai**

* [ ] Migráció futtatás után ellenőrzés (SQL):

  * [ ] `profiles` tábla létezik
  * [ ] `nickname` NOT NULL + UNIQUE + CHECK működik
  * [ ] trigger létezik az `auth.users`-on
  * [ ] anon nem tud `profiles`-ba írni
* [ ] (Opció) Egy valódi signup próbálkozás automatizáltan (ha a környezet engedi):

  * siker esetén `profiles` rekord automatikusan létrejön
  * hiányzó meta esetén signup fail (AUTH_NO_PROFILE kizárás igazolása)

**Te (Ákos) feladataid**

* [ ] Nincs – a futtatás/ellenőrzés Codex feladat.

---

### FÁZIS D – Regisztráció wizard UI (v2 specifikáció alapján)

**Cél:** a `docs/core_logic/registration_flow.md` szerinti flow megvalósítása, a most rögzített módosításokkal.

#### D0) Spec doksik szinkronban tartása

**Codex feladatai**

* [ ] Frissítsd a `docs/core_logic/registration_flow.md` jelszó-szabály részét az új szabályokra (lásd D2), hogy ne legyen ellentmondás.

#### D1) Wizard state modell

**Codex feladatai**

* [ ] Készíts `SignUpWizardController`-t (Riverpod StateNotifier) mezőkkel:

  * `stepIndex (0..2)`
  * `email`
  * `password`
  * `nickname`
  * `avatarKey` (default: `neutral`)
  * `termsAccepted`, `privacyAccepted`
  * `isLoading`, `error`

#### D2) 1. képernyő – Email + Jelszó (plaintext) + dinamikus szabálylista

**Jelszó szabályok (kötelező):**

* **Min. 8 karakter**
* **Legalább 1 kisbetű**
* **Legalább 1 nagybetű**
* **Legalább 1 speciális karakter**

**Codex feladatai**

* [ ] Email validáció marad.
* [ ] Jelszó mező alapértelmezetten **látható** (nem obscure).
* [ ] Jelszó szabálylista a mező alatt:

  * elemek **eltűnnek**, ahogy teljesülnek gépelés közben
* [ ] `Tovább` disabled, amíg minden szabály nem teljesül.

**Te (Ákos) feladataid**

* [ ] Nincs – a szabályok fixen rögzítve fent.

#### D3) 2. képernyő – Nickname + Avatar

**Nickname logika marad**, plusz a formátum követelmények kiírása.

**Codex feladatai**

* [ ] Nickname követelmények kiírása (3–20, engedélyezett karakterek, unique/case-insensitive).
* [ ] Nickname availability check: RPC használata (debounce) + állapotok (checking/available/taken).
* [ ] Avatar:

  * neutral avatar preview (default kiválasztott)
  * preview tap → bottom sheet/dialog grid
  * grid választás mentése → `avatarKey`
* [ ] **Avatar preset lista** létrehozása (8–16 db) a projektben (asset + id), és használata a gridben.
* [ ] `Tovább` disabled, amíg nickname valid + szabad.

**Te (Ákos) feladataid**

* [ ] Nincs – az avatar preset listát Codex készíti.

#### D4) 3. képernyő – Jóváhagyás + Submit

**Codex feladatai**

* [ ] ÁSZF + Adatkezelés checkbox kötelező.
* [ ] Összefoglaló (avatar, nickname, email).
* [ ] Submit → auth layer `signUp` **csak itt**.

**Te (Ákos) feladataid**

* [ ] Ha van kész ÁSZF/Adatkezelés oldalad, add meg a route nevét; ha nincs, Codex csináljon stub screent.

---

### FÁZIS E – Auth layer: `signUp` metadata + hibatérkép

**Cél:** a DB trigger miatt a signup payloadban kötelezően benne legyen `nickname` + `avatar_key`.

**Codex feladatai**

* [ ] `register(...)` / `signUp(...)` metódus:

  * param: email, password, nickname, avatarKey
  * call: `client.auth.signUp(..., data: {'nickname': nickname, 'avatar_key': avatarKey})`
* [ ] Hiba mapping (minimum):

  * email foglalt → UI üzenet + login CTA
  * nickname ütközés (race) → wizard 2. lépés + field error
  * network/timeout/rate limit → lokalizált hiba

**Te (Ákos) feladataid**

* [ ] Nincs – ha a hibaüzenetek stílusán később finomítunk, azt külön.

---

### FÁZIS F – VerifyEmailPending + deep link beléptetés (Android)

**Cél:** signup után a user lássa a teendőt, és a verifikációs link megnyitása után belépjen.

**Codex feladatai**

* [ ] `VerifyEmailPendingScreen`:

  * email (maszkolt)
  * resend throttle
  * help szöveg
* [ ] Deep link feldolgozás:

  * URI parse
  * session recover
  * success → redirect Home
  * error → hiba + resend
* [ ] Android-only beállítások:

  * `AndroidManifest.xml` intent-filter(ek) a deep linkhez

**Te (Ákos) feladataid**

* [ ] Nincs – a Redirect URLs már be vannak állítva.

---

### FÁZIS G – Router + GUEST mód + minimál shell (mert nincs főképernyő)

**Cél:** ne dobjon mindig loginra; guestnek legyen 3 elérhető oldal.

**Codex feladatai**

* [ ] GoRouter redirect szabályok:

  * GUEST engedélyezett: `/home`, `/bets`, `/forum`, `/guest-info`, `/auth/*`
  * más route → `/auth/login`
  * AUTH_READY: `/guest-info` → redirect `/home`
* [ ] Guest shell (3 tab): Home / Bets / Forum
* [ ] Auth shell (ideiglenes minimal, amíg a többi képernyő nincs): Home / Profile / Settings *(stub is ok)*
* [ ] Stub képernyők létrehozása, hogy legyen hova navigálni:

  * `BetsScreen` (guest: browse only)
  * `ForumScreen` (guest & auth ugyanaz; tiltott linkek disabled)
  * `GuestInfoScreen` (csak guest)
  * `HomeScreen` (guest CTA tile vs auth userstat placeholder)

**Te (Ákos) feladataid**

* [ ] Nincs – a GuestInfo alap szöveg alább készen van.

#### GuestInfoScreen – alap szöveg (HU)

**Cím:** „Regisztrációval több funkciót kapsz”

**Törzsszöveg (rövid):**
„Vendégként böngészheted az eseményeket és olvashatod a fórumot. Regisztráció után viszont megnyílnak a közösségi és gamifikációs funkciók, valamint a saját szelvényeid kezelése.”

**Funkciólista (bullet):**

* Saját szelvények mentése és kezelése
* Tippjeid követése, statisztikák és TippCoin egyenleg
* Profil és beállítások
* Barátok, kihívások és közösségi funkciók
* Klubok és események

**CTA gomb:** „Regisztrálok” → regisztráció wizard

**Apró betű:** „Már van fiókod? Bejelentkezés”

---

### FÁZIS H – Lokalizáció + futtatott tesztek (kötelezően zöld)

**Cél:** a teljes flow buildelhető, tesztelhető és stabil.

**Codex feladatai**

* [ ] i18n kulcsok hozzáadása (HU/EN minimum) a wizardhoz, verify pendinghez, guest infohoz.
* [ ] Futtasd és javítsd addig, amíg zöld:

  * `flutter analyze`
  * `flutter test`
  * `flutter test integration_test/app_test.dart -d <device>`
* [ ] Ha a jelenlegi integration teszt a régi „always-login” viselkedésre épül, frissítsd a guest shellnek megfelelően.

**Te (Ákos) feladataid**

* [ ] Csak akkor lépsz közbe, ha a teszt futtatáshoz a Codex nem lát eszközt (`<device>`). Ilyenkor megadod a pontos device id-t.

---

## 2) Elfogadási kritériumok (Definition of Done)

* [ ] Guest indításkor nem kényszerül loginra; eléri Home/Bets/Forum + GuestInfo.
* [ ] Regisztráció wizard végigvihető; a `signUp` csak a 3. lépésben fut.
* [ ] Signup payload tartalmaz `nickname` + `avatar_key` mezőket.
* [ ] DB trigger miatt profil rekord automatikusan létrejön; hiányzó meta esetén signup fail.
* [ ] VerifyEmailPending működik (resend throttle).
* [ ] Email verifikációs link megnyitása után session helyreáll (Android), AUTH_READY állapot jön létre.
* [ ] `flutter analyze`, `flutter test`, integration test: **mind zöld**.

---

# 🧪 Tesztállapot

Kezdő státusz: **0%**.

Pipeline végi kötelező ellenőrzések:

* [ ] Migrációk futottak, SQL ellenőrzések rendben
* [ ] Guest shell navigáció működik
* [ ] Signup flow + verify pending működik
* [ ] Deep link callback (Android) feldolgozható
* [ ] Flutter tesztek zöldek

---

# 🌍 Lokalizáció

Bővítendő kulcsok (minimum):

* `auth_signup_step_account`, `auth_signup_step_profile`, `auth_signup_step_consents`
* `auth_password_rule_min_len`, `auth_password_rule_lower`, `auth_password_rule_upper`, `auth_password_rule_special`
* `auth_nickname_rules_*`
* `auth_avatar_change`
* `auth_verify_pending_*`
* `guest_info_*`, `guest_cta_*`

---

# 📎 Kapcsolódások

* Specifikációk (forrás):

  * `docs/core_logic/authentication_flow.md`
  * `docs/core_logic/registration_flow.md`
* Repo dokumentum helye: `documents/authentication/auth_implementation_plan.md`
* Érintett (migrálandó/átalakítandó) fájlok:

  * `app/lib/src/providers/auth_provider.dart`
  * `app/lib/src/screens/auth/login_screen.dart`
  * `app/lib/src/screens/auth/register_screen.dart`
  * `app/lib/src/router/app_router.dart`
* Integrációs teszt:

  * `app/integration_test/app_test.dart`
