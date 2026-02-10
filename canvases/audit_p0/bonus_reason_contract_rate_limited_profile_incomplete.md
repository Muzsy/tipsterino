# Audit P0-3: bonus reason contract sync (rate_limited + profile_incomplete)

## 🎯 Funkcio
Celfeladat: kliens oldali bonus reason mapping szinkronba hozasa a szerver oldali contracttal (`rate_limited`, `profile_incomplete`), UI/l10n es teszt lefedessel.

Miert P0:
- ismeretlen reason fallback jelenleg felrevezeto allapotot adhat (`notConfigured`), ez hibas user feedbacket es regressziot okozhat.

Nem cel:
- bonus RPC SQL logika ujratervezese
- teljes rewards UX redesign
- integration test suite atirasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/test/unit/daily_bonus_grant_result_test.dart`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/migrations/20260213000000_bonus_system_rpc_rate_limit_guard.sql`

Tervezett kimenetek:
- reason enum/mapping frissites daily + signup domainben
- daily bonus tile reason-specifikus UI szoveg/CTA
- EN/HU l10n bovites
- unit/widget teszt bovites (`daily_bonus_grant_result_test`, uj `signup_bonus_grant_result_test`, `daily_bonus_tile_test`)

DoD:
- [ ] `DailyBonusReason` kezeli a `rate_limited` reason-t
- [ ] `SignupBonusReason` kezeli a `profile_incomplete` es `rate_limited` reason-t
- [ ] UI kulon szoveggel kezeli a `rate_limited` allapotot (nem generic fallback)
- [ ] EN/HU ARB parity teljesul az uj kulcsokra
- [ ] unit/widget tesztek lefedik az uj reason mappingeket es fallbacket

Kockazat/rollback:
- uj reason mapping UI oldalon disable/enable viselkedest modosithat; regresszio eseten revert + koveto fix task szukseges.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/flutter.sh test test/unit/daily_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/unit/signup_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/widget/daily_bonus_tile_test.dart`
- `./scripts/flutter.sh test test/unit/l10n_key_parity_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

## 🌍 Lokalizacio
Erintett. Uj UI szovegekhez EN+HU kulcs kotelezo.

## 📎 Kapcsolodasok
- `docs/localization/localization_logic.md`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `docs/core_logic/bonus_system.md`
