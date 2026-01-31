// canvases/registration/registration_v2_full_e2e_device_run.md

# 🎯 Funkció

A regisztráció V2 folyamat **teljes, átfogó E2E** tesztelése fizikai eszközön:
- Signup wizard (Step1–Step3)
- Verify pending (resend + cooldown)
- Verify email link megnyitás → deep link vissza az appba
- Auth callback feldolgozás (success/expired/error)
- Continue → /home és “auth shell” állapot ellenőrzése

Cél: legyen egy **reprodukálható QA runbook + logolási elvárás**, és egy **determininsztikus integration_test** (fakeléssel), ami a flow UI/routing részét automatikusan lefedi.

## Nem cél

- Universal Links / Android App Links (https + assetlinks / AASA)
- E-mail inbox automatizálás (IMAP/SMTP/teszt postaláda integráció)
- Supabase oldali beállítások átírása (csak ellenőrzés + dokumentálás)
- Production security hardening refaktorok (csak ha konkrét E2E bug indokolja)

# 🧠 Fejlesztési részletek

## Releváns fájlok (valós repó alapján)

- Deep link callback URI: `io.tipsterino://auth-callback/auth/callback`
- Android deep link wiring:
  - `app/android/app/src/main/AndroidManifest.xml`
- iOS deep link wiring:
  - `app/ios/Runner/Info.plist`
- Signup wizard:
  - `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
  - `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- Verify pending:
  - `app/lib/src/features/auth/presentation/screens/verify_email_pending_screen.dart`
  - `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- Auth callback:
  - `app/lib/src/features/auth/presentation/screens/auth_callback_screen.dart`
  - `app/lib/src/features/auth/presentation/state/auth_callback_provider.dart`
- Router:
  - `app/lib/src/app/router/app_router.dart`
- QA doc (deeplink fókusz):
  - `docs/qa/registration_v2_deeplink_e2e.md`

## QA dokumentáció bővítés – elvárt tartalom

Hozzunk létre egy külön “full E2E” runbookot:
- `docs/qa/registration_v2_full_e2e.md`

Tartalmazza:
1) Előfeltételek
   - Supabase Redirect URLs allowlist: `io.tipsterino://auth-callback/auth/callback`
   - Fizikai device elérhető `adb devices` / iOS esetén releváns alternatíva
2) Device futtatás parancsok
   - `./scripts/flutter.sh run -d <DEVICE_ID>`
3) Loggyűjtés (Android)
   - `adb logcat -c`
   - futás közben: `adb logcat | grep -E "AuthCallbackHandler|AuthCallback"`
   - elvárt, hogy tokenek ne kerüljenek logba; csak kulcsnevek
4) Teljes flow lépésről lépésre (manual)
   - Home guest → Register
   - Step1 validáció (email/pass)
   - Step2 nickname (regex) + availability
   - Step3 consent + submit → verify pending
   - Resend gomb + cooldown ellenőrzés
   - Verify email link megnyitás → app megnyílik → AuthCallbackScreen
   - Success: Continue → /home
   - Negatív: smoke link token nélkül → expired/error várható
5) Mit kell rögzíteni a logban / reportban
   - callback URI “alakja”: path + query/fragment kulcsnevek (érték nélkül)
   - AuthCallbackScreen státusz: success/expired/error
   - navigáció eredménye (/home elérhető-e)
   - screenshotok opcionálisak, de javasolt

## Automatizált integration_test (determininsztikus, fakes)

Adjunk hozzá egy integration_testet, ami Provider override-okkal:
- végiglép a Signup Wizard Step1–Step3-on
- submit után Verify Pending képernyőt ellenőriz
- opcionálisan átvisz `/auth/callback` route-ra `extra: Uri`-val és fake handlerrel success állapotot ellenőriz

Cél: UI/routing regressziót fogjon, **Supabase és email nélkül**.

## Pipálható feladatlista (DoD)

- [ ] Új QA runbook: `docs/qa/registration_v2_full_e2e.md`
- [ ] `docs/qa/registration_v2_deeplink_e2e.md` hivatkozik a full runbookra + loggyűjtésre
- [ ] Új determininsztikus integration_test a regisztráció V2 flow-ra (fakes)
- [ ] `./scripts/check.sh` zöld
- [ ] (Device) `./scripts/flutter.sh test integration_test -d <DEVICE_ID>` lefut és zöld
- [ ] Manuális full E2E lefut fizikai eszközön, és a report kitöltve (token nélkül!)
- [ ] Codex checklist + report elkészült és kitöltött

## Kockázatok / rollback

Kockázat:
- Flaky UI teszt (animációk / pumpAndSettle időzítés)
- Véletlen token logolás (tilos)

Rollback:
- Debug log sorok eltávolítása, ha bármilyen érzékeny adat megjelenne
- Integration test egyszerűsítése (kevesebb assert), ha flake-el

# 🧪 Tesztállapot

Kötelező:
- `./scripts/check.sh`

Device integration test (javasolt):
- `./scripts/flutter.sh test integration_test -d <DEVICE_ID>`

Manuális E2E:
- `docs/qa/registration_v2_full_e2e.md` szerint, logcat rögzítéssel

# 🌍 Lokalizáció

Nincs új UI szöveg elvárás. (Docs + teszt.)

# 📎 Kapcsolódások

- `docs/codex/overview.md`
- `docs/codex/yaml_schema.md`
- `docs/qa/testing_guidelines.md`
- `docs/qa/registration_v2_deeplink_e2e.md`
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- `app/lib/src/features/auth/presentation/state/auth_callback_provider.dart`
- `app/lib/src/app/router/app_router.dart`
