# Checklist - ci_gate_checkout_toolchain_pin

- [x] Canvas frissitve: `canvases/audit_p0/ci_gate_checkout_toolchain_pin.md`
- [x] Goal YAML frissitve: `codex/goals/canvases/audit_p0/fill_canvas_ci_gate_checkout_toolchain_pin.yaml`
- [x] `ci.yml` nem hasznal lebego checkout taget
- [x] `ci_db.yml` nem hasznal lebego checkout taget es nincs `supabase/setup-cli@v1` `version: latest`
- [x] Flutter es Supabase toolchain verziok explicit pinelve vannak
- [x] `docs/qa/db_checks.md` frissitve a pin policyval
- [x] `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` lefutott
- [x] DoD -> Evidence Matrix kitoltve a reportban
