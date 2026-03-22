# OpenClaw Task

## Task slug
`migration_repo_inventory_and_control_docs`

## Mission
Készíts repo-alapú, bizonyítékvezérelt migrációs helyzetfelmérést a `tipsterino` és `tippmixapp` repókról, majd készítsd elő a Tipsterino oldali migrációs kontrollréteg első dokumentumait.

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

## File output requirements
A task elején hozz létre egy timestampes report fájlt ezen a mintán:

`./repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.<YYYY-MM-DD_HHMMSS>.report.md`

Kötelező szabályok:
- A végső reportot ebbe a fájlba írd.
- Minden checkpoint után frissítsd ugyanezt a report fájlt.
- A terminálra csak rövid státuszokat írj, ne csak ott legyen meg a lényeg.
- A futás végén add meg a kész report pontos relatív útvonalát.
- Ha a report fájl nem hozható létre vagy nem frissíthető, a task állapota FAIL legyen.

## Required reading
A munka elején olvasd el és értelmezd legalább ezeket:

### Tipsterino
- `./repos/tipsterino/AGENTS.md`
- `./repos/tipsterino/README.md`
- `./repos/tipsterino/docs/codex/overview.md`
- `./repos/tipsterino/docs/codex/yaml_schema.md`
- `./repos/tipsterino/docs/codex/report_standard.md`
- `./repos/tipsterino/docs/architect/project_structure.md`
- `./repos/tipsterino/docs/architect/service_dependencies.md`
- `./repos/tipsterino/docs/localization/localization_logic.md`

### TippmixApp
- `./repos/tippmixapp/AGENTS.md`
- `./repos/tippmixapp/README.md`
- `./repos/tippmixapp/DEV.md`
- `./repos/tippmixapp/codex_docs/codex_readme_en.md`
- `./repos/tippmixapp/codex_docs/service_dependencies_en.md`

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
- mi a Tipsterino szerepe,
- mi a TippmixApp szerepe,
- mely mappák a legfontosabbak a migráció vezérléséhez.
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába, ne csak ideiglenesen a terminálra.

Ha ez nem áll össze egyértelműen, állj meg és ezt jelezd a reportban.

### Phase 2 — Difference mapping
Készíts különbséglistát legalább ezek mentén:
- repo szerkezet
- dokumentációs réteg
- Codex workflow réteg
- Supabase és backend szervezés
- Flutter app elhelyezése
- tesztelési / CI belépési pontok

### Checkpoint 2
Ellenőrizd, hogy a különbséglista konkrét fájlokra és mappákra hivatkozik-e. Ha túl általános, finomítsd.
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába, ne csak ideiglenesen a terminálra.

### Phase 3 — Control-doc design in Tipsterino
Tervezd meg, hogy a Tipsterino repóban milyen első migrációs kontrollfájlok kellenek.

Kötelezően javasolj legalább ezeket:
- 1 canvas
- 1 goal YAML
- 1 OpenClaw task prompt
- 1 checklist
- 1 report fájl

A javasolt fájloknak valós, repo-kompatibilis útvonalat adj.

### Checkpoint 3
Még a fájllétrehozás előtt ellenőrizd:
- a választott útvonalak illeszkednek-e a Tipsterino meglévő struktúrájához,
- nem nyitsz-e párhuzamos, fölösleges második workflow-rendszert.
A checkpoint eredményét azonnal írd be a report fájl megfelelő szekciójába, ne csak ideiglenesen a terminálra.

### Phase 4 — Create initial control docs
Hozd létre a Tipsterino repóban az első kontrollcsomagot az alábbi logika szerint:

1. Canvas: migrációs inventory/control kickoff
2. YAML: a canvas kitöltéséhez illeszkedő, valós outputs listával
3. OpenClaw prompt: hosszabb, többfázisú, checkpointos feladat
4. Checklist: verify + evidence fókuszú
5. Report stub: a standard szerinti szekciókkal

## Verification gates
Mielőtt befejezed a munkát:

1. Sorold fel az összes létrehozott vagy módosított fájlt.
2. Ellenőrizd, hogy minden útvonal tényleg létezik.
3. Ellenőrizd, hogy a létrehozott fájlok neve és szerepe összhangban van a Tipsterino `codex/` és `canvases/` struktúrájával.
4. Ha van repo verify script, írd le, mit futtattál vagy miért nem futtattad.

## Stop conditions
Állj meg és FAIL/PASS_WITH_NOTES állapotot adj, ha:
- a Tipsterino repo struktúrája nem egyezik a feltételezett workflow-val,
- a szükséges canonical docs hiányoznak,
- a javasolt kontrollréteg nem illeszthető tisztán a meglévő struktúrához.

## Expected outputs
A futás végére legyen:

- repo szerepkép a két repóról,
- különbséglista,
- konkrét kontroll-dokumentum javaslat,
- létrehozott kezdő kontrollcsomag a Tipsterino repóban,
- kitöltött report fájl a `./repos/tipsterino/codex/reports/openclaw/` alatt,
- a végső válaszban a report relatív elérési útja.

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

A terminálos végső válasz legyen rövid, és tartalmazza:
- a task státuszát,
- a report fájl relatív útvonalát,
- a következő javasolt task rövid nevét.
