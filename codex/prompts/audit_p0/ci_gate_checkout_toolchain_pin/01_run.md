Olvasd el:
- AGENTS.md
- canvases/audit_p0/ci_gate_checkout_toolchain_pin.md
- codex/goals/canvases/audit_p0/fill_canvas_ci_gate_checkout_toolchain_pin.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p0/ci_gate_checkout_toolchain_pin.md`
- `codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

Verifikacio a vegen:
- `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.verify.log`
- reportban legyen rogzitve a valasztott pinelt verziok listaja es az upgrade policy rovid leirasa.
