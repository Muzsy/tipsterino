**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** `signup_bonus_rpc_single_source_of_truth`
- **Kapcsolodo canvas:** `canvases/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_signup_bonus_rpc_single_source_of_truth.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main`
- **Fokusz terulet:** DB

## 2) Scope
### 2.1 Cel
- Signup bonus RPC migracios single source rendezes.

### 2.2 Nem-cel (explicit)
- UI valtoztatas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `docs/core_logic/bonus_system.md`
- `codex/codex_checklist/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

### 3.2 Miert valtoztak?
- Migracios inkonzisztencia megszuntetese.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Single source migracios allapot elert | FAIL | `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql` | Verify utan toltendo. | `./scripts/check_db.sh` |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
