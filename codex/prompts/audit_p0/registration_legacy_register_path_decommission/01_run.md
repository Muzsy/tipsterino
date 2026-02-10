Olvasd el:
- AGENTS.md
- canvases/audit_p0/registration_legacy_register_path_decommission.md
- codex/goals/canvases/audit_p0/fill_canvas_registration_legacy_register_path_decommission.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/presentation/screens/register_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/widget/guest_routing_shells_test.dart`
- `docs/core_logic/registration_flow.md`
- `codex/codex_checklist/audit_p0/registration_legacy_register_path_decommission.md`
- `codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

Verifikacio a vegen:
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/registration_legacy_register_path_decommission.verify.log`
- reportban legyen explicit bizonyitek arra, hogy `/auth/register` wizard-only maradt.
