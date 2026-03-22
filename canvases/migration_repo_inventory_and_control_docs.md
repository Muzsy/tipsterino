# Canvas: Migration Repo Inventory & Control Docs

## 🎯 Cél

Elkészíteni a Tipsterino migrációs kontrollréteg első dokumentumait a `tipsterino` (target) és `tippmixapp` (source) repók repo-alapú, bizonyítékvezérelt felmérése alapján.

## 📌 Nem-cél (explicit)

- Nem implementál kódot a Tipsterino `app/` mappába.
- Nem ír át Firebase/Firestore logikát.
- Nem módosít secret vagy `.env` fájlt.
- Nem hoz létre migrációs DB sémát.

## 📂 Érintett modulok

### Tipsterino (target)
- `canvases/` — canvas fájlok
- `codex/goals/canvases/` — goal YAML-ek
- `codex/prompts/openclaw/` — OpenClaw task prompt-ok
- `codex/codex_checklist/` — pipálható checklistek
- `codex/reports/openclaw/` — riportok
- `docs/` — canonical docs
- `app/lib/` — fejlesztési célpont (üres scaffold)

### TippmixApp (source/reference)
- `lib/` — teljes app kód
- `docs/` — architektúra, backend, frontend, features docs
- `supabase/` — DB migrations + functions
- `cloud_functions/` — Firebase Cloud Functions
- `canvases/` — canvas archívum

## ✅ Feladat-lista

### Phase 1 — Repo inventory
- [ ] Required reading fájlok elolvasása (AGENTS.md, docs/codex/*, docs/architect/*)
- [ ] Tipsterino szerepkép rögzítése: target, Supabase-only, feature-first canvas+yaml workflow
- [ ] TippmixApp szerepkép rögzítése: source, Firebase+Supabase hybrid, teljes implementáció
- [ ] Legfontosabb mappák azonosítása migráció vezérléséhez

### Phase 2 — Difference mapping
- [ ] Repo struktúra különbség: lib/features vs app/lib/src/features
- [ ] Dokumentációs réteg különbség: canonical docs fa vs scattered + artifact halmaz
- [ ] Codex workflow réteg: hasonló struktúra, de külön repók
- [ ] Backend különbség: Supabase-only vs Firebase+Supabase hybrid
- [ ] Flutter app elhelyezés: app/ vs root lib/
- [ ] CI/belépési pontok: wrapper scriptek vs pnpm monorepo + Firebase scripts

### Phase 3 — Control-doc design
- [ ] Canvas útvonal: canvases/migration_repo_inventory_and_control_docs.md
- [ ] Goal YAML útvonal: codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml
- [ ] Task prompt útvonal: codex/prompts/openclaw/migration_control_docs.task.md
- [ ] Checklist útvonal: codex/codex_checklist/migration_repo_inventory_and_control_docs.md
- [ ] Report útvonal: codex/reports/openclaw/migration_repo_inventory_and_control_docs.<timestamp>.report.md

### Phase 4 — Create initial control docs
- [ ] Canvas fájl létrehozása
- [ ] Goal YAML létrehozása steps + outputs-szal
- [ ] OpenClaw task prompt létrehozása hosszú, többfázisú feladattal
- [ ] Checklist létrehozása evidence-fókuszú pipálható listával
- [ ] Report stub kitöltése minden kötelező szekcióval

### Phase 5 — Verification
- [ ] Összes létrehozott fájl útvonal ellenőrzése
- [ ] Útvonalak illeszkednek-e a Tipsterino meglévő struktúrájához
- [ ] Párhuzamos workflow-rendszer nem nyílt
- [ ] verify.sh futtatása vagy dokumentált ok megadása

## ⚠️ Kockázatok

1. **Tipsterino scaffold üres** — az app kód migráció külön feladat, ez csak a kontrollréteg
2. **Firebase/Firestore kód descoping** — a TippmixApp Firebase része nem migrálható, dokumentálni kell
3. **Auth binding modell** — Supabase-only célstack vs Firebase UID binding: auth migrációs stratégia hiányzik
4. **Feature mapping** — TippmixApp `lib/features/` → Tipsterino `app/lib/src/features/` mapping: nincs még terv

## 🔄 Rollback terv

Ha az útvonalak nem illeszkednek: állj meg, és jelezd a reportban. Ne hozz létre új top-level könyvtárat.

---

**Created:** 2026-03-21  
**Task slug:** `migration_repo_inventory_and_control_docs`
