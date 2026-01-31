// canvases/registration/registration_v2_platform_deeplink_config_audit.md

# 🎯 Funkció

A regisztráció v2 email-verifikációs flow **valós E2E** működéséhez hiányzó platformszintű deep link konfiguráció bevezetése.

Cél: amikor a felhasználó rákattint a Supabase verifikációs email linkjére, a mobil app megnyíljon és a deep link **a meglévő** `/auth/callback` route-ra érkezzen, az alábbi redirect URI-val:

`io.tipsterino://auth-callback/auth/callback`

**Eredmény:** a Step3 → Verify pending → email link → Auth callback screen lánc device-on/emulátoron tényleg validálható.

## Nem cél

- Universal links / Android App Links (https + assetlinks / apple-app-site-association)
- Server oldali resend rate limit
- Supabase dashboard beállítások “helyettünk” (csak dokumentáljuk/checklisteljük)
- Új deep link plugin (`app_links`, `uni_links`) bevezetése (jelen setup GoRouter + natív deep link elég)

# 🧠 Fejlesztési részletek

## Releváns állapot (reality-check a kódban)

- A signup már átadja mobilon az `emailRedirectTo` paramétert:
  - `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
  - redirect: `io.tipsterino://auth-callback/auth/callback`
- A routerben már létezik `/auth/callback` route, és külön `AuthCallbackScreen` kezeli a flow-t.
- **Hiányzik** a platform fogadókészsége:
  - Android: `AndroidManifest.xml`-ben nincs VIEW intent-filter a `io.tipsterino` scheme-re
  - iOS: `Info.plist`-ben nincs `CFBundleURLTypes` (custom URL scheme)

## Implementáció – Android

Fájl: `app/android/app/src/main/AndroidManifest.xml`

A `MainActivity`-hez adj hozzá egy **külön** intent-filtert (a MAIN/LAUNCHER mellé), ami fogadja:

- `scheme`: `io.tipsterino`
- `host`: `auth-callback`
- `pathPrefix`: `/auth/callback`

Követelmények:
- Ne bontsd meg a meglévő MAIN/LAUNCHER intent-filtert.
- Ne változtasd meg a meglévő activity attribútumokat (launchMode, exported, stb.), csak bővíts.

## Implementáció – iOS

Fájl: `app/ios/Runner/Info.plist`

Adj hozzá `CFBundleURLTypes` blokkot `io.tipsterino` sémával.

Követelmények:
- Ha a kulcs nem létezik, hozd létre.
- Ha létezik, bővítsd úgy, hogy a `io.tipsterino` scheme benne legyen.
- Minimalista: csak a szükséges URL scheme.

## Dokumentáció

Frissítendő doksik:

- `docs/core_logic/authentication_flow.md`
  - A “kötelező platform beállítások” rész legyen konkrét a jelenlegi redirect URI-hoz.
- `docs/core_logic/registration_flow.md`
  - A verify/deeplink részben szerepeljen az aktuális redirect URI és a platform követelmény.
- `documents/registration/registration_flow_V2-md`
  - E2E validálási lépések és a pontos URI rögzítése (ne “Android-only” félmondatok legyenek).

Plusz új QA leírás:
- `docs/qa/registration_v2_deeplink_e2e.md`
  - Android adb + iOS sim (xcrun) parancsok, tesztállapotok (app zárt/nyitott), elvárt UX (expired/error/success).

## Pipálható feladatlista (DoD)

- [ ] AndroidManifest: VIEW/BROWSABLE intent-filter bevezetve `io.tipsterino://auth-callback/auth/callback`-re.
- [ ] Info.plist: `CFBundleURLTypes` bevezetve `io.tipsterino` scheme-re.
- [ ] Doksik frissítve (auth flow + reg flow + registration v2 dokumentum).
- [ ] Új QA doc elkészült: manuális E2E deep link teszt lépések és parancsok.
- [ ] `./scripts/check.sh` zöld.
- [ ] (Ha Android toolchain elérhető) `cd app && flutter build apk --debug` zöld.
- [ ] Checklist + report elkészült.

# 🧪 Tesztállapot

Automata (kötelező):
- `./scripts/flutter.sh gen-l10n`
- `./scripts/check.sh`

Build sanity (opcionális, ha van Android toolchain):
- `cd app && flutter build apk --debug`

Manuális E2E (doksi szerint):
- Supabase Redirect URLs allowlist tartalmazza:
  - `io.tipsterino://auth-callback/auth/callback`
- Android: adb deep link indítás (app zárt/nyitott)
- iOS: simctl openurl (ha macOS környezet)

# 🌍 Lokalizáció

Nincs új UI szöveg. (Csak doksi / platform config.)

# 📎 Kapcsolódások

- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart` (emailRedirectTo)
- `app/lib/src/app/router/app_router.dart` (route: `/auth/callback`)
- `app/android/app/src/main/AndroidManifest.xml`
- `app/ios/Runner/Info.plist`
- `docs/core_logic/authentication_flow.md`
- `docs/core_logic/registration_flow.md`
- `documents/registration/registration_flow_V2-md`
- Külső: Supabase Dashboard → Auth → URL Configuration / Redirect URLs (allowlist)
