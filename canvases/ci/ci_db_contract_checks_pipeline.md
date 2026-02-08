# P0-2: DB contract checks pipeline (Supabase local + sql_checks + CI)

## 🎯 Funkció
Cél: legyen egy ismételhető, automatizált DB ellenőrzési kapu:
1) Lokál futtatható script: `./scripts/check_db.sh` → lefuttatja a `supabase/sql_checks/*.sql` fájlokat egy lokális Supabase DB-n.
2) GitHub Actions workflow: `.github/workflows/ci_db.yml` → PR/push esetén automatikusan futtatja a DB checkeket.

Nem cél:
- Prod/remote DB elérése (nincs SUPABASE_ACCESS_TOKEN, nincs DB jelszó CI-ben).
- pgTAP / `supabase test db` bevezetése (később dönthető).
- DB migráció “push” remote-ra (külön task).

## 🧠 Fejlesztési részletek
### Érintett / létrejövő fájlok
- Új: `scripts/check_db.sh` (lokális DB checks runner)
- Új: `.github/workflows/ci_db.yml` (CI DB checks)
- Új: `docs/qa/db_checks.md` (hogyan futtasd lokál/CI)
- Új artefaktok ehhez a taskhoz:
  - `canvases/ci/ci_db_contract_checks_pipeline.md`
  - `codex/goals/canvases/ci/fill_canvas_ci_db_contract_checks_pipeline.yaml`
  - `codex/codex_checklist/ci/ci_db_contract_checks_pipeline.md`
  - `codex/reports/ci/ci_db_contract_checks_pipeline.md`
  - `codex/reports/ci/ci_db_contract_checks_pipeline.verify.log` (auto, a verify.sh-ból)
  - `codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log` (a DB check futás logja)

### Lokál futtatás (előfeltételek)
- Docker fut (Supabase local stack miatt).
- Supabase CLI telepítve.
- `psql` elérhető (`postgresql-client`).

### CI elvárt viselkedés
- Trigger: `pull_request`, `push`, `workflow_dispatch`.
- Runner: `ubuntu-latest`.
- Lépések: repo checkout → Supabase CLI → `supabase start` → migrációk alkalmazása lokál DB-re → `./scripts/check_db.sh`.

### Kockázatok / rollback
- Kockázat: Supabase local docker image változás / szolgáltatás indulási késleltetés.
  - Kezelés: a workflowban külön “start” és “db reset” lépés, fail fast.
- Rollback: `.github/workflows/ci_db.yml` + `scripts/check_db.sh` törlése.

### DoD (pipálható)
- [ ] `scripts/check_db.sh` létezik és futtatható (`chmod +x`).
- [ ] Lokál: `supabase start` után `./scripts/check_db.sh` lefut és PASS/FAIL-t ad (exit kód helyes).
- [ ] `.github/workflows/ci_db.yml` létezik és PR/push esetén fut.
- [ ] `docs/qa/db_checks.md` leírja a lokál parancsokat + CI működést.
- [ ] DB check log mentve: `codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log`
- [ ] Repo gate rögzítve: `./scripts/verify.sh --report codex/reports/ci/ci_db_contract_checks_pipeline.md` (+ `.verify.log`)
- [ ] (KÉZI, opcionális) Branch protection: `CI - DB / DB contract checks (sql_checks)` required status check.

## 🧪 Tesztállapot
- Kötelező (task zárás):  
  `./scripts/verify.sh --report codex/reports/ci/ci_db_contract_checks_pipeline.md`
- DB ellenőrzés (task része):  
  `supabase start`  
  `./scripts/check_db.sh`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `AGENTS.md`
- `docs/codex/overview.md`
- `docs/codex/yaml_schema.md`
- `docs/codex/report_standard.md`
- `docs/qa/testing_guidelines.md`
- `scripts/verify.sh`, `scripts/check.sh`
- `supabase/sql_checks/*.sql`
