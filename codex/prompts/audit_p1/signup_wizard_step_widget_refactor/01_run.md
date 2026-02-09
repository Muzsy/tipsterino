Olvasd el:
- AGENTS.md
- canvases/audit_p1/signup_wizard_step_widget_refactor.md
- codex/goals/canvases/audit_p1/fill_canvas_signup_wizard_step_widget_refactor.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step1.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step2.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step3.dart`
- `app/lib/src/features/auth/presentation/widgets/password_rules.dart`
- `app/test/widget/auth_signup_wizard_step1_test.dart`
- `app/test/widget/auth_signup_wizard_step2_test.dart`
- `app/test/widget/auth_signup_wizard_step3_test.dart`
- `codex/codex_checklist/audit_p1/signup_wizard_step_widget_refactor.md`
- `codex/reports/audit_p1/signup_wizard_step_widget_refactor.md`

Verifikacio a vegen:
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/signup_wizard_step_widget_refactor.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/signup_wizard_step_widget_refactor.verify.log`
- reportban legyen explicit bizonyitek a step1/step2/step3 tesztfutasra.
