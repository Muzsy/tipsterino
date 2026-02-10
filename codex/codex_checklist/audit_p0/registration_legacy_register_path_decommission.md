# Checklist - registration_legacy_register_path_decommission

- [ ] Canvas frissitve: `canvases/audit_p0/registration_legacy_register_path_decommission.md`
- [ ] Goal YAML frissitve: `codex/goals/canvases/audit_p0/fill_canvas_registration_legacy_register_path_decommission.yaml`
- [ ] Legacy register API cleanup megtortent `auth_provider.dart`-ban
- [ ] `register_screen.dart` torolve vagy explicit unreachable/deprecated allapotban van
- [ ] `/auth/register` wizard routing igazolt `app_router.dart` + tesztben
- [ ] `docs/core_logic/registration_flow.md` frissitve (nincs minimal register ut)
- [ ] `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart` lefutott
- [ ] `./scripts/verify.sh --report codex/reports/audit_p0/registration_legacy_register_path_decommission.md` lefutott
- [ ] DoD -> Evidence Matrix kitoltve a reportban
