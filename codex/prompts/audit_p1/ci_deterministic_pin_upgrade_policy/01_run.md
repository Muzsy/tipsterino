Olvasd el:
- AGENTS.md
- canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md
- codex/goals/canvases/audit_p1/fill_canvas_ci_deterministic_pin_upgrade_policy.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `codex/codex_checklist/audit_p1/ci_deterministic_pin_upgrade_policy.md`
- `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

Verifikacio a vegen:
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.verify.log`
- reportban legyen pin matrix before/after es upgrade policy evidence.
