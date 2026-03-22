# OpenClaw Run Prompt: First Migration Unit Scope Freeze

**Task slug:** `first_migration_unit_scope_freeze`  
**Runtime:** agent=tipmig | tipsterino workspace  
**Start:** 2026-03-21 23:51 UTC

---

## Mission

Select the first concrete migration unit from `tippmixapp` into `tipsterino`, freeze its scope, and create a full Tipsterino-side control pack (canvas + goal YAML + run prompt + checklist + report stub) for that unit.

This is a **documentation/control task first, not an implementation task**.

---

## Hard Rules

1. **Do not invent repo state.** Use only actual files and current repository structure as evidence.
2. **`tipsterino/app/`** is the only application implementation target.
3. **`tippmixapp`** is reference/source only.
4. Do not migrate code in this task — only create documentation/control artifacts.
5. Do not touch secrets, env values, binary assets, or gitignored runtime files.
6. Prefer a narrow, executable first migration unit over an ambitious but fuzzy one.

---

## Repositories

- **Target/control:** `./repos/tipsterino`
- **Source/reference:** `./repos/tippmixapp`

---

## Required Reading Before Starting

### Previous task output (MUST READ)
- `./repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`

### Tipsterino core docs
- `./repos/tipsterino/AGENTS.md`
- `./repos/tipsterino/README.md`
- `./repos/tipsterino/app/README.md`
- `./repos/tipsterino/docs/README.md`
- `./repos/tipsterino/docs/codex/overview.md`
- `./repos/tipsterino/docs/codex/yaml_schema.md`
- `./repos/tipsterino/docs/codex/report_standard.md`
- `./repos/tipsterino/docs/architect/project_structure.md`
- `./repos/tipsterino/docs/architect/service_dependencies.md`
- `./repos/tipsterino/docs/localization/localization_logic.md`

### TippmixApp core docs
- `./repos/tippmixapp/AGENTS.md`
- `./repos/tippmixapp/README.md`
- `./repos/tippmixapp/DEV.md`
- `./repos/tippmixapp/codex_docs/codex_readme_en.md`
- `./repos/tippmixapp/codex_docs/service_dependencies_en.md`

---

## Execution Phases

### Phase 1 — Reconstruct current migration baseline
1. Read the latest previous migration inventory report (`migration_repo_inventory_and_control_docs.*.report.md`)
2. Confirm what control docs already exist in Tipsterino
3. Confirm whether an initial migration pack was already created in the previous task
4. Write baseline summary into the report

### Phase 2 — Shortlist candidate migration units
1. Identify 3–5 realistic candidate units from TippmixApp
2. For each candidate, record: unit name, source evidence, target area, dependencies, risks, why it is/is not a good first unit
3. Score against: architectural fit, dependency isolation, documentation clarity, implementation risk, verify-ability, migration value
4. Write shortlist table into report with ranked order

### Phase 3 — Freeze the first migration unit
1. Choose exactly ONE first migration unit
2. Define: in-scope behavior, explicitly out-of-scope behavior, affected directories, source-of-truth references, required docs, verify expectations, rollback boundary, open questions
3. Write frozen scope section into report

### Phase 4 — Create the Tipsterino control pack for the chosen unit

Create ALL of the following files:

**1. Canvas:**
`./repos/tipsterino/canvases/tipsterino_first_migration_unit_scope_freeze.md`

Content: chosen unit description, frozen scope, in-scope vs out-of-scope, required docs, verification gates, risks.

**2. Goal YAML:**
`./repos/tipsterino/codex/goals/canvases/fill_canvas_tipsterino_first_migration_unit_scope_freeze.yaml`

Schema: `steps` list with `name`, `description`, `outputs`. Last step must be "Repo gate" with `./scripts/verify.sh`. Follow Tipsterino `fill_canvas_<slug>.yaml` convention exactly.

**3. Run Prompt Directory and Run Prompt:**
`./repos/tipsterino/codex/prompts/migration/first_migration_unit_scope_freeze/run.md`

Content: long-form execution prompt with phases, checkpoints, verification gates, hard rules.

**4. Checklist:**
`./repos/tipsterino/codex/codex_checklist/migration/tipsterino_first_migration_unit_scope_freeze.md`

Content: evidence-based, implementation-facing checklist with checkboxes.

**5. Stable Report Stub:**
`./repos/tipsterino/codex/reports/migration/tipsterino_first_migration_unit_scope_freeze.md`

Content: follow `docs/codex/report_standard.md` structure. Status: IN_PROGRESS for now; will be finalized by the next task.

---

## Checkpoints

- **Checkpoint 1:** Report contains previous report file, its main conclusions, and what already exists in Tipsterino. If previous report is missing → STOP with FAIL.
- **Checkpoint 2:** Report contains shortlist table, ranked order, justification for top choice. If no candidate is suitable → STOP with PASS_WITH_NOTES.
- **Checkpoint 3:** Report contains chosen unit, why it won, frozen scope section, explicit out-of-scope section.
- **Checkpoint 4:** Report contains exact created paths, whether they conform to existing patterns, any naming/placement compromises.

---

## Verification Gates

Before concluding:
1. List all created or modified files
2. Verify each created file exists at stated path
3. Verify YAML references real files
4. Verify control pack does not create unnecessary second workflow system
5. Verify chosen unit is explicitly narrower than a full product-area migration

---

## Output Requirements

Create the timestamped report at:
`./repos/tipsterino/codex/reports/migration/first_migration_unit_scope_freeze.<YYYY-MM-DD_HHMMSS>.md`

Rules:
- Write the final structured report to that file
- Update the same report after each checkpoint
- Keep terminal output concise
- At the end, print only:
  - task status
  - final report path
  - next recommended task slug

If the report file cannot be created or updated → task status = FAIL.

---

## Final Answer Contract

At the end, print ONLY:
```
STATUS: <PASS | FAIL | PASS_WITH_NOTES>
REPORT: <relative path>
NEXT_TASK: <slug>
```
