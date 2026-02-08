# CI reward_definitions privacy contract checks checklist

## P0 – Canvas + YAML
- [x] Létrejött `canvases/ci/ci_reward_definitions_privacy_contract_checks.md` és a goal YAML (`codex/goals/canvases/ci/fill_canvas_ci_reward_definitions_privacy_contract_checks.yaml`).

## P1 – SQL check + docs
- [x] Létrejött `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`.
- [x] A check FAIL-ol, ha `anon` vagy `authenticated` SELECT/INSERT/UPDATE/DELETE jogot kap a `public.reward_definitions` táblára.
- [x] A check FAIL-ol, ha policy kerül a `public.reward_definitions` táblára.
- [x] `docs/data_model/reward_definitions_table_doc.md` explicit hivatkozik a SQL check fájlra és a `./scripts/check_db.sh` futtatásra.

## P2 – DB log + verify + zárás
- [x] A check PASS a jelenlegi elvárt állapotban.
- [x] DB log rögzítve: `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`.
- [x] Repo gate rögzítve: `./scripts/verify.sh --report codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md` (+ verify log).
