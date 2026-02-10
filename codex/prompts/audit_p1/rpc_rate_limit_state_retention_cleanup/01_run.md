Olvasd el:
- AGENTS.md
- canvases/audit_p1/rpc_rate_limit_state_retention_cleanup.md
- codex/goals/canvases/audit_p1/fill_canvas_rpc_rate_limit_state_retention_cleanup.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/migrations/20260217000000_rpc_rate_limit_state_retention_cleanup.sql`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_retention_checks.sql`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p1/rpc_rate_limit_state_retention_cleanup.md`
- `codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.verify.log`
- reportban legyen kulon evidence a retention cleanup szerzodesrol es a check_db futasrol.
