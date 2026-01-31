# Registration v2 platform deeplink config audit checklist

## C1 – Platform deep link wiring
- [x] `app/android/app/src/main/AndroidManifest.xml` a `MainActivity`-hez VIEW intent-filtert kapott a `io.tipsterino://auth-callback/auth/callback` URI fogadására (DEFAULT + BROWSABLE kategóriák).
- [x] `app/ios/Runner/Info.plist` `CFBundleURLTypes` blokkjában a `io.tipsterino` URL scheme regisztrálva van.

## C2 – Dokumentáció és QA
- [x] `docs/core_logic/authentication_flow.md`, `docs/core_logic/registration_flow.md` és `documents/registration/registration_flow_V2-md` expliciten leírják a `io.tipsterino://auth-callback/auth/callback` redirect URI-t, a Supabase allowlisztet és a platformkonfiguráció lépéseket.
- [x] `docs/qa/registration_v2_deeplink_e2e.md` tartalmazza a Supabase allowlist ellenőrzését, az Android `adb` és iOS `xcrun simctl` parancsokat, valamint az elvárt UX-et sikeres/hibás link esetén.

## C3 – Gate
- [x] `./scripts/flutter.sh gen-l10n`
- [x] `./scripts/check.sh`
- [ ] `cd app && flutter build apk --debug` *(nem futott: környezetben nincs megbízható Android toolchain)*
