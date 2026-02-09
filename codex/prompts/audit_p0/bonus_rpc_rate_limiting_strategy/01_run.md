Olvasd el:
- AGENTS.md
- canvases/audit_p0/bonus_rpc_rate_limiting_strategy.md
- codex/goals/canvases/audit_p0/fill_canvas_bonus_rpc_rate_limiting_strategy.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `supabase/migrations/20260213000000_bonus_system_rpc_rate_limit_guard.sql`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_checks.sql`
- `docs/core_logic/bonus_system.md`
- `codex/codex_checklist/audit_p0/bonus_rpc_rate_limiting_strategy.md`
- `codex/reports/audit_p0/bonus_rpc_rate_limiting_strategy.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_rpc_rate_limiting_strategy.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/bonus_rpc_rate_limiting_strategy.verify.log`
- reportban legyen strategy trade-off es residual risk rogzites.
