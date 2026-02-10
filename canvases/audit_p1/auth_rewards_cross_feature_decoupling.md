# Audit P1-3: auth-rewards cross-feature decoupling

## 🎯 Funkcio
Celfeladat: az auth es rewards feature kozvetlen osszecsatolasanak csokkentese app-szintu startup orchestratorral es feature public API (barrel) bevezetesével.

Nem cel:
- auth flow UI atalakitasa
- bonus RPC uzleti logika atirasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/rewards/application/post_auth_init_provider.dart`
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/unit/bonus_system_post_auth_init_test.dart`
- `docs/architect/project_structure.md`
- `docs/core_logic/registration_flow.md`

Tervezett kimenetek:
- uj startup orchestrator: `app/lib/src/app/startup/post_auth_startup_provider.dart`
- auth notifier refaktor: `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- feature barrel exportok: `app/lib/src/features/auth/auth.dart`, `app/lib/src/features/rewards/rewards.dart`
- import cleanup: `app/lib/src/features/home/presentation/screens/home_screen.dart`
- unit teszt frissites/uj teszt: `app/test/unit/bonus_system_post_auth_init_test.dart`, `app/test/unit/post_auth_startup_provider_test.dart`
- docs frissites: `docs/architect/project_structure.md`, `docs/core_logic/registration_flow.md`

Implementacios irany:
- auth oldalon a rewards `post_auth_init_provider` direkt import helyett app-szintu startup orchestrator hivas.
- app/startup orchestrator felel a session validacio + error swallow viselkedesert.
- cross-feature importban barrel (`features/auth/auth.dart`, `features/rewards/rewards.dart`) hasznalat.

DoD:
- [ ] az auth feature nem importalja kozvetlenul a rewards belso startup provideret
- [ ] a post-auth init hivas app/startup retegen keresztul tortenik
- [ ] legalabb auth/rewards featurehez van public API barrel es a cross-feature import ezt hasznalja
- [ ] unit teszt bizonyitja, hogy a startup orchestrator csak ervenyes sessionnel futtat es hibat nem propagal UI crash-re

Kockazat/rollback:
- rossz startup wiring eseten elmaradhat signup bonus init; rollbackhez auth notifierben ideiglenesen visszakapcsolhato a regi direkt hivas.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/flutter.sh test test/unit/bonus_system_post_auth_init_test.dart test/unit/post_auth_startup_provider_test.dart test/widget/guest_routing_shells_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/architect/project_structure.md`
- `docs/core_logic/registration_flow.md`
- `app/lib/src/app/router/app_router.dart`
