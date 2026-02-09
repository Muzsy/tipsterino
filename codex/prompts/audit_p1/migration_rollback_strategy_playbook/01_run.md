Olvasd el:
- AGENTS.md
- canvases/audit_p1/migration_rollback_strategy_playbook.md
- codex/goals/canvases/audit_p1/fill_canvas_migration_rollback_strategy_playbook.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `docs/qa/migration_rollback_strategy.md`
- `docs/setup/supabase_setup.md`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p1/migration_rollback_strategy_playbook.md`
- `codex/reports/audit_p1/migration_rollback_strategy_playbook.md`

Verifikacio a vegen:
- `./scripts/verify.sh --report codex/reports/audit_p1/migration_rollback_strategy_playbook.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/migration_rollback_strategy_playbook.verify.log`
- reportban legyen rollback decision tree + kotelezo verifikacios lepesek bizonyiteka.
