# Audit P1-5: bonus RPC integration rate-limit branch

## 🎯 Funkcio
Celfeladat: a bonus RPC integration suite kiegeszitese determinisztikus `rate_limited` ag teszttel, kulon CI futtatasi stratégiaval a flake kockazat minimalizalasara.

Nem cel:
- bonus limiter parameterek (`window`, `attempt`) ujratervezese
- signup email-flow rate-limit workaround atirasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `supabase/migrations/20260213000000_bonus_system_rpc_rate_limit_guard.sql`

Tervezett kimenetek:
- integration teszt bovites: `app/integration_test/bonus_rpc_integration_test.dart`
- CI futtatasi logika frissites: `.github/workflows/ci_db.yml`
- QA guideline frissites: `docs/qa/testing_guidelines.md`

DoD:
- [ ] integration teszt explicit ellenorzi legalabb egy bonus RPC `rate_limited` reason agatat
- [ ] a rate-limit scenariot izolalt futasi modban kezeli a CI (kulon step/job vagy egyertelmu sorrend)
- [ ] teszt determinisztikus: nem signup email kuldesi limitre tamaszkodik
- [ ] reportban kulon evidence van a rate-limit branch futasrol

Kockazat/rollback:
- rosszul izolalt scenario flaky CI-t okozhat; rollbackkent a rate-limit ellenorzes kulon jobba helyezheto optional gate-kent.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...`
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/testing_guidelines.md`
- `.github/workflows/ci_db.yml`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_checks.sql`
