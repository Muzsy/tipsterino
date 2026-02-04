# Bonus system Flutter post-auth init checklist

## P1 – Canvas + RPC plan
- [x] A `canvases/bonus_system/bonus_system_flutter_post_auth_init.md` dokumentációja most részletesen leírja a post-auth init triggerpontot, az RPC nevét (`grant_signup_bonus_if_eligible`) és a reason logging/silent UX elvét.
- [x] A canvasban szerepel, hogy az `AuthNotifier` inicializációkor és az `onAuthStateChange` streamben hívja meg a runner-t, nem blokkolva az auth állapotot.

## P2 – Implementációs blokkok
- [x] `app/lib/src/features/rewards/data/signup_bonus_rpc.dart` + `.../domain/signup_bonus_grant_result.dart` készen állnak; a config nélküli state `not_configured` eredményt ad vissza.
- [x] `app/lib/src/features/rewards/application/post_auth_init_provider.dart` megvalósítja a `PostAuthInitNotifier`-t az `isRunning` guarddal és a `lastResult/lastError` állapottal.
- [x] `app/lib/src/features/auth/presentation/state/auth_provider.dart` immár meghívja a runner-t `unawaited` módon, csak konfigurált Supabase esetén.
- [x] A `docs/core_logic/registration_flow.md` megfelel az új flow-nak.
- [x] `app/test/unit/bonus_system_post_auth_init_test.dart` lefedi a granted/not_verified/exception path-okat a stub RPC callerrel.

## P3 – QA gate
- [x] `./scripts/check.sh` lefutott.
