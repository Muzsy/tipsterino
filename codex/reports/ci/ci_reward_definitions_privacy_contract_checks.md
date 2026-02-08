**FAIL** – A privacy contract check jogosultság-sértést talált (`anon SELECT` a `reward_definitions` táblán).

## 1) Meta
* **Task slug:** `ci_reward_definitions_privacy_contract_checks`
* **Kapcsolódó canvas:** `canvases/ci/ci_reward_definitions_privacy_contract_checks.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/ci/fill_canvas_ci_reward_definitions_privacy_contract_checks.yaml`
* **Futás dátuma:** 2026-02-08
* **Fókusz terület:** CI
* **Branch / commit:** `main@0ed99aa`

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
| FAIL-oljon `anon`/`authenticated` SELECT/INSERT/UPDATE/DELETE esetén | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log:17` | A check ténylegesen FAIL-olt `anon has SELECT on reward_definitions` hibával. | `./scripts/check_db.sh` |
| FAIL-oljon policy esetén | PASS | `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql:21` | A check explicit `policy_count <> 0` esetén exception-t dob. | SQL check definíció |
| PASS a jelenlegi elvárt állapotban | FAIL | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log:17` | A jelenlegi DB privilégiumok sértik a privacy contractot (`anon SELECT`). | `./scripts/check_db.sh` |
| Doksi hivatkozik a sql_check-re | PASS | `docs/data_model/reward_definitions_table_doc.md:113` | A tesztállapot szekció explicit hivatkozást kapott. | Doksi ellenőrzés |
| DB log rögzítve | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log:1` | A DB check teljes kimenete mentve. | tee log |
| Repo gate rögzítve | PASS | `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log:1` | A verify futás PASS és a report AUTO_VERIFY blokk frissült. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkoló)
* A `reward_definitions` táblán jelenleg alapértelmezett táblaszintű privilégiumok vannak `anon`/`authenticated` role-okra; ez RLS mellett is sérti a most bevezetett „no grant” contractot.

## 9) Follow-ups (opcionális)
* A teljes zöld állapothoz migráció szükséges (`REVOKE ALL ON TABLE public.reward_definitions FROM anon, authenticated;`), de ez nem szerepel a jelen task `outputs` listájában.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T18:21:27+01:00 → 2026-02-08T18:22:06+01:00 (39s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log`
- git: `main@0ed99aa`
- módosított fájlok (git status): 9

**git diff --stat**

```text
 .../ci/fill_canvas_ci_db_contract_checks_pipeline.yaml | 18 +++++++++---------
 docs/data_model/reward_definitions_table_doc.md        |  2 ++
 2 files changed, 11 insertions(+), 9 deletions(-)
```

**git status --porcelain (preview)**

```text
 M codex/goals/canvases/ci/fill_canvas_ci_db_contract_checks_pipeline.yaml
 M docs/data_model/reward_definitions_table_doc.md
?? canvases/ci/ci_reward_definitions_privacy_contract_checks.md
?? codex/codex_checklist/ci/ci_reward_definitions_privacy_contract_checks.md
?? codex/goals/canvases/ci/fill_canvas_ci_reward_definitions_privacy_contract_checks.yaml
?? codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log
?? codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md
?? codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log
?? supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql
```

<!-- AUTO_VERIFY_END -->
