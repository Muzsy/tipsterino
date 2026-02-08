# Registration v2 auth signOut documentation checklist

## P0 – Felderítés + canvas
- [x] A logout/signOut implementáció és UI hívási pont ellenőrizve (`auth_provider.dart`, `settings_screen.dart`).
- [x] A canvas tartalmazza a célt, teendőket és gate elvárást: `canvases/registration/registration_v2_auth_signout_documentation.md`.

## P1 – Dokumentációs frissítés
- [x] A `docs/core_logic/authentication_flow.md` kapott külön **Kijelentkezés (signOut)** szekciót.
- [x] A szekció tartalmazza az implementáció helyét (`AuthNotifier.signOut()`), Supabase `auth.signOut()` hívást, UI hívási pontot (`SettingsScreen`) és offline fallback viselkedést.

## P2 – Report + verify
- [x] Elkészült: `codex/reports/registration/registration_v2_auth_signout_documentation.md`.
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/registration/registration_v2_auth_signout_documentation.md`.
- [x] Létrejött verify log: `codex/reports/registration/registration_v2_auth_signout_documentation.verify.log`.
