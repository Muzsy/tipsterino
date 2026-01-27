# Registration v2 Verify pending / Resend / Deep link – Checklist

## DoD
- [x] Canvas + Goal YAML lefedi a verify pending resend + callback flow-t.
- [x] A nicknameAvailabilityCheckerProvider közvetlen boolzal tér vissza, és a signup submitter az `io.tipsterino://auth-callback/auth/callback` redirect URI-t használja.
- [x] Létrejött a `verify_email_pending_provider`, a `VerifyEmailPendingScreen` új UI-val és SnackBar/hiba logikával, valamint az `/auth/callback` route + `AuthCallbackScreen`.
- [x] Az új `auth_verify_pending_*` és `auth_callback_*` kulcsok bekerültek az ARB-okba, és lefutott `./scripts/flutter.sh gen-l10n`.
- [ ] `cd app && dart format .` futtatása blokkolva: a Flutter a `/home/muszy/flutter/bin/cache/engine.stamp` fájl írásakor engedélyhibába ütközött.
- [x] `./scripts/check.sh` lefutott (analyze + widget tesztek + új verify pending teszt zöld).

## Feladat-specifikus pontok
- [x] A resend gomb csak email megléte és cooldown nélkül aktív, spinner + SnackBar van siker esetén, hiba a UI-ban megjelenik.
- [x] A cooldown számláló pár másodpercre letiltja a gombot, és a `auth_verify_pending_resend_cooldown` szöveget látni.
- [x] A `/auth/callback` route nem dob 404-et, és hibás query param esetén képes visszajelzést + login gombot mutat.
