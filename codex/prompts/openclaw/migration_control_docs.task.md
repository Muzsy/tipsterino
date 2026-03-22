# OpenClaw Task

## Task slug
`migration_control_docs`

## Mission
Készítsd el a Tipsterino migrációs kontrollrétegének első dokumentumait: canvas, goal YAML, OpenClaw task prompt, checklist és report. A munka a `tipsterino` (target) és `tippmixapp` (source) repók repo-alapú felmérésére épül.

## Repositories in scope
- Target/control repo: `./repos/tipsterino`
- Source/reference repo: `./repos/tippmixapp`

## Hard rules
- Ne találj ki nem létező fájlokat vagy modulokat.
- A `tipsterino/app/` az egyetlen fejlesztési célpont.
- A `tippmixapp` referencia/source repo, nem célrepo.
- Ne módosíts bináris assetet.
- Ne módosíts environment secretet vagy gitignored runtime fájlt.
- Először olvass, utána tervezz, utána módosíts.
- Csak olyan fájlt hozhatsz létre vagy módosíthatsz, ami szerepel a feladat YAML step `outputs` listájában.

## File output requirements
A task elején hozz létre egy timestampes report fájlt ezen a mintán:
`./repos/tipsterino/codex/reports/openclaw/migration_control_docs.<YYYY-MM-DD_HHMMSS>.report.md`

Kötelező szabályok:
- A végső reportot ebbe a fájlba írd.
- Minden checkpoint után frissítsd ugyanezt a report fájlt.
- A terminálra csak rövid státuszokat írj, ne csak ott legyen meg a lényeg.
- A futás végén add meg a kész report pontos relatív útvonalát.
- Ha a report fájl nem hozható létre vagy nem frissíthető, a task állapota FAIL legyen.

## Required reading

### Tipsterino
- `./repos/tipsterino/AGENTS.md` — repo szabályok, app/ mint egyetlen célpont, Codex workflow, wrapper scripttek
- `./repos/tipsterino/docs/codex/overview.md` — canvas+yaml+kontroll artefakt kötelező körforgás, DoD, verification gates
- `./repos/tipsterino/docs/codex/yaml_schema.md` — elfogadott goal YAML séma, outputs szabály, 2.1-2.4 globális szabályok
- `./repos/tipsterino/docs/codex/report_standard.md` — Report Standard v2: kötelező státusz, DoD→Evidence Matrix, Advisory notes
- `./repos/tipsterino/docs/architect/project_structure.md` — feature-first mappaszerkezet, lib/src/features/ kötelező szabály
- `./repos/tipsterino/docs/architect/service_dependencies.md` — Supabase-only stack, UI→service→repo→client rétegek
- `./repos/tipsterino/docs/localization/localization_logic.md` — ARB HU+EN, feature-first kulcsnév konvenció

### TippmixApp
- `./repos/tippmixapp/AGENTS.md` — Codex policy, Firebase+Supabase hybrid stack, sandbox env szabály
- `./repos/tippmixapp/DEV.md` — Flutter + pnpm + Supabase CLI + Deno stack, CI pipeline, Codex workflow
- `./repos/tippmixapp/codex_docs/codex_readme_en.md` — Codex integráció, canvas+yaml kötelező fájlok, DoD
- `./repos/tippmixapp/codex_docs/service_dependencies_en.md` — DataSource→Repository→Service→UI rétegek, DI Riverpod

## Execution phases

### Phase 1 — Repo inventory
Azonosítsd mindkét repo fő struktúráját, és különítsd el:
- fejlesztési célpontok
- dokumentációs források
- workflow artefaktok
- Supabase/backend elemek
- tesztelési és verify belépési pontok

### Checkpoint 1
Mielőtt bármit létrehoznál, írd le röviden:
- mi a Tipsterino szerepe (target, Supabase-only, clean scaffold, canvas+yaml workflow)
- mi a TippmixApp szerepe (source, Firebase+Supabase hybrid, teljes implementáció)
- mely mappák a legfontosabbak a migráció vezérléséhez (tipsterino: codex/, canvases/, docs/; tippmixapp: lib/, docs/, supabase/, canvases/)
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába, ne csak ideiglenesen a terminálra.
Ha ez nem áll össze egyértelműen, állj meg és ezt jelezd a reportban.

### Phase 2 — Difference mapping
Készíts különbséglistát legalább ezek mentén (konkrét fájlokra és mappákra hivatkozva):
- repo struktúra (tipsterino app/ vs tippmixapp lib/ — app/üres scaffold vs lib/teljes app)
- dokumentációs réteg (tipsterino docs/ canonical fa vs tippmixapp docs/ + root artifact halmaz)
- Codex workflow réteg (hasonló struktúra, de külön repók, tipsterino: 9+ canvas, tippmixapp: 40+ canvas)
- Supabase és backend szervezés (tipsterino: Supabase-only, tippmixapp: Firebase Cloud Functions + Firestore + Supabase)
- Flutter app elhelyezése (tipsterino: app/ alkönyvtárban, tippmixapp: root lib/)
- tesztelési / CI belépési pontok (tipsterino: wrapper scripttek, tippmixapp: pnpm monorepo + firebase scripts + GitHub Actions)

