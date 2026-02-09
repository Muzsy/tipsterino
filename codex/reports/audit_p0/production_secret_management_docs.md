**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** `production_secret_management_docs`
- **Kapcsolodo canvas:** `canvases/audit_p0/production_secret_management_docs.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_production_secret_management_docs.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main`
- **Fokusz terulet:** Docs

## 2) Scope
### 2.1 Cel
- Production secret kezeles dokumentacios bazis kialakitasa.

### 2.2 Nem-cel (explicit)
- Valos secret ertekek commitja.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `docs/setup/secret_management.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `app/.env.example`
- `codex/codex_checklist/audit_p0/production_secret_management_docs.md`
- `codex/reports/audit_p0/production_secret_management_docs.md`

### 3.2 Miert valtoztak?
- Commit-safe es CI-safe secret kezeles egységesitese.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/production_secret_management_docs.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Secret management doksi letrejott | FAIL | `docs/setup/secret_management.md` | Verify utan toltendo. | `./scripts/check.sh` |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
