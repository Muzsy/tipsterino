**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** `rls_cross_user_enforcement_checks`
- **Kapcsolodo canvas:** `canvases/audit_p0/rls_cross_user_enforcement_checks.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_rls_cross_user_enforcement_checks.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main`
- **Fokusz terulet:** DB

## 2) Scope
### 2.1 Cel
- Cross-user RLS enforcement SQL check bevezetese.

### 2.2 Nem-cel (explicit)
- App UI valtoztatas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p0/rls_cross_user_enforcement_checks.md`
- `codex/reports/audit_p0/rls_cross_user_enforcement_checks.md`

### 3.2 Miert valtoztak?
- RLS szerzodes regresszio vedelme.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/rls_cross_user_enforcement_checks.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Cross-user SQL check letrejott | FAIL | `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql` | Verify utan toltendo. | `./scripts/check_db.sh` |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