### Checkpoint 2
Ellenőrizd, hogy a különbséglista konkrét fájlokra és mappákra hivatkozik-e. Ha túl általános, finomítsd.
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába.

### Phase 3 — Control-doc design in Tipsterino
Tervezd meg, hogy a Tipsterino repóban milyen első migrációs kontrollfájlok kellenek.

Kötelezően javasolj legalább ezeket:
- 1 canvas: `canvases/migration_repo_inventory_and_control_docs.md`
- 1 goal YAML: `codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`
- 1 OpenClaw task prompt: `codex/prompts/openclaw/migration_control_docs.task.md`
- 1 checklist: `codex/codex_checklist/migration_repo_inventory_and_control_docs.md`
- 1 report fájl: `codex/reports/openclaw/migration_control_docs.<YYYY-MM-DD_HHMMSS>.report.md`

A javasolt fájloknak valós, repo-kompatibilis útvonalat adj.

### Checkpoint 3
Még a fájllétrehozás előtt ellenőrizd:
- a választott útvonalak illeszkednek-e a Tipsterino meglévő struktúrájához (canvases/, codex/goals/canvases/, codex/prompts/openclaw/, codex/codex_checklist/, codex/reports/openclaw/)
- nem nyitsz-e párhuzamos, fölösleges második workflow-rendszert
- a canvas, YAML, prompt, checklist, report útvonalak konzisztensek-e egymással
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába.

### Phase 4 — Create initial control docs
Hozd létre a Tipsterino repóban az első kontrollcsomagot:

1. **Canvas** (`canvases/migration_repo_inventory_and_control_docs.md`):
   - Cél + nem-cél (explicit)
   - Érintett modulok (tipsterino + tippmixapp útvonalakkal)
   - 5 phases feladatlistája pipálható checkboxes-szal
   - Kockázatok + rollback terv

2. **Goal YAML** (`codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`):
   - 6+ steps: required reading (tipsterino) → required reading (tippmixapp) → checkpoint 1 → checkpoint 2 → checkpoint 3 → create canvas → create yaml → create task prompt → create checklist → create/finalize report → repo gate
   - Minden step: name, description (multiline >), outputs (string lista)
   - Utolsó step: "Repo gate (automatikus verify)" with ./scripts/verify.sh command

3. **OpenClaw Task Prompt** (`codex/prompts/openclaw/migration_control_docs.task.md`):
   - Hosszú, többfázisú, checkpointos feladat
   - Required reading lista (7 tipsterino + 4 tippmixapp fájl)
   - 5 phases leírása
   - 3 checkpoint kötelező rögzítési pont
   - File output rules: timestampes report, checkpoint frissítések, terminál output szabályok
   - Verification gates
   - Stop conditions (FAIL/PASS_WITH_NOTES kritériumok)

4. **Checklist** (`codex/codex_checklist/migration_repo_inventory_and_control_docs.md`):
   - Evidence-fókuszú pipálható lista
   - Sections: repo inventory, difference mapping, control-doc design, created files, verification
   - Minden ponthoz: checkbox + fájl útvonal + ellenőrzési mód

5. **Report stub** (új vagy frissítés):
   - Minden kötelező szekció: Status, Summary, Repo Inventory Findings, Difference Mapping, Created/Modified Files, Checkpoint Results, Verification, Risks/Open Items, Recommended Next Task, Appendix

## Verification gates
Mielőtt befejezed a munkát:

1. Sorold fel az összes létrehozott vagy módosított fájlt.
2. Ellenőrizd, hogy minden útvonal tényleg létezik.
3. Ellenőrizd, hogy a létrehozott fájlok neve és szerepe összhangban van a Tipsterino `codex/` és `canvases/` struktúrájával.
4. Ha van repo verify script, írd le, mit futtattál vagy miért nem futtattad.

## Stop conditions
Állj meg és FAIL/PASS_WITH_NOTES állapotot adj, ha:
- a Tipsterino repo struktúrája nem egyezik a feltételezett workflow-val
- a szükséges canonical docs hiányoznak
- a javasolt kontrollréteg nem illeszthető tisztán a meglévő struktúrához
- a report fájl nem hozható létre vagy nem frissíthető

## Expected outputs
A futás végére legyen:
- repo szerepkép a két repóról (tipsterino=target, tippmixapp=source)
- különbséglista (6 dimenzió, konkrét útvonalakkal)
- konkrét kontroll-dokumentum javaslat (5 fájltípus, útvonalakkal)
- létrehozott kezdő kontrollcsomag a Tipsterino repóban (5 fájl)
- kitöltött report fájl a `./repos/tipsterino/codex/reports/openclaw/` alatt
- a végső válaszban a report relatív elérési útja

## Final report handling
A végső reportot markdown fájlba kell írni.

Kötelező szekciók:
1. Status
2. Summary
3. Repo inventory findings
4. Difference mapping
5. Created or modified files
6. Checkpoint results
7. Verification
8. Risks / Open items
9. Recommended next task
10. Appendix

A terminálos végső válasz legyen rövid, és tartalmazza:
- a task státuszát
- a report fájl relatív útvonalát
- a következő javasolt task rövid nevét
