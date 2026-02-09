Olvasd el:
- AGENTS.md
- canvases/audit_p0/signup_bonus_rpc_single_source_of_truth.md
- codex/goals/canvases/audit_p0/fill_canvas_signup_bonus_rpc_single_source_of_truth.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `docs/core_logic/bonus_system.md`
- `codex/codex_checklist/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

Verifikacio a vegen:
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.verify.log`
- reportban explicit legyen az egyetlen kanonikus RPC definicio helye.
