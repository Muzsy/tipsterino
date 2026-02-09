Olvasd el:
- AGENTS.md
- canvases/audit_p0/production_secret_management_docs.md
- codex/goals/canvases/audit_p0/fill_canvas_production_secret_management_docs.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `docs/setup/secret_management.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `app/.env.example`
- `codex/codex_checklist/audit_p0/production_secret_management_docs.md`
- `codex/reports/audit_p0/production_secret_management_docs.md`

Verifikacio a vegen:
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/production_secret_management_docs.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/production_secret_management_docs.verify.log`
- reportban ne szerepeljen valos secret adat.
