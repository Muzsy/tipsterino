Olvasd el:
- AGENTS.md
- canvases/audit_p0/rls_cross_user_enforcement_checks.md
- codex/goals/canvases/audit_p0/fill_canvas_rls_cross_user_enforcement_checks.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p0/rls_cross_user_enforcement_checks.md`
- `codex/reports/audit_p0/rls_cross_user_enforcement_checks.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/rls_cross_user_enforcement_checks.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/rls_cross_user_enforcement_checks.verify.log`
- report statusz: PASS/FAIL/PASS_WITH_NOTES
- reportban legyen DoD -> Evidence Matrix es AUTO_VERIFY blokk.
