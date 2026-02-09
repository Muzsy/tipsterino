**PASS_WITH_NOTES** - signup bonus RPC migracios single-source rendezes kesz, check_db es verify PASS.

## 1) Meta
- **Task slug:** `signup_bonus_rpc_single_source_of_truth`
- **Kapcsolodo canvas:** `canvases/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_signup_bonus_rpc_single_source_of_truth.yaml`
- **Futas datuma:** 2026-02-09
- **Branch / commit:** `main@7ee8dde`
- **Fokusz terulet:** DB

## 2) Scope
### 2.1 Cel
- A signup bonus RPC korabbi migracios duplikaciojanak csokkentese a kijelolt P0 migraciokban.
- A vegso, tenyleges RPC viselkedes contract ellenorzese SQL checkben.

### 2.2 Nem-cel (explicit)
- UI valtoztatas.
- Signup bonus uzleti szabaly ujratervezese.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `docs/core_logic/bonus_system.md`
- `codex/codex_checklist/audit_p0/signup_bonus_rpc_single_source_of_truth.md`
- `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

### 3.2 Miert valtoztak?
- A `20260205000000` migraciobol kikerult a teljes RPC-duplikacio, helyette dedikalt profile helper maradt (`is_profile_complete`).
- A `20260208000000` migracio explicit, dokumentalt signup RPC definiciot tartalmaz a partial unique index konfliktusklauzulahoz.
- A behavior check immar explicit szerzodeskent ellenorzi a rate-limit guard + partial conflict viselkedest.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/supabase.sh db reset --local --no-seed`
- `./scripts/check_db.sh`

### 4.3 Eredmeny roviden
- Elso `./scripts/check_db.sh` futas FAIL volt, mert a lokalis DB nem volt ujramigralva az atirt migraciokkal.
- `./scripts/supabase.sh db reset --local --no-seed` utan `./scripts/check_db.sh` PASS.
- `./scripts/verify.sh --report codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md` PASS (analyze + test zold), AUTO_VERIFY blokk frissult.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| a report dokumentalja, melyik migracio marad a vegso RPC forras | PASS | `docs/core_logic/bonus_system.md:46` | A doksi explicit nevezi a kanonikus, vegso RPC forrast a jelenlegi migracios lancban. | Dokumentacios ellenorzes |
| SQL check ellenorzi, hogy a vegso viselkedes stabil | PASS | `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql:21` | A check validalja a vegso function-def szerzodest es a teljes grant/idempotencia viselkedest. | `./scripts/check_db.sh` |
| DB ellenorzes zold reset utan | PASS | `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md:43` | Reset utan a teljes DB check csomag PASS lett. | `./scripts/check_db.sh` |
| verify gate futas es report evidence kitoltve | PASS | `codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.verify.log:1` | A standard verify gate lefutott, log mentve. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- A canvas/YAML scope a `20260204000000`, `20260205000000`, `20260208000000` migraciokra fokuszal, de a valos vegso RPC definiciot jelenleg a kesobbi `20260213000000_bonus_system_rpc_rate_limit_guard.sql` adja; ezt a report es core doksi explicit kezeli, hogy ne legyen forras-ellentmondas.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-09T22:42:15+01:00 → 2026-02-09T22:42:55+01:00 (40s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.verify.log`
- git: `main@7ee8dde`
- módosított fájlok (git status): 9

**git diff --stat**

```text
 .../signup_bonus_rpc_single_source_of_truth.md     |  3 +
 .../signup_bonus_rpc_single_source_of_truth.md     | 12 ++--
 .../signup_bonus_rpc_single_source_of_truth.md     | 60 ++++++++++++++++++--
 docs/core_logic/bonus_system.md                    |  1 +
 ...0260204000000_bonus_system_rpc_signup_bonus.sql | 12 +++-
 ...s_system_signup_bonus_profile_complete_gate.sql | 64 ++++------------------
 ..._system_reward_grants_grant_day_and_indexes.sql | 14 ++---
 ...nus_system_rpc_signup_bonus_behavior_checks.sql | 15 +++++
 8 files changed, 102 insertions(+), 79 deletions(-)
```

**git status --porcelain (preview)**

```text
 M canvases/audit_p0/signup_bonus_rpc_single_source_of_truth.md
 M codex/codex_checklist/audit_p0/signup_bonus_rpc_single_source_of_truth.md
 M codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md
 M docs/core_logic/bonus_system.md
 M supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql
 M supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql
 M supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql
 M supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql
?? codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.verify.log
```

<!-- AUTO_VERIFY_END -->
