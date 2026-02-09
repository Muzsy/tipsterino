Olvasd el:
- AGENTS.md
- canvases/audit_p0/daily_bonus_rpc_concurrency_guard.md
- codex/goals/canvases/audit_p0/fill_canvas_daily_bonus_rpc_concurrency_guard.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `supabase/sql_checks/bonus_system_rpc_daily_bonus_concurrency_checks.sql`
- `docs/core_logic/daily_bonus.md`
- `codex/codex_checklist/audit_p0/daily_bonus_rpc_concurrency_guard.md`
- `codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.verify.log`
- reportban legyen concurrency teszt evidencia.
