# P1-1: Dokumentáció konszolidáció — docs/ canonical, documents/ deprecated

## 🎯 Funkció
Cél: szüntessük meg a `docs/` vs `documents/` kettősségből adódó bizonytalanságot.

Elv:
- A `docs/` a **single source of truth** minden fejlesztői szabályra és naprakész leírásra.
- A `documents/` **deprecated/archív**: csak hivatkozó stubok + egy deprecációs index maradjon, új tartalom oda **nem** kerül.

Nem cél:
- Új funkció / Flutter kód módosítás.
- P1-2 setup guide teljes kidolgozása (itt csak a doksi-kettősség megszüntetése + minimális átemelés).
- CI / DB pipeline változtatás (P0 már kész).

## 🧠 Fejlesztési részletek

### Kiinduló probléma (repo bizonyíték)
- Root README `documents/`-et aktívan promotál: `README.md`
- `docs/README.md` és `docs/architect/project_structure.md` is `documents/`-re mutat.
- `docs/core_logic/bonus_system.md` a daily bonus specifikációt a `documents/bonus_system/daily_bonus.md` fájlba delegálja.

### Döntés (rögzítendő)
- **Canonical:** `docs/`
- **Deprecated:** `documents/` (back-compat hivatkozások/stubok maradhatnak)

### Migrációs minimum (hivatkozott “kritikus” doksik)
A következő, `docs/` által hivatkozott dokumentumok kerüljenek át `docs/` alá (frissített, valós fájlútvonalakkal), és a régi helyükön csak stub maradjon:

| Régi (documents) | Új (docs) |
|---|---|
| `documents/app_architecture.md` | `docs/architect/app_architecture.md` |
| `documents/supabase_configuration.md` | `docs/setup/supabase_configuration.md` |
| `documents/bonus_system/daily_bonus.md` | `docs/core_logic/daily_bonus.md` |

Megjegyzés: az átemelt tartalomban a repo jelenlegi belépési pontjai legyenek az irányadók:
- Flutter futtatás/teszt: `./scripts/flutter.sh ...` (nem közvetlen `cd app && flutter ...`)
- Repo gate: `./scripts/verify.sh --report ...`

### Hivatkozások átvezetése (kötelező)
Frissítendő fájlok, hogy sehol ne “documents/ legyen a naprakész forrás”:
- `README.md` (root)
- `AGENTS.md` (Repo gyors térkép + Forrás-igazság prioritás)
- `docs/README.md` (Kapcsolódó anyagok)
- `docs/architect/project_structure.md` (`documents/` említések + linkek)
- `docs/core_logic/bonus_system.md` (daily bonus link)
- + bármely további `docs/**` fájl, ami `documents/`-re mutat (keresés alapján)

### Új/érintett fájlok (task artefaktok)
- Új: `canvases/docs/docs_consolidation_docs_vs_documents.md`
- Új: `codex/goals/canvases/docs/fill_canvas_docs_consolidation_docs_vs_documents.yaml`
- Új: `codex/codex_checklist/docs/docs_consolidation_docs_vs_documents.md`
- Új: `codex/reports/docs/docs_consolidation_docs_vs_documents.md`
- Auto: `codex/reports/docs/docs_consolidation_docs_vs_documents.verify.log`

### Kockázatok / rollback
- Kockázat: régi hivatkozások törnek (csak doksi szinten).
  - Kezelés: `documents/*` helyén stub marad, ami az új `docs/*` helyre mutat.
- Rollback: visszaállítható a stubok előtti állapot (`git revert`), mivel csak markdown változik.

### DoD (pipálható)
- [ ] `documents/` kap egy egyértelmű deprecációs belépőt: `documents/README_DEPRECATED.md` (migrációs térképpel).
- [ ] A 3 kritikus doksi tartalma `docs/` alá átkerült (új fájlok), a régi helyükön stub van.
- [ ] Minden `docs/**` és top-level doksi hivatkozás az új `docs/` útvonalakra mutat (nincs “naprakész forrás” a `documents/` alatt).
- [ ] `AGENTS.md` Forrás-igazság prioritásban a `docs/` a `documents/` elé kerül, és a `documents/` deprecatedként van megjelölve.
- [ ] Repo gate lefuttatva és rögzítve:
  `./scripts/verify.sh --report codex/reports/docs/docs_consolidation_docs_vs_documents.md`
  (report státusz + `.verify.log` megvan).

## 🧪 Tesztállapot
- Kötelező (task zárás):
  `./scripts/verify.sh --report codex/reports/docs/docs_consolidation_docs_vs_documents.md`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `AGENTS.md` (forrás-igazság, workflow)
- `docs/codex/overview.md`
- `docs/codex/yaml_schema.md`
- `docs/codex/report_standard.md`
- `docs/qa/testing_guidelines.md`
- Repo gate: `scripts/check.sh`, `scripts/verify.sh`
- Dokumentációs belépők: `README.md`, `docs/README.md`
