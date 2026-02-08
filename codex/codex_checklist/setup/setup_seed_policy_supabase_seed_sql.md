# Setup seed policy supabase seed.sql checklist

## P0 - Canvas + cel
- [x] Letrejott / frissult a canvas: `canvases/setup/setup_seed_policy_supabase_seed_sql.md`.

## P1 - Seed policy implementacio
- [x] `supabase/seed.sql` policy headerrel frissitve, szandekosan no-op.
- [x] Letrejott: `docs/qa/seed_policy.md`.
- [x] `docs/qa/db_checks.md` tartalmaz seed-policy hivatkozast es `--no-seed` indoklast.

## P2 - Codex artefaktok
- [x] Letrejott: `codex/codex_checklist/setup/setup_seed_policy_supabase_seed_sql.md`.
- [x] Letrejott: `codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`.

## P3 - Repo gate + report
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`.
- [x] Letrejott verify log: `codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log`.
