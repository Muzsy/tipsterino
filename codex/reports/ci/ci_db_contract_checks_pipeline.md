**FAIL** – DB local check needs fixing before the gate can pass.

## 1) Meta
* **Task slug:** `ci_db_contract_checks_pipeline`
* **Kapcsolódó canvas:** `canvases/ci/ci_db_contract_checks_pipeline.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/ci/fill_canvas_ci_db_contract_checks_pipeline.yaml`
* **Futás dátuma:** 2026-02-08
* **Branch / commit:** `main@e0da270`
* **Fókusz terület:** CI

## 2) Scope

### 2.1 Cél
1. Lokál Supabase + sql_checks hiányosságok fedezése egy új `scripts/check_db.sh`-sel.
2. CI workflow (`.github/workflows/ci_db.yml`) a checkeket futtatja `pull_request/push/workflow_dispatch` triggerrel.
3. Dokumentáció a DB checkek futtatásáról és a Codex report/checklist frissítése.

### 2.2 Nem-cél (explicit)
1. Supabase remote DB elérése vagy prod környezet.
2. `supabase test db` vagy pgTAP integráció.
3. Branch protection automatikus engedélyezése (manuális GitHub-ról kell).

## 3) Változások összefoglalója (Change summary)

### 3.1 Érintett fájlok
* **CI automation:** `.github/workflows/ci_db.yml`
* **Scripts:** `scripts/check_db.sh`
* **Docs:** `docs/qa/db_checks.md`
* **Codex artefacts:** the new checklist/report + DB log + verify log.

### 3.2 Miért változtak?
* A pipeline most már explicit DB check scriptet és CI workflow-t ad, így a Supabase lokalizált contract ellenőrzések gondosan dokumentáltan futnak.
* Az `docs/qa/db_checks.md` segít a fejlesztőknek és CI-nek, hogy tudják, hogyan indítsák és gyanúsítsák a hibákat.

## 4) Verifikáció (How tested)

### 4.1 Kötelező parancs
* (éppen futtatva a repo gate) `./scripts/verify.sh --report codex/reports/ci/ci_db_contract_checks_pipeline.md`

### 4.2 Opcionális, feladatfüggő parancsok
* `supabase start`
* `supabase db reset --local --no-seed`
* `./scripts/check_db.sh | tee codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log`

## 4.0 Automatikus blokk (verify.sh)

```md
<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T15:58:39+01:00 → 2026-02-08T15:59:17+01:00 (38s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/ci/ci_db_contract_checks_pipeline.verify.log`
- git: `main@e0da270`
- módosított fájlok (git status): 9

**git status --porcelain (preview)**

```text
?? .github/workflows/ci_db.yml
?? canvases/ci/ci_db_contract_checks_pipeline.md
?? codex/codex_checklist/ci/ci_db_contract_checks_pipeline.md
?? codex/goals/canvases/ci/fill_canvas_ci_db_contract_checks_pipeline.yaml
?? codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log
?? codex/reports/ci/ci_db_contract_checks_pipeline.md
?? codex/reports/ci/ci_db_contract_checks_pipeline.verify.log
?? docs/qa/db_checks.md
?? scripts/check_db.sh
```

<!-- AUTO_VERIFY_END -->
```

## 5) DoD → Evidence Matrix (kötelező)

| DoD pont | Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| #1 `scripts/check_db.sh` létezik és futtatható | PASS | `scripts/check_db.sh`:1-120 | Skript kialakítva a Supabase local URL feltérképezésével és minden `supabase/sql_checks/*.sql` futtatásával. | `./scripts/check_db.sh` |
| #2 `.github/workflows/ci_db.yml` létezik | PASS | `.github/workflows/ci_db.yml`:1-32 | Workflow a `pull_request/push/workflow_dispatch` triggeren fut és a DB check scriptet hívja. | GitHub Actions job |
| #3 `docs/qa/db_checks.md` leírja a futtatást | PASS | `docs/qa/db_checks.md`:1-32 | Rövid, parancscentrikus dokumentáció a lokális/CI futtatáshoz és hibaelhárításhoz. | - |
| #4 DB check log mentve | FAIL | `codex/reports/ci/ci_db_contract_checks_pipeline.db_checks.log`:1-40 | A script `supabase status failed` hibával állt le, mert a local stack nem futott (`supabase start` timeout). | `./scripts/check_db.sh` |
| #5 Repo gate rögzítve | PASS | `codex/reports/ci/ci_db_contract_checks_pipeline.verify.log`:1-80 | Repo gate lefutott, `./scripts/check.sh` PASS lett, a log a report mellett elérhető. | `./scripts/verify.sh --report ...` |
| #6 Branch protection | FAIL | - | Manuális GitHub beállítás hiányzik (`CI - DB / DB contract checks (sql_checks)`). | - |

## 8) Advisory notes (nem blokkoló)
* tele van.

## 9) Follow-ups (opcionális)
* Telepítsd a Supabase CLI-t és `psql`-t a fejlesztői/CI környezetbe, hogy a `./scripts/check_db.sh` tényleges SQL ellenőrzéseket végezzen.
