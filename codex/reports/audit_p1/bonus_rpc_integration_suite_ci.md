**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** bonus_rpc_integration_suite_ci
- **Kapcsolodo canvas:** canvases/audit_p1/bonus_rpc_integration_suite_ci.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_suite_ci.yaml
- **Futas datuma:** 2026-02-09
- **Branch / commit:** main
- **Fokusz terulet:** Mixed

## 2) Scope
### 2.1 Cel
- P1 task scaffold; reszletes tartalom implementacio utan toltendo.

### 2.2 Nem-cel (explicit)
- Scaffold szakaszban nincs kodvaltoztatas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- canvases/audit_p1/bonus_rpc_integration_suite_ci.md
- codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_suite_ci.yaml
- codex/codex_checklist/audit_p1/bonus_rpc_integration_suite_ci.md
- codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md

### 3.2 Miert valtoztak?
- P1 feladat futtathato codex artefakt scaffold.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- ./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md

### 4.2 Opcionlis, feladatfuggo parancsok
- Task-fuggo, implementacio alatt toltendo.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Task-specifikus DoD pontok teljesulnek | FAIL | canvases/audit_p1/bonus_rpc_integration_suite_ci.md | Implementacio utan toltendo. | ./scripts/verify.sh --report ... |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
