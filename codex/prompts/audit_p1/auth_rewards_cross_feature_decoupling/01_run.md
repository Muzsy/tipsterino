Olvasd el:
- AGENTS.md
- canvases/audit_p1/auth_rewards_cross_feature_decoupling.md
- codex/goals/canvases/audit_p1/fill_canvas_auth_rewards_cross_feature_decoupling.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/app/startup/post_auth_startup_provider.dart`
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/auth.dart`
- `app/lib/src/features/rewards/rewards.dart`
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/test/unit/bonus_system_post_auth_init_test.dart`
- `app/test/unit/post_auth_startup_provider_test.dart`
- `docs/architect/project_structure.md`
- `docs/core_logic/registration_flow.md`
- `codex/codex_checklist/audit_p1/auth_rewards_cross_feature_decoupling.md`
- `codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md`

Verifikacio a vegen:
- `./scripts/flutter.sh test test/unit/bonus_system_post_auth_init_test.dart test/unit/post_auth_startup_provider_test.dart test/widget/guest_routing_shells_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.verify.log`
- reportban legyen kulon evidence a coupling csokkenesrol (import szint) es a startup regresszios tesztekrol.
