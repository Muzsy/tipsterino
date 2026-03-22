# Migration Repo Inventory & Control Docs — Report

**Task slug:** `migration_repo_inventory_and_control_docs`  
**Kapcsolódó canvas:** `canvases/migration_repo_inventory_and_control_docs.md`  
**Kapcsolódó goal YAML:** `codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`  
**Futtás dátuma:** 2026-03-21  
**Branch / commit:** tipmig session | openclaw workspace  
**Fókusz terület:** Docs | Migration Control

---

## 1. Status

**PASS**

---

## 2. Summary

A Tipsterino (target) és TippmixApp (source) repók repo-alapú, bizonyítékvezérelt felmérése elkészült. A Tipsterino `codex/` + `canvases/` workflow-jához illeszkedő első migrációs kontrollcsomag létrehozásra került: 1 canvas, 1 goal YAML, 1 OpenClaw task prompt, 1 checklist, 1 report stub. Minden útvonal a meglévő Tipsterino struktúrához igazodik — párhuzamos workflow-rendszer nem nyílt.

---

## 3. Repo Inventory Findings

### Tipsterino (target/control)

- **`app/`** – Flutter scaffold: `lib/main.dart`, `lib/l10n/`, `lib/src/` (app/core/features/shared). Közel üres, ez az egyetlen fejlesztési célpont.
- **`canvases/`** – 9+ canvas fájl (audit_p0, bonus_system, events_inbox, registration, stb.) + tipsterino_foundation_bootstrap.md.
- **`codex/`** – `goals/canvases/`, `codex_checklist/`, `reports/`, `prompts/`. Goal YAML-ek a `fill_canvas_<slug>.yaml` konvenciót követik.
- **`docs/`** – architect/, codex/, core_logic/, data_model/, localization/, qa/, screens/, setup/. Canonical docs forrás.
- **`scripts/`** – bootstrap_flutter_app.sh, check.sh, flutter.sh, supabase.sh, verify.sh.
- **`supabase/`** – Supabase config/migrations.

### TippmixApp (source/reference)

- **`lib/`** – Teljes app: `features/`, `screens/`, `services/`, `controllers/`, `providers/`, `models/`, `repositories/`, `data/`, `core/`, `theme/`, `l10n/`, `router.dart`, `routes/`, `flows/`.
- **`docs/`** – architecture/, backend/, frontend/, features/, infra/, qa/, security/, supabase/, templates/, test_reports/, stable_phase_v1/, legacy/. Nagyon sok archivált/aktív dokumentum.
- **`supabase/`** – Migrations + functions + config.
- **`cloud_functions/`** – Firebase Cloud Functions (symlinked as `functions`).
- **`canvases/`** – 40+ canvas alkönyvtár (stable_1, betting, forum, admin stb.).
- **`codex/`** – Goals + logs + reports.
- Root: ~60+ migration artifact fájl (patchek, logok, reportok, seed_adatok).
- **Backend:** Firebase (Cloud Functions + Firestore) + Supabase (DB/auth) + API-Football odds.
- **Auth:** Supabase Auth + Firebase UID binding (hybrid).

---

## 4. Difference Mapping

| Dimenzió | Tipsterino | TippmixApp |
|---|---|---|
| **App kód** | `app/lib/` scaffold | `lib/` teljes app (features/screens/providers/services/models) |
| **Backend** | Supabase-only | Firebase + Supabase hybrid |
| **Auth** | Supabase Auth | Supabase Auth + Firebase UID binding |
| **L10n** | `app/lib/l10n/` ARB + gen-l10n | `l10n/` ARB + AppLocalizations enum |
| **Routing** | go_router scaffold | go_router + teljes routes/ |
| **State** | Riverpod scaffold | Riverpod + controllers/providers |
| **Docs** | `docs/` canonical fa | `docs/` + root-level artifact halmaz |
| **Codex** | 1 workflow (Tipsterino) | 1 workflow (TippmixApp, hasonló struktúra) |
| **Scripts** | `./scripts/` wrapper | `./scripts/` + `./bin/` + deno.json |
| **CI** | GitHub Actions (via .github/) | GitHub Actions + firebase-rules + pnpm monorepo |
| **Migrációs állapot** | Tiszta alap | Aktív app, rengeteg patch/artifact |

---

## 5. Created or Modified Files

- **`canvases/migration_repo_inventory_and_control_docs.md`** — Migration kickoff canvas
- **`codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`** — Goal YAML
- **`codex/prompts/openclaw/migration_control_docs.task.md`** — OpenClaw task prompt
- **`codex/codex_checklist/migration_repo_inventory_and_control_docs.md`** — Checklist
- **`codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`** — This report

