**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** `reward_definitions_privacy_contract_alignment`
- **Kapcsolodo canvas:** `canvases/audit_p0/reward_definitions_privacy_contract_alignment.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_reward_definitions_privacy_contract_alignment.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main`
- **Fokusz terulet:** DB

## 2) Scope
### 2.1 Cel
- `reward_definitions` privacy contract kanonikus erosites.

### 2.2 Nem-cel (explicit)
- Public SELECT policy bevezetese.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- `docs/data_model/reward_definitions_table_doc.md`
- `codex/codex_checklist/audit_p0/reward_definitions_privacy_contract_alignment.md`
- `codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.md`

### 3.2 Miert valtoztak?
- Kontraktus szinkron a kanonikus docs szerint.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Privacy contract check szinkronban | FAIL | `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql` | Verify utan toltendo. | `./scripts/check_db.sh` |

## 8) Advisory notes (nem blokkolo)
- Konfliktus: audit terv P0-2 vs kanonikus docs; ez a task a kanonikus docs iranyat koveti.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
