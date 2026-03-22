# OpenClaw Run Prompt: Friends Feature Migration

**Task slug:** `friends_feature_migration`  
**Runtime:** agent=tipmig | tipsterino workspace

---

## Mission

Implement the bounded **friends feature** in Tipsterino so that the existing chat route (`/chat/:friendId`) gets a real navigation context.

This task is both a **control-pack + implementation** task.

The output must give Tipsterino:
- an auth-gated `/friends` route,
- a minimal but usable friends screen,
- accepted friends list,
- incoming pending requests,
- nickname search over public profiles,
- send / accept / decline / remove friendship flows,
- deep-link from accepted friend rows into `/chat/:friendId`,
- a minimal entry point from the existing profile area.

This task must stay **strictly bounded**. It is not a broader social-system migration.

---

## Current Known State

Treat these as already true unless the repo disproves them:

1. `chat_feature_migration` already ran and the chat feature exists in Tipsterino.
2. Chat route already exists at `/chat/:friendId`.
3. Chat post-run repairs are already applied in repo state.
4. Tipsterino is the only implementation target.
5. TippmixApp is source/reference only.
6. Supabase-only target stack. No Firebase/Firestore migration is allowed.
7. Current deferred chat items remain deferred unless explicitly included below:
   - `read_at` update on conversation open
   - broader chat deep-link polish outside friends/profile context
   - broader social redesign

---

## Hard Rules

1. **Do not invent repo state.** Use only actual files and actual current structure.
2. **Target app code lives only in `./repos/tipsterino/app/`.**
3. **Do not port Firebase/Firestore, notification services, followers, legacy friend_requests, or any hybrid backend logic.**
4. **Do not copy TippmixApp blindly.** Adapt it to Tipsterino’s real contracts and current architecture.
5. **Do not reuse the scope-freeze docs as substitutes for this task’s own control pack.**
   This task must create its own dedicated:
   - canvas
   - goal YAML
   - run prompt
   - checklist
   - report
6. **Do not run raw `flutter ...` commands directly.**
   Use repo wrappers only:
   - `./scripts/flutter.sh ...`
   - `./scripts/check.sh`
   - `./scripts/verify.sh --report ...`
7. **No hardcoded UI strings.**
   All user-facing strings must go through EN/HU localization.
8. **No hardcoded colors / deprecated styling shortcuts.**
   Follow current Tipsterino theme usage and current Flutter-compatible APIs.
9. **Do not introduce scope creep**:
   - no club chat
   - no notifications
   - no public profile feature
   - no follower system
   - no leaderboard/social redesign
   - no bottom-nav tab for friends
   - no read_at chat enhancement in this task
10. If verification cannot run because the environment is missing Flutter SDK or similar tooling, do **not** fake a green result. Document it exactly and use `PASS_WITH_NOTES` only if implementation is otherwise complete.

---

## Repositories

- **Target/control:** `./repos/tipsterino`
- **Source/reference:** `./repos/tippmixapp`

---

## Required Reading Before Starting

### Tipsterino core rules
- `./repos/tipsterino/AGENTS.md`
- `./repos/tipsterino/docs/codex/overview.md`
- `./repos/tipsterino/docs/codex/yaml_schema.md`
- `./repos/tipsterino/docs/codex/report_standard.md`
- `./repos/tipsterino/docs/qa/testing_guidelines.md`
- `./repos/tipsterino/docs/architect/project_structure.md`
- `./repos/tipsterino/docs/architect/routing_integrity.md`
- `./repos/tipsterino/docs/architect/theme_rules.md`
- `./repos/tipsterino/docs/architect/service_dependencies.md`
- `./repos/tipsterino/docs/localization/localization_logic.md`

### Existing migration context in Tipsterino
- `./repos/tipsterino/codex/reports/openclaw/migration_repo_inventory_and_control_docs.2026-03-21_231512.report.md`
- `./repos/tipsterino/codex/reports/migration/first_migration_unit_scope_freeze.2026-03-21_235144.md`
- `./repos/tipsterino/codex/reports/migration/chat_feature_migration.2026-03-22_001411.report.md`
- `./repos/tipsterino/codex/codex_checklist/migration/chat_feature_migration.md`
- `./repos/tipsterino/app/lib/src/features/chat/domain/chat_message.dart`
- `./repos/tipsterino/app/lib/src/features/chat/domain/chat_exception.dart`
- `./repos/tipsterino/app/lib/src/features/chat/data/chat_repository.dart`
- `./repos/tipsterino/app/lib/src/features/chat/providers/chat_providers.dart`
- `./repos/tipsterino/app/lib/src/features/chat/presentation/screens/chat_screen.dart`
- `./repos/tipsterino/app/lib/src/app/router/app_router.dart`
- `./repos/tipsterino/app/lib/src/features/profile/presentation/screens/profile_screen.dart`

