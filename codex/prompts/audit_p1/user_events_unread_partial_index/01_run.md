Olvasd el:
- AGENTS.md
- canvases/audit_p1/user_events_unread_partial_index.md
- codex/goals/canvases/audit_p1/fill_canvas_user_events_unread_partial_index.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/migrations/20260214000000_user_events_unread_partial_index.sql`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `docs/data_model/user_events_table_doc.md`
- `codex/codex_checklist/audit_p1/user_events_unread_partial_index.md`
- `codex/reports/audit_p1/user_events_unread_partial_index.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/user_events_unread_partial_index.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/user_events_unread_partial_index.verify.log`
- reportban legyen explicit index + check_db bizonyitek.
