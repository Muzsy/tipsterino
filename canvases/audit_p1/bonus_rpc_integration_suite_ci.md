# Audit P1-1: bonus RPC integration suite + CI

## 🎯 Funkcio
Celfeladat: bonus RPC-khez valos (Supabase local stackre epulo) integration teszt suite bevezetese, es CI futtatasi gate-be kotese.

Nem cel:
- uj bonus uzleti szabaly bevezetese
- production Supabase projekt modositasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/integration_test/app_test.dart`
- `app/integration_test/registration_v2_full_flow_test.dart`
- `app/lib/src/features/rewards/data/signup_bonus_rpc.dart`
- `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `scripts/check_db.sh`
- `scripts/check.sh`

Tervezett kimenetek:
- uj integration test suite: `app/integration_test/bonus_rpc_integration_test.dart`
- CI futtatasi lepesek frissitese: `.github/workflows/ci_db.yml`
- teszt workflow dokumentacio: `docs/qa/testing_guidelines.md`
- CI futtatasi parancs: `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...`

DoD:
- [ ] letezik bonus RPC integration teszt, ami lefedi a signup + daily bonus critical reason kodokat
- [ ] a teszt suite CI-ben fut (Supabase local stack + app integration test)
- [ ] a futtatasi sorrend deterministic (db reset -> check_db -> CI auth user provision + sign-in validation -> integration)
- [ ] reportban kulon bizonyitek van az integration futasrol

Kockazat/rollback:
- CI futasi ido nohet; ha timeout jelentkezik, kulon workflow-ra bontas vagy parhuzamositas kell.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/testing_guidelines.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `app/integration_test/registration_v2_full_flow_test.dart`
