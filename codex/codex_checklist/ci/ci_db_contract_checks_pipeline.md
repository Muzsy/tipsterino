# CI DB contract checks pipeline checklist

## P0 – Canvas + YAML
- [x] Létrejött `canvases/ci/ci_db_contract_checks_pipeline.md` és az ehhez tartozó goal YAML (`codex/goals/canvases/ci/fill_canvas_ci_db_contract_checks_pipeline.yaml`).

## P1 – Scripts + workflow
- [x] `scripts/check_db.sh` létrejött, az `supabase/sql_checks/*.sql`-eket futtatja (`supabase` + `psql` -t ellenőrzi, fallback `DATABASE_URL`, kilép `PASS`-sel).
- [x] `.github/workflows/ci_db.yml` a `CI - DB` pipeline (Supabase CLI, psql, start/reset és `./scripts/check_db.sh`).
- [x] `docs/qa/db_checks.md` dokumentálja a lokál/CI parancsokat és a hibakezelést.

## P2 – DB log + report
- [x] `supabase start` + `supabase db reset --local --no-seed` lefutott lokálisan, majd a `./scripts/check_db.sh` sikeresen lefutott; bizonyíték: `codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log` (`DB contract checks: PASS`).
- [x] `./scripts/verify.sh --report codex/reports/ci/ci_db_contract_checks_pipeline.md` lefutott, a reportban az AUTO_VERIFY blokk frissült, és készült `codex/reports/ci/ci_db_contract_checks_pipeline.verify.log`.
- [x] (Kézi) GitHub branch protection: `CI - DB / DB contract checks (sql_checks)` required status check.
