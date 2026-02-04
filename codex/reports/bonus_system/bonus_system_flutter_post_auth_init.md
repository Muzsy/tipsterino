## Mit találtunk?
- A `AuthNotifier` initja és `onAuthStateChange` streamje jelenleg sem blokkolja a post-auth logikát, így a runner-nek a `unawaited` hívása sem akadályozza az auth flow-t.
- A Supabase RPC (`grant_signup_bonus_if_eligible`) már létezik, ezért a kliens csak egy `Session`-t ad át a `PostAuthInitNotifier`-nek, amely a `velocity` guard miatt nem tud párhuzamos hívást indítani.

## Mit módosítottunk?
- Bővítettük a canvas-t az RPC nevét, a verified mezőket (`email_confirmed_at` / `confirmed_at`), az indexet és a silent logging elvet szem előtt tartva.
- Készítettünk `signup_bonus_rpc.dart` + `signup_bonus_grant_result.dart` fájlokat, amelyek a Supabase klienten keresztül hívják `grant_signup_bonus_if_eligible`-t, és `not_configured` eredménnyel térnek vissza, ha a config hiányzik.
- Implementáltuk a `PostAuthInitNotifier`-t (`isRunning` guard + `lastResult`/`lastError`) és bekötöttük az `AuthNotifier`-ba (`unawaited` hívás csak konfigurált Supabase esetén), így a concurrency aggályokat kezeli a runner.
- Dokumentáltuk a post-auth init flow-t a `docs/core_logic/registration_flow.md` fájlban és készült unit teszt az új `PostAuthInitNotifier`-hez.

## Módosított/létrehozott fájlok
- `canvases/bonus_system/bonus_system_flutter_post_auth_init.md`
- `app/lib/src/features/rewards/data/signup_bonus_rpc.dart`
- `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
- `app/lib/src/features/rewards/application/post_auth_init_provider.dart`
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `docs/core_logic/registration_flow.md`
- `app/test/unit/bonus_system_post_auth_init_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_flutter_post_auth_init.md`
- `codex/reports/bonus_system/bonus_system_flutter_post_auth_init.md`

## Tesztek
- `./scripts/check.sh` – PASS (repo standard gate: analyze + widget tesztek)

## Következő javasolt lépések
1. Integrálni a runner-t az actual post-auth init edge function/telemetry (ha még nincs) és monitorozni a `reason` mezőket.
2. Ha szükséges, a `SignupBonusGrantResult`-ból származó `amount`/`reason`-t továbbítsd a kliens logging moduljához.
