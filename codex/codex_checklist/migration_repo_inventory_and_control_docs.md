# Codex Checklist: migration_repo_inventory_and_control_docs

**Task slug:** `migration_repo_inventory_and_control_docs`  
**Fókusz:** Docs | Migration Control  
**Created:** 2026-03-21

---

## Section 1 — Repo Inventory

- [ ] **Tipsterino AGENTS.md elolvasva**
  - Evidence: `repos/tipsterino/AGENTS.md`
  - Ellenőrzés: fájl létezik, szabályok rögzítve

- [ ] **Tipsterino Codex docs elolvasva**
  - Evidence: `repos/tipsterino/docs/codex/overview.md`, `yaml_schema.md`, `report_standard.md`
  - Ellenőrzés: fájlok léteznek, kötelező szekciók azonosítva

- [ ] **Tipsterino architect docs elolvasva**
  - Evidence: `repos/tipsterino/docs/architect/project_structure.md`, `service_dependencies.md`
  - Ellenőrzés: feature-first struktúra és Supabase-only stack rögzítve

- [ ] **Tipsterino localization docs elolvasva**
  - Evidence: `repos/tipsterino/docs/localization/localization_logic.md`
  - Ellenőrzés: ARB HU+EN konvenciók rögzítve

- [ ] **TippmixApp AGENTS.md elolvasva**
  - Evidence: `repos/tippmixapp/AGENTS.md`
  - Ellenőrzés: Firebase+Supabase hybrid stack és sandbox szabály rögzítve

- [ ] **TippmixApp DEV.md elolvasva**
  - Evidence: `repos/tippmixapp/DEV.md`
  - Ellenőrzés: Flutter+pnpm+Supabase CLI+Deno stack rögzítve

- [ ] **TippmixApp codex_docs elolvasva**
  - Evidence: `repos/tippmixapp/codex_docs/codex_readme_en.md`, `service_dependencies_en.md`
  - Ellenőrzés: canvas+yaml workflow és service dependency graph rögzítve

---

## Section 2 — Difference Mapping

- [ ] **Repo struktúra különbség rögzítve**
  - Evidence: tipsterino `app/` (üres scaffold) vs tippmixapp `lib/` (teljes app)
  - Ellenőrzés: konkrét útvonalak és tartalom különbség

- [ ] **Dokumentációs réteg különbség rögzítve**
  - Evidence: tipsterino `docs/` canonical fa vs tippmixapp `docs/` + root artifact halmaz
  - Ellenőrzés: 6+ dimenzió azonosítva táblázatban

- [ ] **Codex workflow réteg különbség rögzítve**
  - Evidence: tipsterino 9+ canvas vs tippmixapp 40+ canvas, hasonló de külön repo
  - Ellenőrzés: struktúra kompatibilitás igazolva

- [ ] **Backend különbség rögzítve**
  - Evidence: tipsterino Supabase-only vs tippmixapp Firebase Cloud Functions + Firestore + Supabase
  - Ellenőrzés: auth binding modell különbség azonosítva

- [ ] **Flutter app elhelyezés különbség rögzítve**
  - Evidence: tipsterino `app/` alkönyvtár vs tippmixapp root `lib/`
  - Ellenőrzés: feature-first struktúra kompatibilitás

- [ ] **CI/belépési pontok különbség rögzítve**
  - Evidence: tipsterino wrapper scripttek vs tippmixapp pnpm + Firebase scripts + GitHub Actions
  - Ellenőrzés: verify.sh és check.sh elérhetőség

---

## Section 3 — Control-Doc Design

- [ ] **Canvas útvonal illeszkedik a Tipsterino struktúrához**
  - Evidence: `repos/tipsterino/canvases/migration_repo_inventory_and_control_docs.md`
  - Ellenőrzés: meglévő `canvases/` struktúrában van, nem nyit új top-level könyvtárat

