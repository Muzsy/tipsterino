Olvasd el:
- AGENTS.md
- canvases/audit_p0/public_profiles_privacy_hardening.md
- codex/goals/canvases/audit_p0/fill_canvas_public_profiles_privacy_hardening.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/migrations/20260215000000_public_profiles_privacy_hardening.sql`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `docs/data_model/profiles_table_doc.md`
- `codex/codex_checklist/audit_p0/public_profiles_privacy_hardening.md`
- `codex/reports/audit_p0/public_profiles_privacy_hardening.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/public_profiles_privacy_hardening.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/public_profiles_privacy_hardening.verify.log`
- reportban szerepeljen a vegso privacy dontes rovid indoklasa es a DB check eredmenye.