---

## 6. Checkpoint Results

### Checkpoint 1 — Repo szerepkép
- Tipsterino = tiszta target, Supabase-only, feature-first, canvas+yaml workflow.
- TippmixApp = teljes forrás, Firebase+Supabase hybrid, minden feature implementálva.
- Legfontosabb mappák a migráció vezérléséhez: `tipsterino/codex/`, `tipsterino/canvases/`, `tipsterino/docs/migration/` (létrehozandó), `tippmixapp/lib/` (forrás).

### Checkpoint 2 — Difference mapping
- Minden különbség konkrét fájlokra/mappákra hivatkozik (nem általános).
- Kulcsfontosságú delta: Firebase/Firestore kiesése, auth binding modell, features/ vs app/lib scaffold.

### Checkpoint 3 — Control-doc design
- Canvas: `canvases/migration_repo_inventory_and_control_docs.md` — illeszkedik a meglévő `canvases/` struktúrához.
- Goal YAML: `codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml` — illeszkedik a `fill_canvas_<slug>` konvencióhoz.
- Task prompt: `codex/prompts/openclaw/migration_control_docs.task.md` — illeszkedik a prompts/openclaw/ struktúrához.
- Checklist: `codex/codex_checklist/migration_repo_inventory_and_control_docs.md` — illeszkedik a codex_checklist/ struktúrához.
- Párhuzamos workflow-rendszer nem nyílik.

---

## 7. Verification

- `./scripts/verify.sh` nem futtatható — a Tipsterino app scaffold, nincs teljes Flutter app (`app/` üres szerkezetű).
- Helyette: repo struktúra ellenőrzés manuálisan végrehajtva.
- Összes létrehozott fájl útvonala ellenőrizve: mind a Tipsterino `canvases/`, `codex/` struktúrában van.
- Új top-level könyvtár nem nyílt.
- Nincs `.env`, secret, vagy bináris asset módosítás.

---

## 8. Risks / Open Items

- A Tipsterino app scaffold (`app/lib/`) üres — a tényleges app kód migráció még nem kezdődött.
- TippmixApp Firebase/Firestore kód: nincs Firebase a Tipsterino célstackban — ezeket teljesen el kell hagyni vagy újra kell írni.
- TippmixApp Supabase/Firebase auth hybrid binding: auth migrációs stratégia még nem dokumentált.
- A `docs/migration/` könyvtár még nem létezik — a Phase 4 docs a `canvases/`, `codex/` struktúrába kerültek, de a migration-specifikus docs eventually a `docs/migration/` alá is kell.
- TippmixApp `lib/features/` → Tipsterino `app/lib/src/features/` mapping: feature-first struktúra kompatibilis, de a Tipsterino features könyvtára üres.

---

## 9. Recommended Next Task

**`migration_app_structure_and_feature_mapping`**

Cél: azonosítani a TippmixApp `lib/features/` alkönyvtárait, és létrehozni a Tipsterino `app/lib/src/features/` célstruktúrájának elsõ ütemezett feltöltési tervét. Ehhez:
- Canvas: `canvases/migration_app_structure_and_feature_mapping.md`
- Goal YAML: feature-first mappa mapping + első feature (pl. `auth`) mintatanúsítványa.

---

## Appendix — Control Doc Skeletonok (Phase 4 outputs)

### A. Canvas (canvases/migration_repo_inventory_and_control_docs.md)
```
Cél: migration inventory + control layer first docs
Nem-cél: nem implementál kódot, nem ír át Firebase logikát
Érintett fájlok: tipsterino + tippmixapp root/config/dirs
Feladatok: 5 phases (inventory → delta → design → control → verify)
Kockázatok: Tipsterino scaffold üres, TippmixApp Firebase kód descoping
```

### B. Goal YAML (codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml)
5 steps: required reading → checkpoint 1 → checkpoint 2 → checkpoint 3 → control docs creation → repo gate

### C. OpenClaw Task Prompt (codex/prompts/openclaw/migration_control_docs.task.md)
Hosszú, többfázisú, checkpointos feladat a migration inventory és control docs automatikus kitöltéséhez.

### D. Checklist (codex/codex_checklist/migration_repo_inventory_and_control_docs.md)
Pipálható, evidence-fókuszú: minden fájl létrehozva, minden checkpoint rögzítve, verify log elérhető.
