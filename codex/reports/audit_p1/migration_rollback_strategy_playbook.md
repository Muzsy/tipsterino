**PASS** - migration rollback strategy playbook elkeszult, setup/QA doksik hivatkozasai szinkronban, verify PASS.

## 1) Meta
- **Task slug:** migration_rollback_strategy_playbook
- **Kapcsolodo canvas:** canvases/audit_p1/migration_rollback_strategy_playbook.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_migration_rollback_strategy_playbook.yaml
- **Futas datuma:** 2026-02-09
- **Branch / commit:** main
- **Fokusz terulet:** Docs + QA

## 2) Scope
### 2.1 Cel
- Rollback playbook dokumentalasa local/stage/prod dontesi agakkal.
- Kotelezo verifikacios lepesek rogzitese rollback utan.
- Setup es DB check doksik osszekotese az uj playbookkal.

### 2.2 Nem-cel (explicit)
- Down migration framework implementalas.
- Production migration futtatas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/migration_rollback_strategy_playbook.md`
- `docs/qa/migration_rollback_strategy.md`
- `docs/setup/supabase_setup.md`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p1/migration_rollback_strategy_playbook.md`
- `codex/reports/audit_p1/migration_rollback_strategy_playbook.md`

### 3.2 Miert valtoztak?
- Letrejott egy canonical rollback playbook, amely tartalmazza a rollback vs forward-fix dontesi fat.
- A setup es DB checks dokumentumok explicit a playbookra mutatnak incident kezeleshez.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/migration_rollback_strategy_playbook.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check.sh`

### 4.3 Eredmeny roviden
- `./scripts/verify.sh --report codex/reports/audit_p1/migration_rollback_strategy_playbook.md` PASS.
- A report AUTO_VERIFY blokkban rögzítve a doksi-gate futas eredmenye.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| letezik lepesrol-lepesre rollback eljaras local/stage/prod szintre bontva | PASS | `docs/qa/migration_rollback_strategy.md:1` | A playbook kulon runbookokat ad local, stage es prod kornyezetre. | `./scripts/verify.sh --report ...` |
| tartalmazza a kotelezo utolagos verifikaciot (db reset/check_db/verify) | PASS | `docs/qa/migration_rollback_strategy.md:60` | A playbook explicit minimum verifikacios checklistet ir rollback utan. | `./scripts/verify.sh --report ...` |
| tartalmaz migration incident dontesi fat (rollback vs forward-fix) | PASS | `docs/qa/migration_rollback_strategy.md:16` | A decision tree szabalyozza, mikor rollback es mikor forward-fix az elvart irany. | `./scripts/verify.sh --report ...` |
| setup es QA doksik hivatkoznak a playbookra | PASS | `docs/setup/supabase_setup.md:30` | A setup guide rollback szekcioja az uj playbookra mutat; a DB checks guide is hivatkozza. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- Stage/prod visszaallitasnal a csapat uzemeltetesi policyja az iranyado; a playbook ezt keretezi, nem helyettesiti.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T00:03:55+01:00 → 2026-02-10T00:04:36+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/migration_rollback_strategy_playbook.verify.log`
- git: `main@dc7df1a`
- módosított fájlok (git status): 7

**git diff --stat**

```text
 .../migration_rollback_strategy_playbook.md        |  1 +
 .../migration_rollback_strategy_playbook.md        | 12 +++----
 .../migration_rollback_strategy_playbook.md        | 39 ++++++++++++++--------
 docs/qa/db_checks.md                               |  7 ++++
 docs/setup/supabase_setup.md                       |  7 ++++
 5 files changed, 47 insertions(+), 19 deletions(-)
```

**git status --porcelain (preview)**

```text
 M canvases/audit_p1/migration_rollback_strategy_playbook.md
 M codex/codex_checklist/audit_p1/migration_rollback_strategy_playbook.md
 M codex/reports/audit_p1/migration_rollback_strategy_playbook.md
 M docs/qa/db_checks.md
 M docs/setup/supabase_setup.md
?? codex/reports/audit_p1/migration_rollback_strategy_playbook.verify.log
?? docs/qa/migration_rollback_strategy.md
```

<!-- AUTO_VERIFY_END -->
