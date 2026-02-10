Olvasd el:
- AGENTS.md
- canvases/audit_p0/auth_state_copywith_sentinel_regression.md
- codex/goals/canvases/audit_p0/fill_canvas_auth_state_copywith_sentinel_regression.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- `app/test/unit/signup_wizard_provider_test.dart`
- `app/test/unit/verify_email_pending_provider_test.dart`
- `app/test/widget/auth_signup_wizard_step3_test.dart`
- `app/test/widget/auth_verify_pending_resend_test.dart`
- `codex/codex_checklist/audit_p0/auth_state_copywith_sentinel_regression.md`
- `codex/reports/audit_p0/auth_state_copywith_sentinel_regression.md`

Verifikacio a vegen:
- `./scripts/flutter.sh test test/unit/signup_wizard_provider_test.dart`
- `./scripts/flutter.sh test test/unit/verify_email_pending_provider_test.dart`
- `./scripts/flutter.sh test test/widget/auth_signup_wizard_step3_test.dart`
- `./scripts/flutter.sh test test/widget/auth_verify_pending_resend_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/auth_state_copywith_sentinel_regression.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/auth_state_copywith_sentinel_regression.verify.log`
- reportban legyen explicit error-nullazasi regresszios evidence mindket state-re.
