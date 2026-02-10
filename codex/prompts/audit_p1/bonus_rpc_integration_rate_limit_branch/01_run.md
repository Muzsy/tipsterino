Olvasd el:
- AGENTS.md
- canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md
- codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_rate_limit_branch.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `codex/codex_checklist/audit_p1/bonus_rpc_integration_rate_limit_branch.md`
- `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...`
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.verify.log`
- reportban legyen kulon evidence a `rate_limited` branch integration futasarol.