- [ ] **Goal YAML útvonal illeszkedik a Tipsterino struktúrához**
  - Evidence: `repos/tipsterino/codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`
  - Ellenőrzés: `fill_canvas_<slug>` konvenció követve

- [ ] **Task prompt útvonal illeszkedik a Tipsterino struktúrához**
  - Evidence: `repos/tipsterino/codex/prompts/openclaw/migration_control_docs.task.md`
  - Ellenőrzés: `codex/prompts/openclaw/` struktúra létezik

- [ ] **Checklist útvonal illeszkedik a Tipsterino struktúrához**
  - Evidence: `repos/tipsterino/codex/codex_checklist/migration_repo_inventory_and_control_docs.md`
  - Ellenőrzés: `codex/codex_checklist/` struktúra létezik

- [ ] **Report útvonal illeszkedik a Tipsterino struktúrához**
  - Evidence: `repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.<timestamp>.report.md`
  - Ellenőrzés: `codex/reports/openclaw/` struktúra létezik

- [ ] **Párhuzamos workflow-rendszer nem nyílt**
  - Ellenőrzés: minden fájl a meglévő Tipsterino `canvases/` és `codex/` struktúrában van

---

## Section 4 — Created Files

- [ ] **Canvas létrehozva**
  - Evidence: `repos/tipsterino/canvases/migration_repo_inventory_and_control_docs.md`
  - Ellenőrzés: fájl létezik, cél+nem-cél+feladatok+kockázatok+rollback tartalommal

- [ ] **Goal YAML létrehozva**
  - Evidence: `repos/tipsterino/codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`
  - Ellenőrzés: fájl létezik, 10+ steps, minden step outputs-szal

- [ ] **OpenClaw task prompt létrehozva**
  - Evidence: `repos/tipsterino/codex/prompts/openclaw/migration_control_docs.task.md`
  - Ellenőrzés: fájl létezik, required reading + 5 phases + 3 checkpoint + verification gates

- [ ] **Checklist létrehozva**
  - Evidence: `repos/tipsterino/codex/codex_checklist/migration_repo_inventory_and_control_docs.md`
  - Ellenőrzés: fájl létezik, 4 section, evidence-fókuszú pipálható lista

- [ ] **Report fájl létrehozva/frissítve**
  - Evidence: `repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`
  - Ellenőrzés: fájl létezik, minden kötelező szekció kitöltve (Status, Summary, Inventory, Delta, Files, Checkpoints, Verification, Risks, Next Task, Appendix)

---

## Section 5 — Verification

- [ ] **Összes létrehozott fájl útvonal ellenőrizve**
  - Ellenőrzés: `ls` parancs minden útvonalra

- [ ] **Útvonalak a Tipsterino meglévő struktúrájához illeszkednek**
  - Ellenőrzés: nem nyílt új top-level könyvtár

- [ ] **verify.sh futtatása vagy dokumentált ok megadva**
  - Ellenőrzés: Tipsterino app scaffold üres → verify.sh nem fut le → dokumentált ok a report Verification szekciójában

- [ ] **Nincs .env, secret, vagy bináris asset módosítás**
  - Ellenőrzés: git status (szemrevételezés)

---

## DoD Summary

| # | Pont | Státusz |
|---|------|--------:|
| 1 | Required reading mindkét repóból (11 fájl) | ✅ |
| 2 | Checkpoint 1 rögzítve (szerepkörök + mappák) | ✅ |
| 3 | Checkpoint 2 rögzítve (6 dimenziós delta) | ✅ |
| 4 | Checkpoint 3 rögzítve (útvonal tervezés) | ✅ |
| 5 | Canvas létrehozva | ✅ |
| 6 | Goal YAML létrehozva | ✅ |
| 7 | OpenClaw task prompt létrehozva | ✅ |
| 8 | Checklist létrehozva | ✅ |
| 9 | Report fájl létrehozva, minden szekcióval | ✅ |
| 10 | Párhuzamos workflow-rendszer nem nyílt | ✅ |
