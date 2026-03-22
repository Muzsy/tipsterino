# OpenClaw task/report rendszer – Tipsterino-alapú javaslat

## Miért ez a struktúra

A feltöltött `tipsterino-main` repo már eleve rendelkezik a következő, kanonikus munkafolyamat-mappákkal:

- `canvases/`
- `codex/goals/`
- `codex/prompts/`
- `codex/codex_checklist/`
- `codex/reports/`
- `docs/codex/`

Ezért az OpenClaw-feladatokat nem külön, új root alá érdemes tenni, hanem a meglévő `codex/` fa alá.

## Ajánlott helyek

- hosszú OpenClaw task promptok:
  - `tipsterino/codex/prompts/openclaw/<TASK_SLUG>.task.md`
- OpenClaw futási reportok:
  - `tipsterino/codex/reports/openclaw/<TASK_SLUG>.report.md`
- verify / kézi checklist:
  - `tipsterino/codex/codex_checklist/openclaw/<TASK_SLUG>.md`

## Miért nem külön `tasks/` root?

Lehetne, de a Tipsterino AGENTS és a repo tényleges struktúrája azt sugallja, hogy a munka-artefaktokat a `codex/` fa alatt tartsuk. Így:

- együtt marad a prompt, report és checklist,
- könnyebb később canvas + YAML + report lánccá emelni,
- nem kell párhuzamos, második workflow-rendszert fenntartani.

## Javasolt task-szintek

### 1. Discovery / audit taskok
Cél: csak feltérképezés, semmi implementáció.

### 2. Control-doc taskok
Cél: Tipsterino oldalon migrációs canvas / prompt / report vázak létrehozása.

### 3. Controlled implementation taskok
Cél: már konkrét fájlmódosítás, de csak előre definiált outputokra.

## Hosszabb OpenClaw task kötelező blokkjai

Minden taskban legyen:

1. Mission
2. Scope
3. Repositories in scope
4. Required reading
5. Execution phases
6. Checkpoints
7. Verification gates
8. Stop conditions
9. Expected outputs
10. Final report format

## Konkrét repo-alapú megfigyelés

A feltöltött repók alapján:

### Tipsterino (target/control repo)
- tisztább monorepo jelleg
- `app/` az egyetlen fejlesztési célpont
- `docs/` a canonical source of truth
- `canvases/` + `codex/` már készen áll a kontrollált workflowhoz
- `supabase/` és `scripts/verify.sh` jellegű struktúra már a kontrollált munkára utal

### TippmixApp (source/reference repo)
- nagy, történetileg rétegzett repo
- sok `canvases/`, `docs/`, `codex/`, `codex_docs/`, `reports/`, `artifacts/`
- sok legacy és fejlesztéstörténeti anyag van benne
- kiváló referencia, de rossz célrepo közvetlen továbbépítésre

## Első ajánlott OpenClaw feladatsor

Nem kódmigrációval kell kezdeni, hanem ezzel a sorrenddel:

1. Tipsterino és TippmixApp repo-inventory
2. migrációs kontroll-dokumentumok listája Tipsterino oldalon
3. első konkrét canvas/prompt/report/checklist csomag előkészítése
4. csak ezután első tényleges implementációs migrációs egység
