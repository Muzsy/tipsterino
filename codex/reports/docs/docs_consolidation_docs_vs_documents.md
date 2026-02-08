**PASS** – Docs konszolidáció elkészült, a repo gate sikeresen lefutott.

## 1) Meta
* **Task slug:** `docs_consolidation_docs_vs_documents`
* **Kapcsolódó canvas:** `canvases/docs/docs_consolidation_docs_vs_documents.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/docs/fill_canvas_docs_consolidation_docs_vs_documents.yaml`
* **Futás dátuma:** 2026-02-08
* **Branch / commit:** `main@54ceb17`
* **Fókusz terület:** Docs

## 2) Scope
### 2.1 Cél
1. `docs/` canonical forrásként rögzítése.
2. `documents/` deprecáció és átirányító stub stratégia bevezetése.
3. Kritikus doksik átmozgatása a `docs/` fa alá és hivatkozások átvezetése.

### 2.2 Nem-cél (explicit)
1. Flutter alkalmazáskód módosítása.
2. CI/DB pipeline logika módosítása.

## 3) Változások összefoglalója (Change summary)
### 3.1 Érintett fájlok
* `docs/architect/app_architecture.md`
* `docs/setup/supabase_configuration.md`
* `docs/core_logic/daily_bonus.md`
* `documents/app_architecture.md`
* `documents/supabase_configuration.md`
* `documents/bonus_system/daily_bonus.md`
* `documents/README_DEPRECATED.md`
* `README.md`
* `AGENTS.md`
* `docs/README.md`
* `docs/architect/project_structure.md`
* `docs/core_logic/bonus_system.md`
* `codex/codex_checklist/docs/docs_consolidation_docs_vs_documents.md`
* `codex/reports/docs/docs_consolidation_docs_vs_documents.md`
* `codex/reports/docs/docs_consolidation_docs_vs_documents.verify.log`

### 3.2 Miért változtak?
* A docs-vs-documents kettősség megszüntetése és canonical dokumentációs útvonal rögzítése.
* A régi dokumentum-útvonalak kompatibilitása deprecációs stubokkal fenntartható.

## 4) Verifikáció (How tested)
### 4.1 Kötelező parancs
* `./scripts/verify.sh --report codex/reports/docs/docs_consolidation_docs_vs_documents.md`

### 4.2 Opcionális, feladatfüggő parancsok
* `./scripts/check.sh`

## 5) DoD → Evidence Matrix (kötelező)
| DoD pont | Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `documents/README_DEPRECATED.md` létrejött | PASS | `documents/README_DEPRECATED.md:1` | A deprecációs belépő és szabályok rögzítve. | Doksi ellenőrzés |
| 3 kritikus doksi átmozgatva `docs/` alá | PASS | `docs/architect/app_architecture.md:1` | Canonical doksik új útvonalon elérhetők. | Doksi ellenőrzés |
| Régi helyeken stub marad | PASS | `documents/app_architecture.md:1` | A `documents/*` fájlok rövid átirányító stubok. | Doksi ellenőrzés |
| `docs/**` és top-level hivatkozások canonical útra állítva | PASS | `README.md:7` | Kötelezően jelölt fájlokban `docs/` canonical lett. | Doksi ellenőrzés |
| `AGENTS.md` source-of-truth sorrend javítva | PASS | `AGENTS.md:174` | A `docs/` megelőzi a `documents/` mappát. | Doksi ellenőrzés |
| Repo gate futtatva és log mentve | PASS | `codex/reports/docs/docs_consolidation_docs_vs_documents.verify.log:1` | A verify futás PASS, a log létrejött és az AUTO_VERIFY blokk frissült. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkoló)
* A `documents/` mappa megtartható kompatibilitási célra, de tartalma maradjon rövid stub.

## 9) Follow-ups (opcionális)
* Nincs kötelező follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T23:02:43+01:00 → 2026-02-08T23:03:22+01:00 (39s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/docs/docs_consolidation_docs_vs_documents.verify.log`
- git: `main@54ceb17`
- módosított fájlok (git status): 16

**git diff --stat**

```text
 AGENTS.md                             |  8 +--
 README.md                             |  3 +-
 docs/README.md                        |  6 ++-
 docs/architect/project_structure.md   |  7 ++-
 docs/core_logic/bonus_system.md       |  2 +-
 documents/app_architecture.md         | 29 +++--------
 documents/bonus_system/daily_bonus.md | 94 +++--------------------------------
 documents/supabase_configuration.md   | 24 +++------
 8 files changed, 32 insertions(+), 141 deletions(-)
```

**git status --porcelain (preview)**

```text
 M AGENTS.md
 M README.md
 M docs/README.md
 M docs/architect/project_structure.md
 M docs/core_logic/bonus_system.md
 M documents/app_architecture.md
 M documents/bonus_system/daily_bonus.md
 M documents/supabase_configuration.md
?? canvases/docs/
?? codex/codex_checklist/docs/
?? codex/goals/canvases/docs/
?? codex/reports/docs/
?? docs/architect/app_architecture.md
?? docs/core_logic/daily_bonus.md
?? docs/setup/
?? documents/README_DEPRECATED.md
```

<!-- AUTO_VERIFY_END -->
