Olvasd el:
- AGENTS.md
- canvases/audit_p1/setup_guide_sdk_redirect_clarity.md
- codex/goals/canvases/audit_p1/fill_canvas_setup_guide_sdk_redirect_clarity.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `docs/setup/dev_setup.md`
- `docs/setup/supabase_setup.md`
- `docs/setup/supabase_configuration.md`
- `README.md`
- `codex/codex_checklist/audit_p1/setup_guide_sdk_redirect_clarity.md`
- `codex/reports/audit_p1/setup_guide_sdk_redirect_clarity.md`

Verifikacio a vegen:
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/setup_guide_sdk_redirect_clarity.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/setup_guide_sdk_redirect_clarity.verify.log`
- reportban legyen explicit SDK + redirect/site_url dokumentacios evidence.
