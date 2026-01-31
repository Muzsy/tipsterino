// canvases/registration/registration_v2_real_e2e_verify_email_run_log.md

# 🎯 Funkció

A regisztráció v2 email-verifikációs folyamata funkcionálisan kész, de a **valódi E2E** (email link → böngésző/redirect → app deeplink → `/auth/callback` → session → auth shell) még nincs **konkrét futtatási loggal** lezárva.

Cél:
1) Valódi E2E verify-email futtatás **valós eszközön / emulátoron** (Android preferált), és a futás **auditálható logolása** (parancsok + kimenet + megfigyelt UI állapot).
2) A `docs/qa/registration_v2_deeplink_e2e.md` pontosítása: a “real verify-email E2E” rész **ne építsen `?email=` feltételezésre**, mert a jelenlegi redirect URI nem ad hozzá email query paramot.

## Nem cél

- Universal Links / App Links (https + assetlinks / apple-app-site-association)
- Platform manifest/plist további módosítása (már bekötve)
- Resend CTA UX újratervezése (csak dokumentáljuk, hogyan működik ma)
- Backend/Supabase policy változtatások (csak allowlist ellenőrzés)

# 🧠 Fejlesztési részletek

## Releváns tények a repóban

- Redirect URI (signup): `io.tipsterino://auth-callback/auth/callback`
- Auth callback route: `/auth/callback`
- Auth callback handler: `getSessionFromUrl(uri)` (Sikernél session beáll)
- Resend CTA az `AuthCallbackScreen`-en **csak akkor jelenik meg**, ha a callback URL tartalmaz `?email=...` query paramot.
  - A valós Supabase verify flow **nem garantál** `email` query paramot a redirectben, így a resend jellemzően a `VerifyPendingScreen`-en történik.

## Mit kell pontosítani a QA docban

Fájl: `docs/qa/registration_v2_deeplink_e2e.md`

- Smoke/Wiring rész maradhat: token nélküli deeplink indítás → elvárt `error/expired`.
- Real verify-email E2E rész:
  - Ne állítsa, hogy `?email=...` lesz a verify linkben.
  - A “valódi” siker kritériuma: `AuthCallbackScreen` → `success` + Continue → `/home` + auth-olt shell.
  - A logolásnál rögzítsük: a callback URI **milyen paramétereket/fragmentet** tartalmazott (pirosítva/szűrve, nem kell tokeneket commitolni).

## Minimális debug logolás a jobb bizonyíthatóságért

Adjunk hozzá minimál-invazív `debugPrint` logokat az auth callback feldolgozásnál, hogy a `flutter run` konzol kimenetben egyértelmű legyen:

- bejövő URI (szanitalva: tokenek nélkül, csak a route + kulcsok neve)
- outcome (success/expired/error) + AuthException code/statusCode ha van

**Fontos:** semmilyen auth token/secret ne kerüljön fájlba, reportba, commitba.

### Log audit javaslat

- Ha a valós E2E lefut, a QA logban rögzítsük a callback URI path-ját, a query/fragment kulcsokat (nem az értékeket), a `AuthCallbackScreen` állapotát (success/expired/error) és hogy megjelent-e a resend gomb.
- Kiemelten jegyezzük fel, ha hiányzik a `?email=` param (a resend CTA emiatt nem jelenik meg), és ha van fragment kulcs (pl. `access_token`), csak a kulcsnevet rögzítjük.
- A debugPrint logok az `AuthCallbackHandler`-ből már alapból ebből a szempontból készített összegzést adnak (URI leírás + outcome), ezt használjuk fel a manuális run során.
## DoD (pipálható)

- [ ] QA doc real E2E része nem vár `?email=`-t; leírja a valós success feltételeket és a resend CTA valós működését.
- [ ] Auth callback feldolgozásnál van minimális debug log (szanitalt, tokenmentes).
- [ ] Elkészült egy új Codex checklist és report, amiben:
  - futtatási parancsok (flutter run / adb / logcat, ha elérhető)
  - E2E futás kimenet rövid összefoglalója
  - megfigyelt UI állapotok (success/expired/error)
  - nincs token/secret a reportban
- [ ] `./scripts/check.sh` PASS

# 🧪 Tesztállapot

Kötelező:
- `./scripts/check.sh`

Manuális (valódi E2E):
- Supabase Dashboard Redirect URL allowlist tartalmazza: `io.tipsterino://auth-callback/auth/callback`
- Android:
  - Smoke: `adb shell am start -a android.intent.action.VIEW -d "io.tipsterino://auth-callback/auth/callback"`
  - Valódi E2E: új signup → email link megnyit → app callback → success
  - (Ha elérhető) `adb logcat` szűrés a callback logokra

# 🌍 Lokalizáció

Nincs UI szöveg változás (csak QA doc + debug log).

# 📎 Kapcsolódások

- `docs/qa/registration_v2_deeplink_e2e.md`
- `app/lib/src/features/auth/presentation/state/auth_callback_provider.dart`
- `app/lib/src/features/auth/presentation/screens/auth_callback_screen.dart`
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `scripts/check.sh`
- `codex/codex_checklist/registration/`
- `codex/reports/registration/`
