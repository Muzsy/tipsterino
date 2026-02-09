Olvasd el:
- AGENTS.md
- canvases/audit_p1/legacy_screens_feature_first_alignment.md
- codex/goals/canvases/audit_p1/fill_canvas_legacy_screens_feature_first_alignment.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/lib/src/features/bets/presentation/screens/bets_screen.dart`
- `app/lib/src/features/forum/presentation/screens/forum_screen.dart`
- `app/lib/src/features/guest_info/presentation/screens/guest_info_screen.dart`
- `app/lib/src/features/profile/presentation/screens/profile_screen.dart`
- `app/lib/src/features/settings/presentation/screens/settings_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/widget/guest_routing_shells_test.dart`
- `docs/architect/project_structure.md`
- `codex/codex_checklist/audit_p1/legacy_screens_feature_first_alignment.md`
- `codex/reports/audit_p1/legacy_screens_feature_first_alignment.md`

Verifikacio a vegen:
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/legacy_screens_feature_first_alignment.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/legacy_screens_feature_first_alignment.verify.log`
- reportban legyen kulon route smoke bizonyitek.
