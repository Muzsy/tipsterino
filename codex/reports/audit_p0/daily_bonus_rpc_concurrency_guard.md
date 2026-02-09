**FAIL** - scaffold; verify meg nem futott.

## 1) Meta
- **Task slug:** `daily_bonus_rpc_concurrency_guard`
- **Kapcsolodo canvas:** `canvases/audit_p0/daily_bonus_rpc_concurrency_guard.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_daily_bonus_rpc_concurrency_guard.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main`
- **Fokusz terulet:** DB

## 2) Scope
### 2.1 Cel
- Daily bonus parhuzamos hivasi vedelmenek bevezetese.

### 2.2 Nem-cel (explicit)
- UI valtoztatas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `supabase/sql_checks/bonus_system_rpc_daily_bonus_concurrency_checks.sql`
- `docs/core_logic/daily_bonus.md`
- `codex/codex_checklist/audit_p0/daily_bonus_rpc_concurrency_guard.md`
- `codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.md`

### 3.2 Miert valtoztak?
- Penzugyi duplazas kockazatanak csokkentese.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Concurrency guard implementalva | FAIL | `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql` | Verify utan toltendo. | `./scripts/check_db.sh` |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
