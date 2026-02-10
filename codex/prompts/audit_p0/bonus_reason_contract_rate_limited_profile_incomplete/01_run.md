Olvasd el:
- AGENTS.md
- canvases/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md
- codex/goals/canvases/audit_p0/fill_canvas_bonus_reason_contract_rate_limited_profile_incomplete.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/test/unit/daily_bonus_grant_result_test.dart`
- `app/test/unit/signup_bonus_grant_result_test.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- `codex/codex_checklist/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`
- `codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

Verifikacio a vegen:
- `./scripts/flutter.sh test test/unit/daily_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/unit/signup_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/widget/daily_bonus_tile_test.dart`
- `./scripts/flutter.sh test test/unit/l10n_key_parity_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.verify.log`
- reportban szerepeljen, hogy a `rate_limited` es `profile_incomplete` contract milyen evidence-szel teljesult.
