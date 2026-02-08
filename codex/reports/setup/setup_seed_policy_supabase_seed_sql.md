**PASS** - Seed policy dokumentacio kesz, verify es check gate zold.

## 1) Meta
* **Task slug:** `setup_seed_policy_supabase_seed_sql`
* **Kapcsolodo canvas:** `canvases/setup/setup_seed_policy_supabase_seed_sql.md`
* **Kapcsolodo goal YAML:** `codex/goals/canvases/setup/fill_canvas_setup_seed_policy_supabase_seed_sql.yaml`
* **Futas datuma:** 2026-02-08
* **Branch / commit:** `main@134e953`
* **Fokusz terulet:** Docs

## 2) Scope
### 2.1 Cel
1. A `supabase/seed.sql` celjanak es no-op policyjenek egyertelmu rogzitese.
2. Seed policy dokumentalasa CI-vs-lokal szemszogbol.
3. DB check dokumentacio kiegeszitese seed-policy hivatkozassal.

### 2.2 Nem-cel (explicit)
1. Schema/migracio modositas.
2. CI workflow implementacios atirasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
* `supabase/seed.sql`
* `docs/qa/seed_policy.md`
* `docs/qa/db_checks.md`
* `codex/codex_checklist/setup/setup_seed_policy_supabase_seed_sql.md`
* `codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`
* `codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log`

### 3.2 Miert valtoztak?
* A seed-policy explicitte teszi, hogy CI es contract check seed nelkul fut.
* A seed placeholder most mar felreerthetetlenul dokumentalt no-op.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
* `./scripts/verify.sh --report codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`

### 4.2 Opcionlis, feladatfuggo parancsok
* `./scripts/check.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `supabase/seed.sql` no-op policy explicit | PASS | `supabase/seed.sql:1` | A fajl policy headerrel irja le a no-op es `--no-seed` elvet. | Doksi ellenorzes |
| Letrejott `docs/qa/seed_policy.md` | PASS | `docs/qa/seed_policy.md:1` | Kulon policy doksi rogzitve CI/lokal seed strategiarol. | Doksi ellenorzes |
| `docs/qa/db_checks.md` seed-policy hivatkozassal kiegeszitve | PASS | `docs/qa/db_checks.md:15` | A `--no-seed` melle odakerult az indoklas es a policy link. | Doksi ellenorzes |
| Letrejott checklist + report vaz | PASS | `codex/codex_checklist/setup/setup_seed_policy_supabase_seed_sql.md:1` | Task artefaktok letrehozva a setup area alatt. | Doksi ellenorzes |
| Repo gate lefutott es log mentve | PASS | `codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log:1` | A verify futas PASS, a log letrejott es az AUTO_VERIFY blokk frissult. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
* Ha a jovoben seed bevezetese szukseges, CI policy maradjon seedless.

## 9) Follow-ups (opcionalis)
* Nincs kotelezo follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T23:35:54+01:00 → 2026-02-08T23:36:33+01:00 (39s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log`
- git: `main@134e953`
- módosított fájlok (git status): 8

**git diff --stat**

```text
 docs/qa/db_checks.md |  2 ++
 supabase/seed.sql    | 23 +++++++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)
```

**git status --porcelain (preview)**

```text
 M docs/qa/db_checks.md
 M supabase/seed.sql
?? canvases/setup/setup_seed_policy_supabase_seed_sql.md
?? codex/codex_checklist/setup/setup_seed_policy_supabase_seed_sql.md
?? codex/goals/canvases/setup/fill_canvas_setup_seed_policy_supabase_seed_sql.yaml
?? codex/reports/setup/setup_seed_policy_supabase_seed_sql.md
?? codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log
?? docs/qa/seed_policy.md
```

<!-- AUTO_VERIFY_END -->
