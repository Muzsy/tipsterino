**FAIL** - Scaffold only; implementacio es verifikacio nem futott ebben a korben.

## 1) Meta
- **Task slug:** rpc_rate_limit_state_retention_cleanup
- **Kapcsolodo canvas:** canvases/audit_p1/rpc_rate_limit_state_retention_cleanup.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_rpc_rate_limit_state_retention_cleanup.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (scaffold)
- **Fokusz terulet:** DB + Docs

## 2) Scope
### 2.1 Cel
- `rpc_rate_limit_state` retention/cleanup bevezetese.
- SQL check szerzodes kiegeszitese retention ellenorzessel.
- Strategia es QA doksi frissitese futtatasi moddal.

### 2.2 Nem-cel (explicit)
- Bonus RPC uzleti logika atirasa.
- Limiter parameterek (`window`, `attempt`) valtoztatasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/rpc_rate_limit_state_retention_cleanup.md`
- `supabase/migrations/20260217000000_rpc_rate_limit_state_retention_cleanup.sql`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_retention_checks.sql`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p1/rpc_rate_limit_state_retention_cleanup.md`
- `codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.md`

### 3.2 Miert valtoztak?
- P1 retention/cleanup scope formalizalasa.
- Task futtatasahoz szukseges output es verifikacios targetek rogzitese.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`

### 4.3 Eredmeny roviden
- Ebben a korben scaffold keszult, verifikacio nem futott.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| letezik SECURITY DEFINER cleanup fuggveny a `public.rpc_rate_limit_state` regi sorainak torlesere | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/check_db.sh` |
| a cleanup futtatasi modja dokumentalt (cron vagy kulso scheduler), fallback manual parancsokkal | FAIL | n/a | Implementacio meg nem tortent. | docs review |
| SQL check validalja a cleanup fuggveny jelenletet es alap retention szerzodest | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/check_db.sh` |
| reportban kulon evidence van a `check_db` futasrol es a retention rationale-rol | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a scaffold korben.

<!-- AUTO_VERIFY_START -->
Scaffold allapot: verify futas meg nem tortent.
<!-- AUTO_VERIFY_END -->
