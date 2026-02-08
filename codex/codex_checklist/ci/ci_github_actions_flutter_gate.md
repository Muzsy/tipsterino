# CI GitHub Actions Flutter gate checklist

## P0 – Canvas + YAML
- [x] A `canvases/ci/ci_github_actions_flutter_gate.md` leírja a GitHub Actions CI minőségi kapuját (scope, DoD, teszt terv, kockázat, rollback).
- [x] A `codex/goals/canvases/fill_canvas_ci_github_actions_flutter_gate.yaml` lépései pontosan meghatározzák a megvalósítás + gate flow-t.

## P1 – Workflow + script
- [x] `.github/workflows/ci.yml` létrejött, a `Flutter gate (check.sh)` job a `pull_request`, `push` és `workflow_dispatch` trigger-eken fut, és `./scripts/check.sh`-t hívja.
- [x] `scripts/verify.sh` executable, a repo gate parancsot a `./scripts/verify.sh --report codex/reports/ci/ci_github_actions_flutter_gate.md` esetén is elérhető funkcióval futtatja.

## P2 – Repo gate + log
- [x] `./scripts/verify.sh --report codex/reports/ci/ci_github_actions_flutter_gate.md` lefutott, létrehozta a `codex/reports/ci/ci_github_actions_flutter_gate.verify.log`-ot és frissítette az AUTO_VERIFY blokkot (exit 0).
- [ ] (Manual) Branch protection beállítása: `CI / Flutter gate (check.sh)` required status check a GitHub-on.

## P3 – Report + follow-up
- [x] A report a `docs/codex/report_standard.md` szerinti struktúrát követi, tartalmazza a Change summary-t és a DoD → Evidence mátrixot.
- [x] A reportban van AUTO_VERIFY blokk, amit a `verify.sh` frissít.
