Olvasd el:
- AGENTS.md
- canvases/audit_p1/bonus_rpc_integration_suite_ci.md
- codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_suite_ci.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `codex/codex_checklist/audit_p1/bonus_rpc_integration_suite_ci.md`
- `codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/bonus_rpc_integration_suite_ci.verify.log`
- reportban legyen kulon bizonyitek az integration teszt CI futasarol.
