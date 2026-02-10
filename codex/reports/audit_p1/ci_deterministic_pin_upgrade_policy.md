**FAIL** - Scaffold only; implementacio es verifikacio nem futott ebben a korben.

## 1) Meta
- **Task slug:** ci_deterministic_pin_upgrade_policy
- **Kapcsolodo canvas:** canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_ci_deterministic_pin_upgrade_policy.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (scaffold)
- **Fokusz terulet:** CI + Docs

## 2) Scope
### 2.1 Cel
- workflow pin matrix egységesites.
- upgrade policy dokumentalas check/check_db/verify gate kovetelmennyel.
- drift kockazat csokkentese.

### 2.2 Nem-cel (explicit)
- CI pipeline architektura attervezese.
- major toolchain upgrade.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `codex/codex_checklist/audit_p1/ci_deterministic_pin_upgrade_policy.md`
- `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

### 3.2 Miert valtoztak?
- P1 CI determinisztika es upgrade policy task formalizalasa.
- Workflow + docs outputok explicit deklaralasa.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check.sh`

### 4.3 Eredmeny roviden
- Ebben a korben scaffold keszult, verifikacio nem futott.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| minden workflow action/toolchain pin explicit es dokumentalt | FAIL | n/a | Implementacio meg nem tortent. | workflow review |
| nincs lebego `latest`/major-only pin kritikus toolchain komponenseknel | FAIL | n/a | Implementacio meg nem tortent. | workflow review |
| docs tartalmazza az upgrade policyt es kotelezo local gate parancsokat | FAIL | n/a | Implementacio meg nem tortent. | docs review |
| reportban szerepel pin matrix before/after es a verifikacios parancslista | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a scaffold korben.

<!-- AUTO_VERIFY_START -->
Scaffold allapot: verify futas meg nem tortent.
<!-- AUTO_VERIFY_END -->
