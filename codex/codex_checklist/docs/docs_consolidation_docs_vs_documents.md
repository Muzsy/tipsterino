# Docs consolidation (docs vs documents) checklist

## P0 – Canvas + cél
- [x] Létrejött / frissült a canvas: `canvases/docs/docs_consolidation_docs_vs_documents.md`.

## P1 – Migráció + stubok
- [x] Létrejött a `documents/README_DEPRECATED.md` deprecációs belépő.
- [x] A 3 kritikus doksi átkerült a `docs/` alá:
  - `docs/architect/app_architecture.md`
  - `docs/setup/supabase_configuration.md`
  - `docs/core_logic/daily_bonus.md`
- [x] A régi `documents/*` helyeken csak stub maradt:
  - `documents/app_architecture.md`
  - `documents/supabase_configuration.md`
  - `documents/bonus_system/daily_bonus.md`

## P2 – Hivatkozások + source of truth
- [x] A kötelező hivatkozások átvezetve: `README.md`, `AGENTS.md`, `docs/README.md`, `docs/architect/project_structure.md`, `docs/core_logic/bonus_system.md`.
- [x] `AGENTS.md` forrás-igazság sorrendben a `docs/` megelőzi a `documents/`-t.

## P3 – Repo gate + report
- [x] Elkészült: `codex/reports/docs/docs_consolidation_docs_vs_documents.md`.
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/docs/docs_consolidation_docs_vs_documents.md`.
- [x] Létrejött verify log: `codex/reports/docs/docs_consolidation_docs_vs_documents.verify.log`.
