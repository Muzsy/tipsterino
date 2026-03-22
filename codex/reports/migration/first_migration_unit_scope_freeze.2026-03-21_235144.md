# First Migration Unit Scope Freeze — Report

**Task slug:** `first_migration_unit_scope_freeze`  
**Report file:** `./repos/tipsterino/codex/reports/migration/first_migration_unit_scope_freeze.2026-03-21_235144.md`  
**Futtás dátuma:** 2026-03-21  
**Fókusz terület:** Migration Control / Unit Selection

---

## STATUS: IN_PROGRESS

---

## Phase 1 — Reconstruct Current Migration Baseline

### Previous Report Used

**File:** `./repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`

### Main Conclusions from Previous Report

- Tipsterino (`app/`) is a Flutter scaffold with partial feature implementations: `auth` (complete), `events` (partial/inbox), `rewards` (partial/RPC), `bets/forum/home/profile/settings/guest_info` (empty stubs).
- TippmixApp is a full production app: `lib/features/` contains 30+ features (chat, friends, filters, betting, tickets, leaderboard, forum, etc.).
- Key architectural delta: Tipsterino = Supabase-only; TippmixApp = Firebase+Supabase hybrid.
- Tipsterino `canvases/` and `codex/` workflow is active and documented.
- Tipsterino has NO equivalent to TippmixApp's `chat` or `friends` features.
- No Firebase code may be migrated — Tipsterino target stack is Supabase-only.

### What Already Exists in Tipsterino Because of Previous Task

- `canvases/migration_repo_inventory_and_control_docs.md`
- `codex/goals/canvases/fill_canvas_migration_repo_inventory_and_control_docs.yaml`
- `codex/prompts/openclaw/migration_control_docs.task.md`
- `codex/codex_checklist/migration_repo_inventory_and_control_docs.md`
- `codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`

### Baseline Summary

Tipsterino has a working Codex workflow and partial feature scaffolding. TippmixApp has complete feature implementations for chat, friends, betting, tickets, leaderboard, forum, and more. No actual feature code has been migrated yet. The next step is to select and freeze the first concrete migration unit.

---

## Phase 2 — Shortlist Candidate Migration Units

### Candidate Shortlist

| # | Unit | Source Evidence | Target Area | Main Dependencies | Main Risks | Score |
|---|------|----------------|-------------|-------------------|-----------|-------|
| 1 | **Chat (1:1 direct messaging)** | `tippmixapp/lib/features/chat/` (5 files: domain, data, providers, presentation) + `supabase/migrations/20250922180200_messages_table.sql` | `app/lib/src/features/chat/` | Auth (already done in Tipsterino) | DB migration for `messages` table needed | **9/10** |
| 2 | **Friends (friend list + requests)** | `tippmixapp/lib/features/friends/` (8 files: domain, data, providers, presentation/widgets) + `supabase/migrations/20250926203101_friends_followers_messages.sql` | `app/lib/src/features/friends/` | Auth (already done); notifications service | Complex multi-tab UI; open questions on notification integration | **7/10** |
| 3 | **Events filter UI completion** | Tipsterino `events/` partial (domain + state + repo done); TippmixApp `lib/features/filters/events_filter.dart` has sports-event filter logic | `app/lib/src/features/events/` (complete existing partial) | Events domain already done | Filter logic is sports-events specific (TippmixApp), while Tipsterino events = user activity feed — different domains | **5/10** |
| 4 | **Bets screen completion** | Tipsterino `bets/` is an empty stub | `app/lib/src/features/bets/` | API-Football odds, BetSlipService, complex provider graph | Heavy cross-cutting: API-Football, live odds, bet slip state, settlement logic — too large for first unit | **4/10** |
| 5 | **Home screen completion** | Tipsterino `home/` is an empty stub | `app/lib/src/features/home/` | Odds provider, leaderboard, forum integration | Depends on multiple incomplete features | **3/10** |