### Tipsterino schema references
- `./repos/tipsterino/supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `./repos/tipsterino/supabase/migrations/20260215000000_public_profiles_privacy_hardening.sql`
- `./repos/tipsterino/supabase/migrations/20260322_001151_messages_table.sql`

### TippmixApp source/reference for friends
- `./repos/tippmixapp/lib/features/friends/domain/friend_status.dart`
- `./repos/tippmixapp/lib/features/friends/domain/friend_profile.dart`
- `./repos/tippmixapp/lib/features/friends/domain/friend_search_result.dart`
- `./repos/tippmixapp/lib/features/friends/domain/friendship.dart`
- `./repos/tippmixapp/lib/features/friends/domain/friend_operation_exception.dart`
- `./repos/tippmixapp/lib/features/friends/data/friends_repository.dart`
- `./repos/tippmixapp/lib/features/friends/providers/friends_providers.dart`
- `./repos/tippmixapp/lib/features/friends/presentation/friends_screen.dart`
- `./repos/tippmixapp/lib/features/friends/presentation/widgets/friend_list_item.dart`
- `./repos/tippmixapp/lib/features/friends/presentation/widgets/friend_request_item.dart`
- `./repos/tippmixapp/lib/features/friends/presentation/widgets/friend_search_result_item.dart`
- `./repos/tippmixapp/supabase/migrations/20250922180100_friends_table.sql`
- `./repos/tippmixapp/supabase/migrations/20251005101000_drop_followers_friend_requests.sql`
- `./repos/tippmixapp/supabase/migrations/20251005102000_friends_unique_pair.sql`

---

## Scope Freeze for This Task

### In scope

Implement a bounded Tipsterino-native friends feature with:

1. **Friends DB contract**
   - a `friends` table in Tipsterino
   - bilateral relationship model
   - statuses limited to `pending | accepted | rejected`
   - canonical uniqueness for a user pair
   - RLS for participants only
   - schema shaped for realtime support

2. **Friends domain/data/providers**
   - friend status model
   - friend profile model adapted to Tipsterino profile contract
   - friendship model
   - search result model
   - narrow exception model for friend operations
   - repository adapted to Tipsterino `SupabaseConfiguration`
   - Riverpod providers for:
     - accepted friends
     - incoming pending requests
     - search query / search results
     - repository access

3. **Friends presentation**
   - a Tipsterino-native `FriendsScreen`
   - accepted friends list section
   - incoming request section
   - profile search field
   - send request
   - accept request
   - decline request
   - remove friendship
   - open chat from accepted friend item

4. **Routing / navigation**
   - auth-gated `/friends` route
   - minimal entry point from existing `ProfileScreen` to `/friends`
   - accepted friend items deep-link to `/chat/:friendId`

5. **Localization**
   - EN/HU keys for the full friends UI and basic operation feedback

6. **Testing / verification**
   - at least one widget test covering route/screen render and core interaction expectations
   - repo verify through wrapper scripts

---

### Explicitly out of scope

- followers system
- separate friend_requests table
- notifications / notification service migration
- public profile page
- score / leaderboard enrichment
- avatar URL/network image system from TippmixApp
- club chat / group chat
- read_at update in chat when opening conversation
- message unread counters
- blocking / muting / reporting users
- social feed redesign
- bottom-nav friends tab
- advanced debounce/search analytics/pagination polish

---

## Key Adaptation Decisions (mandatory)

These are not optional. Respect them unless the real repo forces a better version:

1. **Use Tipsterino profile contract, not TippmixApp’s profile contract.**
   - Tipsterino public profile shape is based on `public.public_profiles`
   - use fields that actually exist in Tipsterino (`id`, `nickname`, `avatar_key`)
   - do not invent `avatar_url` or `score` if they are not present

2. **Do not port notification integration.**
   - remove TippmixApp notification side-effects from the migrated logic

3. **Do not replay TippmixApp’s whole schema history literally.**
   - create the final bounded schema that Tipsterino needs now
   - prefer a single clean migration if that is sufficient
   - include canonical pair uniqueness from the start
   - do not reintroduce legacy `followers` / `friend_requests`

4. **Do not use global Supabase singletons in the migrated repository layer.**
   - follow the current Tipsterino `supabaseConfigProvider` / `SupabaseConfiguration` pattern

5. **Do not port TippmixApp’s error stack wholesale.**
   - Tipsterino does not currently have the same AppError/AppErrorMapper setup
   - use a narrow Tipsterino-compatible exception pattern similar in spirit to the chat migration

6. **Use only repo-compatible SDK/filter APIs.**
   - do not reintroduce removed/deprecated filter helpers
   - prefer the same style already proven in the current repo state

7. **Keep the UI minimal and compatible with what Tipsterino already has.**
   - do not build an oversized social hub
   - if no reusable avatar component exists, use a simple Material 3 friendly fallback
   - prefer initials / simple avatar-key based fallback over invented asset systems

---

## Expected Output Files

Create or modify all relevant files needed for the task, including at minimum:

### Control-pack files
- `./repos/tipsterino/canvases/friends_feature_migration.md`
- `./repos/tipsterino/codex/goals/canvases/fill_canvas_friends_feature_migration.yaml`
- `./repos/tipsterino/codex/prompts/migration/friends_feature_migration/run.md`
- `./repos/tipsterino/codex/codex_checklist/migration/friends_feature_migration.md`
- `./repos/tipsterino/codex/reports/migration/friends_feature_migration.md`

### App files
- `./repos/tipsterino/app/lib/src/features/friends/domain/friend_status.dart`
- `./repos/tipsterino/app/lib/src/features/friends/domain/friend_profile.dart`
- `./repos/tipsterino/app/lib/src/features/friends/domain/friend_search_result.dart`
- `./repos/tipsterino/app/lib/src/features/friends/domain/friendship.dart`
- `./repos/tipsterino/app/lib/src/features/friends/domain/friend_operation_exception.dart`
- `./repos/tipsterino/app/lib/src/features/friends/data/friends_repository.dart`
- `./repos/tipsterino/app/lib/src/features/friends/providers/friends_providers.dart`
- `./repos/tipsterino/app/lib/src/features/friends/presentation/screens/friends_screen.dart`

If needed for clean UI decomposition, also create:
- `./repos/tipsterino/app/lib/src/features/friends/presentation/widgets/friend_list_item.dart`
- `./repos/tipsterino/app/lib/src/features/friends/presentation/widgets/friend_request_item.dart`
- `./repos/tipsterino/app/lib/src/features/friends/presentation/widgets/friend_search_result_item.dart`

### Routing / existing screen updates
- `./repos/tipsterino/app/lib/src/app/router/app_router.dart`
- `./repos/tipsterino/app/lib/src/features/profile/presentation/screens/profile_screen.dart`

### Localization
- `./repos/tipsterino/app/lib/l10n/app_en.arb`
- `./repos/tipsterino/app/lib/l10n/app_hu.arb`

### DB migration
- `./repos/tipsterino/supabase/migrations/<timestamp>_friends_table.sql`

### Tests
- `./repos/tipsterino/app/test/widgets/friends_screen_test.dart`

Add any additional touched file to the YAML outputs list if it becomes necessary.

---

## Execution Phases

### Phase 1 — Reconstruct the real baseline

1. Verify what already exists in Tipsterino for:
   - chat
   - profile
   - router
   - Supabase profile/public profile contract
2. Verify what the source TippmixApp friends feature actually does today.
3. Write a short baseline section into the report:
   - what is already present
   - what is missing
   - which source files are truly relevant
4. Explicitly call out the key adaptation deltas:
   - `avatar_url` vs `avatar_key`
   - `score` absence
   - notification removal
   - no follower/friend_requests port

**Checkpoint 1**
- report contains a real baseline summary
- report lists actual relevant files
- report lists schema/profile adaptation constraints

---

### Phase 2 — Create a dedicated control pack for this task

Create this task’s own dedicated:
- canvas
- goal YAML
- run prompt
- checklist
- report

Important:
- do **not** reuse `tipsterino_first_migration_unit_scope_freeze` artifacts as substitutes
- this task must stand on its own in the repo

The canvas must include:
- feature goal
- non-goals
- affected files
- DoD
- rollback notes
- verification expectations

The YAML must:
- use the repo schema exactly
- include every touched file in outputs
- end with a repo gate step using:
  - `./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md`

**Checkpoint 2**
- all control-pack files exist
- paths follow Tipsterino conventions
- YAML outputs cover every file that will be touched

---

### Phase 3 — Design and implement the DB contract

Implement a clean Tipsterino-side `friends` schema.

Requirements:
1. Bilateral relationships only
2. Allowed statuses: `pending`, `accepted`, `rejected`
3. No self-relationship
4. Canonical user-pair uniqueness
5. Realtime-compatible primary key strategy if required by the repo/Supabase client usage
6. Participant-only RLS for select/update/delete
7. Insert restricted to requester identity
8. No follower table
9. No separate friend_requests table

Prefer a clean final-state migration instead of replaying multiple legacy migrations unless the actual repo structure requires otherwise.

Document in the report:
- chosen schema
- key constraints
- RLS policies
- why the final-state approach is valid for Tipsterino

**Checkpoint 3**
- migration exists
- schema is bounded and clean
- no legacy social tables reintroduced

---

### Phase 4 — Implement domain, repository, and providers

Implement the friends domain/data/providers adapted to Tipsterino.

Requirements:
- repository must use Tipsterino’s Supabase configuration pattern
- no notification side-effects
- no global singleton shortcut
- no source-only error infrastructure copied over blindly
- profile lookups/search must use the actual Tipsterino-readable profile contract
- search must exclude the current authenticated user
- accepted friends and incoming pending requests must be stream-based if practical and repo-compatible
- deep-link support must expose the friend ID needed for `/chat/:friendId`

Repository behavior must support:
- watch accepted friends
- watch incoming pending requests
- search public profiles by nickname
- send friend request
- accept request
- decline request
- remove friendship

Document any deliberate deviations from TippmixApp in the report.

**Checkpoint 4**
- all core friends models/repository/providers exist
- no notification import / no Firebase import
- Tipsterino profile contract is respected

---

### Phase 5 — Implement FriendsScreen and navigation

Create a minimal but solid Tipsterino-native friends screen.

UI requirements:
- Material 3 / ColorScheme / TextTheme only
- search input at top
- incoming requests section
- accepted friends section
- empty states
- basic loading and error states
- action buttons for request handling
- action on accepted friend row to open chat

Navigation requirements:
1. Add auth-gated route:
   - `/friends`
2. Add a minimal entry point from existing `ProfileScreen`
   - simple button/list tile is enough
   - do not redesign the whole profile screen
3. Accepted friend rows must open:
   - `/chat/:friendId`

Do not introduce a friends bottom-nav tab.

**Checkpoint 5**
- `/friends` exists and is auth-gated
- Profile screen can reach `/friends`
- Accepted friend rows can reach `/chat/:friendId`

---

### Phase 6 — Localization and tests

Add all necessary EN/HU keys for the friends feature.

Rules:
- no hardcoded UI text
- do not hand-edit generated localization files unless the repo already expects that workflow
- keep naming consistent with the current migration-era style in this repo

Create at least one widget test covering:
- friends screen rendering
- core route access/render path
- at least one important interaction expectation

Good candidates:
- route renders for authenticated state
- empty state visible without data
- chat action visible for accepted friend row
- profile CTA navigates to friends route

**Checkpoint 6**
- EN/HU keys exist
- test file exists
- no obvious hardcoded strings remain in friends UI

---

### Phase 7 — Verify and finalize report

Run the repo gate with wrappers only:

`./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md`

If the environment lacks Flutter SDK or another required tool:
- do not fake PASS
- document the exact blocker
- leave a truthful result in the report

The final report must include:
- status
- actual touched files
- change summary
- verification summary
- DoD → Evidence matrix
- advisory notes
- follow-ups

It must also mention, if true, that the remaining chat deferred item `read_at on open` still remains for a later task.

**Checkpoint 7**
- report finalized
- verify result recorded truthfully
- next recommended task slug chosen

---

## Verification Gates

Before concluding, verify all of the following:

1. This task created its own dedicated control pack
2. No Firebase / Firestore / notification service code was introduced
3. No `avatar_url` / `score` assumptions were invented if the target repo does not support them
4. `friends` schema is bounded and does not reintroduce followers or separate friend request tables
5. `/friends` route is auth-gated
6. `ProfileScreen` has a minimal entry into `/friends`
7. Accepted friend items deep-link into `/chat/:friendId`
8. EN/HU localization keys exist
9. No hardcoded UI strings remain in the friends feature
10. Repo gate was run via wrapper or the exact blocker was documented

---

## Suggested Status Logic

- **PASS**
  - implementation done
  - control-pack done
  - verify ran green

- **PASS_WITH_NOTES**
  - implementation done
  - control-pack done
  - only non-code/tooling limitations blocked full verify

- **FAIL**
  - missing control-pack
  - broken scope
  - missing key implementation pieces
  - schema/profile contract invented incorrectly
  - verify found real code failures

---

## Final Answer Contract

At the end, print ONLY:

```text
STATUS: <PASS | FAIL | PASS_WITH_NOTES>
REPORT: <relative path>
NEXT_TASK: <slug>
