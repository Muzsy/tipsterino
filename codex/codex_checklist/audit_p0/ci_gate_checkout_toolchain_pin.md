# Checklist - ci_gate_checkout_toolchain_pin

- [ ] Canvas frissitve: `canvases/audit_p0/ci_gate_checkout_toolchain_pin.md`
- [ ] Goal YAML frissitve: `codex/goals/canvases/audit_p0/fill_canvas_ci_gate_checkout_toolchain_pin.yaml`
- [ ] `ci.yml` nem hasznal lebego checkout taget
- [ ] `ci_db.yml` nem hasznal lebego checkout taget es nincs `supabase/setup-cli@v1` `version: latest`
- [ ] Flutter es Supabase toolchain verziok explicit pinelve vannak
- [ ] `docs/qa/db_checks.md` frissitve a pin policyval
- [ ] `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` lefutott
- [ ] DoD -> Evidence Matrix kitoltve a reportban
