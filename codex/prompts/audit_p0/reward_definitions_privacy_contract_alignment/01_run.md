Olvasd el:
- AGENTS.md
- docs/core_logic/bonus_system.md
- docs/data_model/reward_definitions_table_doc.md
- canvases/audit_p0/reward_definitions_privacy_contract_alignment.md
- codex/goals/canvases/audit_p0/fill_canvas_reward_definitions_privacy_contract_alignment.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Kulon szabaly:
- Konfliktus eseten a repo kanonikus szabalyokat koveted (reward_definitions kliens oldali SELECT tiltott).

Task output cel:
- `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- `docs/data_model/reward_definitions_table_doc.md`
- `codex/codex_checklist/audit_p0/reward_definitions_privacy_contract_alignment.md`
- `codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.verify.log`
- report tartalmazza a konfliktusfeloldas rovid indoklasat.
