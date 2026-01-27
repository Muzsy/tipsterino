# Registration v2 Verify pending / Resend / Deep link – Report

## Futtatott parancsok
- `./scripts/flutter.sh gen-l10n`
- `cd app && dart format .` *(hiba: a Flutter a `/home/muszy/flutter/bin/cache/engine.stamp` fájlt írt volna, de „Engedély megtagadva” miatt nem teljesült)*
- `./scripts/check.sh`

## Eredmény
- A `nicknameAvailabilityCheckerProvider` immár a Supabase RPC bool értékét használja, a signup submitter pedig `emailRedirectTo`-val az `io.tipsterino://auth-callback/auth/callback` URI-t célozza (a Supabase redirect allowlistjában ez a URI is fenn kell legyen).
- Készült egy új `verify_email_pending_provider`, amely a cooldown-t, resend hívást, hibát és sikeres visszajelzést kezeli, a verify pending screen pedig SnackBaros visszajelzést, inline hibát és cooldown szöveget mutat, míg az `/auth/callback` route egy visszajelző hibaképernyőt ad.
- A `./scripts/flutter.sh gen-l10n` lefutott, a `cd app && dart format .` parancs megakadt a Flutter engine cache írási engedélyén, a `./scripts/check.sh` analyze + widget tesztek (többek közt az új verify pending/resend teszt) pedig zölden vágta át az összes feladatot.

## Módosított / létrehozott fájlok
1. `canvases/registration/registration_v2_verify_pending_resend_deeplink.md`
2. `codex/goals/canvases/registration/fill_canvas_registration_v2_verify_pending_resend_deeplink.yaml`
3. `codex/codex_checklist/registration/registration_v2_verify_pending_resend_deeplink.md`
4. `codex/reports/registration/registration_v2_verify_pending_resend_deeplink.md`
5. `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
6. `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
7. `app/lib/src/features/auth/presentation/screens/verify_email_pending_screen.dart`
8. `app/lib/src/features/auth/presentation/screens/auth_callback_screen.dart`
9. `app/lib/src/app/router/app_router.dart`
10. `app/lib/l10n/app_en.arb`
11. `app/lib/l10n/app_hu.arb`
12. `app/lib/l10n/app_localizations.dart`
13. `app/lib/l10n/app_localizations_en.dart`
14. `app/lib/l10n/app_localizations_hu.dart`
15. `app/test/widget/auth_verify_pending_resend_test.dart`

## Megjegyzések
- A `cd app && dart format .` parancs futása a Flutter cache `/home/muszy/flutter/bin/cache/engine.stamp` fájl írási jogának hiánya miatt nem sikerült, a többinél nincs probléma.
