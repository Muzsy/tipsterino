**PASS** – A reward_definitions privacy contract check és a repo gate is zöld.

## 1) Meta
* **Task slug:** `ci_reward_definitions_privacy_contract_checks`
* **Kapcsolódó canvas:** `canvases/ci/ci_reward_definitions_privacy_contract_checks.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/ci/fill_canvas_ci_reward_definitions_privacy_contract_checks.yaml`
* **Futás dátuma:** 2026-02-08
* **Fókusz terület:** CI
* **Branch / commit:** `main@03eecfd`

## 2) Scope
### 2.1 Cél
1. `reward_definitions` privacy contract automatikus SQL ellenőrzése.
2. RLS + policy + privilege invariánsok regresszióvédelme.
3. DB check + verify logok rögzítése.

### 2.2 Nem-cél
1. Új policy vagy kliens oldali táblaolvasás bevezetése.
2. Reward adatmódosítás.

## 3) Változások összefoglalója (Change summary)
### 3.1 Érintett fájlok
* `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
* `supabase/migrations/20260212000000_bonus_system_reward_definitions_privilege_contract_fix.sql`
* `docs/data_model/reward_definitions_table_doc.md`
* `codex/codex_checklist/ci/ci_reward_definitions_privacy_contract_checks.md`
* `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md`
* `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`
* `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log`

### 3.2 Miért változtak?
* Új contract check készült, ami explicit védi a `reward_definitions` tábla privacy invariánsait.
* A doksi explicit linket kapott a check fájlra és a `./scripts/check_db.sh` futtatásra.

## 4) Verifikáció (How tested)
### 4.1 Kötelező parancs
* `./scripts/verify.sh --report codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md`

### 4.2 Opcionális, feladatfüggő parancsok
* `supabase start`
* `supabase db reset --local --no-seed`
* `./scripts/check_db.sh | tee codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`
* `./scripts/check_db.sh 2>&1 | tee codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`
* `./scripts/check.sh`

## 5) DoD → Evidence Matrix (kötelező)
| DoD pont | Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Létrejött: `bonus_system_reward_definitions_privacy_contract_checks.sql` | PASS | `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql:1` | A privacy contract SQL check létrejött. | SQL check futtatás |
| FAIL-oljon `anon`/`authenticated` SELECT/INSERT/UPDATE/DELETE esetén | PASS | `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql:67` | A check explicit exception-t dob bármely kliens-jogosultság esetén. | SQL check definíció |
| FAIL-oljon policy esetén | PASS | `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql:21` | A check explicit `policy_count <> 0` esetén exception-t dob. | SQL check definíció |
| PASS a jelenlegi elvárt állapotban | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log:20` | A check lefutott és `bonus_system reward_definitions privacy contract checks passed` kimenetet adott. | `./scripts/check_db.sh` |
| Doksi hivatkozik a sql_check-re | PASS | `docs/data_model/reward_definitions_table_doc.md:113` | A tesztállapot szekció explicit hivatkozást kapott, plusz a revoke migrációra mutat. | Doksi ellenőrzés |
| DB log rögzítve | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log:1` | A DB check teljes kimenete mentve. | tee log |
| Repo gate rögzítve | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log:1` | A verify futás PASS és a report AUTO_VERIFY blokk frissült. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkoló)
* A privacy contractot egy külön privilégium-fix migráció (20260212000000) rögzíti, így regresszió esetén a sql_check azonnal bukik.

## 9) Follow-ups (opcionális)
* Nincs kötelező follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T19:02:26+01:00 → 2026-02-08T19:03:04+01:00 (38s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log`
- git: `main@03eecfd`
- módosított fájlok (git status): 6

**git diff --stat**

```text
 ...i_reward_definitions_privacy_contract_checks.md |  2 +-
 ...finitions_privacy_contract_checks.db_checks.log | 78 +++++++++++++++++++++-
 ...i_reward_definitions_privacy_contract_checks.md | 39 +++++------
 ..._definitions_privacy_contract_checks.verify.log | 12 ++--
 docs/data_model/reward_definitions_table_doc.md    |  2 +
 5 files changed, 103 insertions(+), 30 deletions(-)
```

**git status --porcelain (preview)**

```text
 M codex/codex_checklist/ci/ci_reward_definitions_privacy_contract_checks.md
 M codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log
 M codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md
 M codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log
 M docs/data_model/reward_definitions_table_doc.md
?? supabase/migrations/20260212000000_bonus_system_reward_definitions_privilege_contract_fix.sql
```

<!-- AUTO_VERIFY_END -->
