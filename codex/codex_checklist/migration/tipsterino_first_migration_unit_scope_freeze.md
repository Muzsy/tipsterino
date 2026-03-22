# Checklist: First Migration Unit Scope Freeze

**Task slug:** `first_migration_unit_scope_freeze`  
**Chosen unit:** `chat` (1:1 Direct Messaging)  
**Status:** COMPLETE

---

## Phase 1 — Baseline Reconstruction

- [x] Previous migration inventory report read: `migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`
- [x] Report conclusions documented: Tipsterino scaffold partial, TippmixApp full, no feature code migrated yet
- [x] Existing Tipsterino control docs identified: migration kickoff canvas + goal YAML + task prompt + checklist + report
- [x] Baseline summary written to report file

## Phase 2 — Candidate Shortlisting

- [x] TippmixApp features inspected: `chat/`, `friends/`, `filters/`, `feature_flags/`, `home/`
- [x] Tipsterino features inspected: `auth/` (complete), `events/` (partial), `rewards/` (partial), `bets/forum/home/profile/settings/guest_info/` (empty stubs)
- [x] Candidate #1 (chat) scored: 9/10 — bounded, Supabase-native, no Tipsterino equivalent
- [x] Candidate #2 (friends) scored: 7/10 — complete but more UI complexity
- [x] Candidate #3 (events filter completion) scored: 5/10 — different domain (sports events vs user activity)
- [x] Candidate #4 (bets completion) scored: 4/10 — too cross-cutting (API-Football, settlement)
- [x] Candidate #5 (home completion) scored: 3/10 — too many feature dependencies
- [x] Shortlist table written to report
- [x] Ranked order: chat > friends > events filter > bets > home
- [x] Justification for top choice (chat) written

## Phase 3 — Scope Freeze

- [x] `chat` chosen as first migration unit
- [x] Why chat won documented: bounded scope (5 files), Supabase-native, no Tipsterino equivalent, clean architecture
- [x] In-scope behavior defined: 1:1 messaging, realtime stream, send/receive, read_at
- [x] Explicitly out-of-scope defined: club chat, push notifications, message edit/delete, blocking, online status, search, attachments, Firebase code
- [x] Affected Tipsterino directories listed
- [x] Source-of-truth TippmixApp references listed (5 files + 1 DB migration)
- [x] Required docs to consult listed (9 docs)
- [x] Verify expectations defined (8 items)
- [x] Rollback boundary defined
- [x] Open questions documented (3 questions with decisions)

## Phase 4 — Control Pack Creation

### Canvas
- [x] `canvases/tipsterino_first_migration_unit_scope_freeze.md` created
- [x] Canvas conforms to existing Tipsterino canvas patterns
- [x] Canvas contains: frozen scope, in-scope, out-of-scope, required docs, checklist, risks

### Goal YAML
- [x] `codex/goals/canvases/fill_canvas_tipsterino_first_migration_unit_scope_freeze.yaml` created
- [x] YAML follows `fill_canvas_<slug>.yaml` naming convention
- [x] YAML uses `steps` schema with `name`, `description`, `outputs`
- [x] Last step is "Repo gate" with verify.sh
- [x] All 10 CP steps documented (CP1–CP10)
- [x] YAML references real Tipsterino paths

### Run Prompt
- [x] `codex/prompts/migration/first_migration_unit_scope_freeze/run.md` created
- [x] Run prompt placed in `migration/` subdirectory
- [x] Run prompt contains: mission, hard rules, required reading, 4 phases, checkpoints, verification gates

### Checklist
- [x] `codex/codex_checklist/migration/tipsterino_first_migration_unit_scope_freeze.md` created
- [x] Checklist is evidence-based and implementation-facing
- [x] All checkpoints documented with checkboxes

### Stable Report Stub
- [x] `codex/reports/migration/tipsterino_first_migration_unit_scope_freeze.md` created
- [x] Report follows `docs/codex/report_standard.md` structure
- [x] Report contains: all 4 checkpoint results, verification summary, next recommended task

## Verification

- [x] All 5 control pack files created at stated paths
- [x] All paths verified to conform to Tipsterino structure
- [x] No second workflow system created (all files follow existing Codex conventions)
- [x] Chosen unit (chat) is explicitly narrower than full product-area migration
- [x] No repo verification script run (documentation-only task — no code implementation)

---

## Evidence Summary

| Created File | Evidence |
|-------------|----------|
| `canvases/tipsterino_first_migration_unit_scope_freeze.md` | Feature-first canvas structure |
| `codex/goals/canvases/fill_canvas_tipsterino_first_migration_unit_scope_freeze.yaml` | 10-step YAML with real paths |
| `codex/prompts/migration/first_migration_unit_scope_freeze/run.md` | Full execution prompt |
| `codex/codex_checklist/migration/tipsterino_first_migration_unit_scope_freeze.md` | 4-phase checklist |
| `codex/reports/migration/tipsterino_first_migration_unit_scope_freeze.md` | Report with all 4 CP results |
| `codex/reports/migration/first_migration_unit_scope_freeze.2026-03-21_235144.md` | Timestamped report |
