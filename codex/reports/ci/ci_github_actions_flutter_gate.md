**FAIL** – Verify gate succeeded, but the manual branch-protection rule is still pending.

## 1) Meta
* **Task slug:** `ci_github_actions_flutter_gate`
* **Kapcsolódó canvas:** `canvases/ci/ci_github_actions_flutter_gate.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/ci/fill_canvas_ci_github_actions_flutter_gate.yaml`
* **Futás dátuma:** 2026-02-08
* **Branch / commit:** `main@f58d0f6`
* **Fókusz terület:** Docs

## 2) Scope

### 2.1 Cél
1. `./scripts/check.sh`-t lefuttató GitHub Actions workflow készítése (`pull_request`, `push`, `workflow_dispatch`).
2. Verifikációs flow egy új report + log párral a `verify.sh`-on keresztül.
3. Dokumentálás: checklist és report a standard szerint.

### 2.2 Nem-cél (explicit)
1. Flutter build vagy release pipeline.
2. Supabase kulcs vagy környezet beállítása a workflow-ban.
3. Branch protection automatizálása (manuális GitHub beállítás).

## 3) Változások összefoglalója (Change summary)

### 3.1 Érintett fájlok
* **CI automation:**
  * `.github/workflows/ci.yml`
* **Docs / gates:**
  * `scripts/verify.sh` (executable bit és gate flow)
  * `codex/codex_checklist/ci/ci_github_actions_flutter_gate.md`
  * `codex/reports/ci/ci_github_actions_flutter_gate.md`

### 3.2 Miért változtak?
* A GitHub Actions workflow a repo standard quality gate-re épül, hogy a check.sh a main/minőségi branchen automatikusan fusson.
* A verify.sh executable bitjének biztosítása + új report/checklist telepítésével a Codex gate determinisztikus és auditálható marad.

## 4) Verifikáció (How tested)

### 4.1 Kötelező parancs
* `./scripts/verify.sh --report codex/reports/ci/ci_github_actions_flutter_gate.md` → `PASS` (a log a `codex/reports/ci/ci_github_actions_flutter_gate.verify.log` fájlban).

### 4.2 Opcionális, feladatfüggő parancsok
* (nem futott)

## 4.0 Automatikus blokk (verify.sh)

```md
<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T15:42:17+01:00 → 2026-02-08T15:42:49+01:00 (32s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/ci/ci_github_actions_flutter_gate.verify.log`
- git: `main@a278a56`
- módosított fájlok (git status): 5

**git diff --stat**

```text
 canvases/ci/ci_github_actions_flutter_gate.md      | 16 +++++++--------
 .../ci/ci_github_actions_flutter_gate.md           |  2 +-
 ...fill_canvas_ci_github_actions_flutter_gate.yaml | 24 +++++++++++-----------
 codex/reports/ci/ci_github_actions_flutter_gate.md |  2 +-
 .../ci/ci_github_actions_flutter_gate.verify.log   | 14 ++++++-------
 5 files changed, 29 insertions(+), 29 deletions(-)
```

**git status --porcelain (preview)**

```text
 M canvases/ci/ci_github_actions_flutter_gate.md
 M codex/codex_checklist/ci/ci_github_actions_flutter_gate.md
 M codex/goals/canvases/ci/fill_canvas_ci_github_actions_flutter_gate.yaml
 M codex/reports/ci/ci_github_actions_flutter_gate.md
 M codex/reports/ci/ci_github_actions_flutter_gate.verify.log
```

<!-- AUTO_VERIFY_END -->
```

## 5) DoD → Evidence Matrix (kötelező)

| DoD pont | Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| #1 `.github/workflows/ci.yml` létrehozása, `Flutter gate (check.sh)` job push/PR triggerrel | PASS | `.github/workflows/ci.yml`:1-32 | Workflow a `./scripts/check.sh`-t futtatja, a job neve megegyezik az elvárással. | `./scripts/check.sh` a workflow-ban |
| #2 `scripts/verify.sh` futtatható, gate parancs lefut | PASS | `scripts/verify.sh`:1-200 és `codex/reports/ci/ci_github_actions_flutter_gate.verify.log`:1-200 | `./scripts/verify.sh --report ...` futott, a log a check.sh sikeres futását mutatja (exit 0). | `./scripts/verify.sh --report ...` |
| #3 Checklist + report a szabvány szerint | PASS | `codex/codex_checklist/ci/ci_github_actions_flutter_gate.md`:1-16, `codex/reports/ci/ci_github_actions_flutter_gate.md`:1-80 | Pillértelen, a dokumentáció tartalmazza a DoD pontokat és a standard blokkokat. | - |
| #4 Branch protection: `CI / Flutter gate (check.sh)` required status | FAIL | - | A manuális GitHub beállítás még nem történt. | - |

## 8) Advisory notes (nem blokkoló)
* (nincs ez a taskban)

## 9) Follow-ups (opcionális)
* Állítsd be a GitHub branch protection rules alatt a `CI / Flutter gate (check.sh)` státuszt required-nek.
