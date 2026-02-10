**FAIL** - report scaffold, futas es bizonyitekok meg nincsenek kitoltve.

## 1) Meta
- **Task slug:** `ci_gate_checkout_toolchain_pin`
- **Kapcsolodo canvas:** `canvases/audit_p0/ci_gate_checkout_toolchain_pin.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_ci_gate_checkout_toolchain_pin.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** nincs rogzitve
- **Fokusz terulet:** CI + docs

## 2) Scope
### 2.1 Cel
- checkout/action/toolchain drift kockazat csokkentese explicit pinelesseI.
- CI db-check dokumentacio szinkronizalasa a valasztott pin policyval.

### 2.2 Nem-cel (explicit)
- pipeline redesign.
- uj release pipeline.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p0/ci_gate_checkout_toolchain_pin.md`
- `codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

### 3.2 Miert valtoztak?
- A futas utan toltendo: mely pinelt verziok lettek valasztva es miert.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- Nincs.

### 4.3 Eredmeny roviden
- Nincs kitoltve.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `ci.yml` es `ci_db.yml` nem hasznal lebego checkout taget | FAIL | n/a | n/a | n/a |
| Flutter/Supabase toolchain explicit pinelt | FAIL | n/a | n/a | n/a |
| `docs/qa/db_checks.md` tartalmazza a pin policyt | FAIL | n/a | n/a | n/a |
| verify gate futas dokumentalt | FAIL | n/a | n/a | n/a |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