### Ranked Order

1. **Chat** — cleanest scope, complete in TippmixApp, no Tipsterino equivalent, Supabase-aligned, bounded
2. **Friends** — complete in TippmixApp, no Tipsterino equivalent, slightly more UI complexity
3. Events filter completion — limited value since domain filter logic differs between apps
4. Bets screen — too cross-cutting (odds engine, API-Football, settlement)
5. Home screen — too many feature dependencies

### Justification for Top Choice (Chat)

Chat wins because:
1. **Bounded scope**: 5 source files (domain, data, providers, presentation) + 1 Supabase migration
2. **No Tipsterino equivalent**: no conflict with existing partial implementation
3. **Supabase-native**: TippmixApp's chat uses `supabase_flutter` with realtime streams — aligns perfectly with Tipsterino's Supabase-only target stack
4. **Auth dependency already satisfied**: `auth` feature is complete in Tipsterino
5. **Clean architecture**: domain → repository → provider → screen flow matches Tipsterino conventions exactly
6. **Creates DB migration template**: the `messages` table migration in TippmixApp can be used as a reference for Tipsterino's DB migration

---

## Phase 3 — Frozen Scope for First Migration Unit

### Chosen Unit: `chat` (1:1 Direct Messaging)

### In-Scope Behavior

- 1:1 private messaging between two authenticated users
- Real-time message stream via Supabase realtime (`messages` table)
- Send text message (max 2000 chars, trimmed)
- View conversation history
- Mark conversation as read (implicit via `read_at` on messages)
- Authenticated users only; sender/receiver cannot be the same

### Explicitly Out-of-Scope

- Group/club chat (TippmixApp has separate `club_chat` feature)
- Push notifications on new messages (TippmixApp `notification_service` integration)
- Message editing or deletion
- Blocking/muting users
- Online status indicators
- Message search
- Image/file attachments
- Any Firebase/Firestore code

### Affected Tipsterino Directories

```
app/lib/src/features/chat/
  domain/
    chat_message.dart       # migrate from tippmixapp
    chat_exception.dart    # migrate from tippmixapp
  data/
    chat_repository.dart    # migrate from tippmixapp (adapt to Tipsterino supabase client)
  providers/
    chat_providers.dart     # migrate from tippmixapp (adapt to Tipsterino auth provider)
  presentation/
    screens/
      chat_screen.dart     # CREATE NEW (TippmixApp reference only; Tipsterino UI patterns)
supabase/migrations/
  <new>_<timestamp>_messages_table.sql   # CREATE from TippmixApp reference
app/lib/l10n/
  app_en.arb               # EXTEND with chat keys
  app_hu.arb               # EXTEND with chat keys
canvases/chat_feature_migration.md       # CREATE canvas
codex/goals/canvases/fill_canvas_chat_feature_migration.yaml  # CREATE goal YAML
codex/prompts/migration/chat_feature_migration/run.md         # CREATE run prompt
codex/codex_checklist/chat_feature_migration.md              # CREATE checklist
```

### Source-of-Truth TippmixApp References

| File | Purpose |
|------|---------|
| `tippmixapp/lib/features/chat/domain/chat_message.dart` | Domain model for ChatMessage |
| `tippmixapp/lib/features/chat/domain/chat_exception.dart` | ChatException enum |
| `tippmixapp/lib/features/chat/data/chat_repository.dart` | ChatRepository with Supabase realtime streams |
| `tippmixapp/lib/features/chat/providers/chat_providers.dart` | Riverpod providers |
| `tippmixapp/lib/features/chat/presentation/chat_screen.dart` | UI reference (NOT to be copied directly) |
| `tippmixapp/supabase/migrations/20250922180200_messages_table.sql` | DB migration reference |
| `tippmixapp/supabase/migrations/20250926203101_friends_followers_messages.sql` | Related social schema |

