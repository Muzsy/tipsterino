**PASS** - user_events olvasatlan listahoz partial index migracio + DB contract check + data model doksi frissites elkeszult, check_db es verify PASS.

## 1) Meta
- **Task slug:** user_events_unread_partial_index
- **Kapcsolodo canvas:** canvases/audit_p1/user_events_unread_partial_index.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_user_events_unread_partial_index.yaml
- **Futas datuma:** 2026-02-09
- **Branch / commit:** main
- **Fokusz terulet:** DB + docs

## 2) Scope
### 2.1 Cel
- `user_events` olvasatlan lista lekero teljesitmenyenek javitasa partial index szerzodessel.
- DB contract check kiterjesztese az uj indexre.
- Data model doksiban az index szerzodes formalizalasa.

### 2.2 Nem-cel (explicit)
- user_events repository API/viselkedes valtoztatas.
- Inbox UI atalakitas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/user_events_unread_partial_index.md`
- `supabase/migrations/20260214000000_user_events_unread_partial_index.sql`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `docs/data_model/user_events_table_doc.md`
- `codex/codex_checklist/audit_p1/user_events_unread_partial_index.md`
- `codex/reports/audit_p1/user_events_unread_partial_index.md`

### 3.2 Miert valtoztak?
- Letrejott a `user_events_user_unread_created_at_idx` partial index (`read_at is null`) a hot-path olvasatlan listara.
- A DB contract check explicit validalja az index nevet es predicate contractot.
- A data model dokumentacio rogzitett index-szerzodest kapott, teljesitmeny rationale-lal.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/user_events_unread_partial_index.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/supabase.sh db reset --local --no-seed`
- `./scripts/check_db.sh`

### 4.3 Eredmeny roviden
- `./scripts/supabase.sh db reset --local --no-seed` PASS (uj migracio alkalmazva local DB-re).
- `./scripts/check_db.sh` PASS (a `bonus_system_user_events_db_contract_checks.sql` az uj unread partial index ellenorzessel zold).
- `./scripts/verify.sh --report codex/reports/audit_p1/user_events_unread_partial_index.md` PASS.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| letezik partial index olvasatlan (`read_at is null`) user_events listara | PASS | `supabase/migrations/20260214000000_user_events_unread_partial_index.sql:2` | Az index kulcsa `user_id, created_at desc`, predicate `read_at is null`. | `./scripts/check_db.sh` |
| DB contract check validalja az index jelenletet | PASS | `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql:138` | A check explicit az `user_events_user_unread_created_at_idx` nevet es a partial predicate-et is ellenorzi. | `./scripts/check_db.sh` |
| migracio idempotens (if not exists / safe rerun) | PASS | `supabase/migrations/20260214000000_user_events_unread_partial_index.sql:2` | `create index if not exists` miatt ujrafuttatas biztonsagos. | `./scripts/supabase.sh db reset --local --no-seed` |
| reportban szerepel teljesitmeny rationale | PASS | `docs/data_model/user_events_table_doc.md:131` | Az index szerzodeshez rogzitesre kerult az unread listahoz tartozo teljesitmeny indoklas. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- Nagy volumen mellett a partial index karbantartasi koltsege mersekelt, de incident eseten a migration rollback playbook kovetendo (`docs/qa/migration_rollback_strategy.md`).

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T00:23:57+01:00 → 2026-02-10T00:24:37+01:00 (40s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/user_events_unread_partial_index.verify.log`
- git: `main@58726ab`
- módosított fájlok (git status): 7

**git diff --stat**

```text
 .../audit_p1/user_events_unread_partial_index.md   |  1 +
 .../audit_p1/user_events_unread_partial_index.md   | 12 +++----
 .../audit_p1/user_events_unread_partial_index.md   | 42 +++++++++++++++-------
 docs/data_model/user_events_table_doc.md           | 11 ++++++
 ...bonus_system_user_events_db_contract_checks.sql | 15 ++++++++
 5 files changed, 62 insertions(+), 19 deletions(-)
```

**git status --porcelain (preview)**

```text
 M canvases/audit_p1/user_events_unread_partial_index.md
 M codex/codex_checklist/audit_p1/user_events_unread_partial_index.md
 M codex/reports/audit_p1/user_events_unread_partial_index.md
 M docs/data_model/user_events_table_doc.md
 M supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql
?? codex/reports/audit_p1/user_events_unread_partial_index.verify.log
?? supabase/migrations/20260214000000_user_events_unread_partial_index.sql
```

<!-- AUTO_VERIFY_END -->
