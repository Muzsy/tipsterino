# P0-1: GitHub Actions CI – Flutter quality gate (check.sh)

## 🎯 Funkció
Cél: legyen egy GitHub Actions workflow, ami **push + PR** esetén lefut, és minimum quality gate-ként futtatja a repó standard ellenőrzését: `./scripts/check.sh` (pub get + analyze + test).

Nem cél:
- DB contract checks (külön P0-2).
- Flavors / build / release pipeline.
- Formázás gate (opcionális, később dönthető el).

## 🧠 Fejlesztési részletek
### Érintett / létrejövő fájlok
- Új: `.github/workflows/ci.yml`
- Mód: `scripts/verify.sh` (követelmény: futtatható legyen `./scripts/verify.sh` formában; ha nem, `chmod +x scripts/verify.sh`)
- Új artefaktok ehhez a taskhoz:
  - `canvases/ci/ci_github_actions_flutter_gate.md`
  - `codex/goals/canvases/ci/fill_canvas_ci_github_actions_flutter_gate.yaml`
  - `codex/codex_checklist/ci/ci_github_actions_flutter_gate.md`
  - `codex/reports/ci/ci_github_actions_flutter_gate.md`
  - `codex/reports/ci/ci_github_actions_flutter_gate.verify.log` (auto)

### CI elvárt viselkedés
- Trigger: `pull_request`, `push`, + opcionális `workflow_dispatch`.
- Linux runner: `ubuntu-latest`.
- A workflow futtassa: `./scripts/check.sh`.
- Ha a `check.sh` hibával tér vissza → a workflow **FAIL**.

### Fontos: branch protection (kézi GitHub beállítás)
A workflow önmagában lefut, de “kötelező” státuszcheck csak GitHub oldali beállítással lesz:
- Branch protection rules alatt tedd **required**-dé a checket:
  - `CI / Flutter gate (check.sh)` *(workflow név / job név)*

### Kockázatok / rollback
- Kockázat: CI runneren plugin/dep miatt a `flutter test` platformfüggő hibát dob.
  - Kezelés: csak akkor tegyünk be apt deps telepítést, ha ténylegesen indokolt (log alapján).
- Rollback:
  - `.github/workflows/ci.yml` törlése / visszavonása.
  - `scripts/verify.sh` executable bit visszaállítása (ha valamiért gondot okozna).

### DoD (pipálható)
- [ ] `.github/workflows/ci.yml` létrehozva (push + PR + manual run).
- [ ] Workflow a `./scripts/check.sh`-t futtatja, hibára piros.
- [ ] `scripts/verify.sh` futtatható: `./scripts/verify.sh --help` (executable bit rendben).
- [ ] Repo gate futtatva és rögzítve: `./scripts/verify.sh --report codex/reports/ci/ci_github_actions_flutter_gate.md` (PASS/FAIL a reportban + `.verify.log` megvan).
- [ ] (KÉZI) Branch protection: required status check beállítva `CI / Flutter gate (check.sh)`.

## 🧪 Tesztállapot
- Kötelező (task zárás):  
  `./scripts/verify.sh --report codex/reports/ci/ci_github_actions_flutter_gate.md`
- Lokál gyors kapu (fallback):  
  `./scripts/check.sh`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `AGENTS.md` (wrapper parancsok + outputs szabály)
- `docs/codex/overview.md` (artefaktok + DoD)
- `docs/codex/yaml_schema.md` (steps-séma + kötelező repo gate)
- `docs/codex/report_standard.md` (Report Standard v2)
- `docs/qa/testing_guidelines.md` (verify/check parancsok)
- `scripts/check.sh`, `scripts/flutter.sh`, `scripts/verify.sh`