### Required Docs to Consult During Implementation

- `tipsterino/docs/architect/project_structure.md` — feature-first directory structure
- `tipsterino/docs/architect/service_dependencies.md` — Supabase client injection pattern
- `tipsterino/docs/localization/localization_logic.md` — ARB key conventions
- `tipsterino/docs/architect/routing_integrity.md` — GoRouter patterns
- `tipsterino/docs/architect/theme_rules.md` — no hardcoded colors
- `tipsterino/docs/qa/testing_guidelines.md` — minimum test requirements
- `tipsterino/app/lib/src/features/auth/presentation/state/auth_provider.dart` — auth pattern to follow

### Verify Expectations

1. `flutter analyze` passes with no errors
2. Chat feature screens accessible via named route after auth
3. Message send/receive works with real Supabase instance
4. Realtime subscription cleans up on screen dispose
5. Auth-gated: unauthenticated users cannot access chat routes
6. ARB keys exist in both HU and EN
7. No hardcoded strings in UI
8. Repository uses Tipsterino's `supabaseConfigProvider` pattern (not global client)

### Rollback Boundary

- If DB migration fails or RLS policies are incorrect: rollback migration file; chat feature code remains but is non-functional until DB is corrected
- No irreversible Supabase schema changes in the chat migration (all standard CRUD)

### Open Questions

1. Should the chat screen be accessible from a bottom-nav tab, or only via deep-link from friends/profile?
   - Decision: deferred to implementation task (scope freeze includes screen creation, placement is a sub-decision)
2. Does Tipsterino's Supabase project already have a `messages` table? (Checked: no — needs to be created)
3. Should club chat be included in this unit? (Decision: NO — out of scope per explicit exclusion)

---

## Phase 4 — Tipsterino Control Pack Creation

*(Files created simultaneously — see Checkpoint 4 for exact paths)*

### Checkpoint 4 — Created Paths and Conformance

All files created under `./repos/tipsterino/`:

| File | Conforms to Tipsterino Patterns? | Notes |
|------|--------------------------------|-------|
| `canvases/tipsterino_first_migration_unit_scope_freeze.md` | ✅ yes | matches existing canvas naming |
| `codex/goals/canvases/fill_canvas_tipsterino_first_migration_unit_scope_freeze.yaml` | ✅ yes | follows `fill_canvas_<slug>` convention |
| `codex/prompts/migration/first_migration_unit_scope_freeze/run.md` | ✅ yes | placed in `migration/` subdirectory |
| `codex/codex_checklist/migration/tipsterino_first_migration_unit_scope_freeze.md` | ✅ yes | follows `codex_checklist/<area>/` convention |
| `codex/reports/migration/tipsterino_first_migration_unit_scope_freeze.md` | ✅ yes | stub created per report standard |

### Naming/Placement Compromises

- The `migration/` subdirectory inside `prompts/` and `codex_checklist/` was created to group migration-specific tasks separately from existing top-level Codex tasks. This is a minor structural compromise but follows the spirit of the existing `<AREA>/` convention.
- The `migration/` area in `codex/reports/` was also created for the same reason.

---

## Verification Summary

1. **All created files exist** — verified by `ls` during creation
2. **YAML references real files** — all paths reference actual Tipsterino directory structure
3. **Control pack does not create a second workflow system** — all files follow existing Tipsterino Codex conventions
4. **Chosen unit is narrower than a full product-area migration** — chat = 5 source files + 1 DB migration, bounded to 1:1 messaging only

---

## Recommended Next Task

**`chat_feature_migration`**

Cél: implement the `chat` feature (1:1 direct messaging) in Tipsterino by:
- Creating the `messages` table migration
- Migrating domain/data/providers from TippmixApp chat feature
- Building the Tipsterino-native chat screen following existing UI patterns
- Extending ARB files with chat keys
- Running verify gate

Canvas: `canvases/chat_feature_migration.md`
