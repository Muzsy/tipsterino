# OpenClaw Run Prompt: Read-at Update on Chat Open

**Task slug:** `read_at_update_on_chat_open`  
**Runtime:** agent=tipmig | tipsterino workspace

---

## Mission

Implement the deferred chat enhancement in Tipsterino so that opening an authenticated 1:1 conversation marks incoming unread messages as read.

This is a **bounded follow-up task** to the already completed:
- `chat_feature_migration`
- `friends_feature_migration`

The task must close the remaining functional gap around `read_at` without expanding into broader messaging features.

---

## Current Known State

Treat these as already true unless the repo disproves them:

1. `chat_feature_migration` already ran and Tipsterino contains a working `/chat/:friendId` route.
2. `friends_feature_migration` already ran and accepted friend rows can deep-link into `/chat/:friendId`.
3. `messages` table already exists and already contains a nullable `read_at timestamptz` column.
4. The current chat screen streams conversation messages and supports sending text messages.
5. The current chat implementation intentionally deferred:
   - `read_at` update on conversation open
6. Tipsterino is the target repo.
7. TippmixApp is source/reference only.
8. Supabase-only stack. No Firebase/Firestore is allowed.

---

## Primary Goal

When an authenticated user opens `/chat/:friendId`, all unread incoming messages in that conversation addressed to the current user from that friend should be marked as read in a safe, idempotent, repo-compatible way.

This should also work for newly arriving unread incoming messages while the conversation is actively open, if that can be implemented cleanly without scope creep.

---

## Hard Rules

1. **Do not invent repo state.** Use actual current files only.
2. **Do not create a broad messaging redesign.**
3. **Do not add unread badges, conversation list, push notifications, presence, delivery states, typing indicators, attachments, edit/delete, or search.**
4. **Do not port Firebase/Firestore or any legacy backend logic.**
5. **Do not bypass Tipsterino patterns.**
   - use existing `SupabaseConfiguration`
   - use existing Riverpod structure
   - use existing route/auth model
6. **Do not run raw `flutter ...` commands directly.**
   Use only:
   - `./scripts/flutter.sh ...`
   - `./scripts/check.sh`
   - `./scripts/verify.sh --report ...`
7. **This task must create its own dedicated control pack.**
   Do not reuse chat/friends docs as substitutes.
8. **If a DB policy change is needed, do it with a new migration.**
   Do not hand-edit an already committed migration in place.
9. **Do not fake green verification.**
   If Flutter SDK is unavailable in the execution environment, document it exactly.

---

## Repositories

- **Target/control:** `./repos/tipsterino`
- **Source/reference:** `./repos/tippmixapp`

---

## Required Reading Before Starting

### Tipsterino rules and workflow
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

### Existing migration context
- `./repos/tipsterino/codex/reports/migration/chat_feature_migration.2026-03-22_001411.report.md`
- `./repos/tipsterino/codex/reports/migration/friends_feature_migration.md`
- `./repos/tipsterino/codex/codex_checklist/migration/friends_feature_migration.md`

### Current target implementation
- `./repos/tipsterino/supabase/migrations/20260322_001151_messages_table.sql`
- `./repos/tipsterino/app/lib/src/features/chat/domain/chat_message.dart`
- `./repos/tipsterino/app/lib/src/features/chat/domain/chat_exception.dart`
- `./repos/tipsterino/app/lib/src/features/chat/data/chat_repository.dart`
- `./repos/tipsterino/app/lib/src/features/chat/providers/chat_providers.dart`
- `./repos/tipsterino/app/lib/src/features/chat/presentation/screens/chat_screen.dart`
- `./repos/tipsterino/app/lib/src/app/router/app_router.dart`
- `./repos/tipsterino/app/test/widgets/chat_screen_test.dart`

### Source/reference
Read only if actually helpful; do not assume it already solves the problem:
- `./repos/tippmixapp/lib/features/chat/data/chat_repository.dart`
- `./repos/tippmixapp/lib/features/chat/presentation/screens/chat_screen.dart`
- `./repos/tippmixapp/supabase/migrations/20250922180200_messages_table.sql`
- `./repos/tippmixapp/supabase/migrations/20250926203101_friends_followers_messages.sql`

Important:
- if source repo does not contain a complete read-at-on-open implementation, the Tipsterino repo remains the source of truth for the final bounded design.

---

## Scope Freeze for This Task

### In scope

1. **Repository-level read update**
   - add a bounded repository method that marks unread incoming messages as read
   - target only messages where:
     - `receiver_id == currentUserId`
     - `sender_id == friendId`
     - `read_at is null`
   - use a single safe update path if possible
   - operation must be idempotent

2. **Chat screen integration**
   - trigger mark-read when the chat screen becomes active/open for a valid authenticated user
   - optionally re-trigger when new unread incoming messages arrive while the screen stays open, but only if clean and bounded
   - do not spam repeated writes unnecessarily

3. **Policy hardening if needed**
   - inspect whether current `messages` RLS/update policy is broader than needed
   - if appropriate, add a new migration to tighten write semantics around read updates
   - preserve current send/read functionality
   - do not break existing chat behavior

4. **Testing**
   - add or update tests covering the new behavior at the most appropriate layer available in this repo
   - widget test, provider test, or repository test is acceptable
   - prefer stable, bounded tests over ambitious integration scaffolding

5. **Control pack**
   - create dedicated canvas
   - create dedicated goal YAML
   - create dedicated run prompt
   - create dedicated checklist
   - create/update dedicated report

---

### Explicitly out of scope

- unread badge counters
- conversations list
- last-message preview list
- chat search
- typing indicators
- delivery status
- message edit/delete
- attachments
- push notifications
- club/group chat
- friend presence
- bottom-nav changes
- chat redesign
- social redesign

---

## Key Design Constraints

1. **Read means receiver-side only**
   The sender must not be the actor marking messages read.

2. **Only unread incoming messages in the active conversation**
   Do not bulk-update unrelated messages.

3. **Idempotent behavior**
   Reopening the screen should not create broken repeated state transitions.

4. **Avoid write storms**
   If the screen rebuilds frequently, the implementation must not fire uncontrolled repeated updates.

5. **Preserve current routing and auth gating**
   `/chat/:friendId` remains auth-gated exactly as it is.

6. **Keep localization clean**
   Only add EN/HU l10n keys if genuinely needed by the chosen UX/error path.

---

## Expected Output Files

Create or modify all relevant files needed for the task, including at minimum:

### Control-pack files
- `./repos/tipsterino/canvases/read_at_update_on_chat_open.md`
- `./repos/tipsterino/codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml`
- `./repos/tipsterino/codex/prompts/migration/read_at_update_on_chat_open/run.md`
- `./repos/tipsterino/codex/codex_checklist/migration/read_at_update_on_chat_open.md`
- `./repos/tipsterino/codex/reports/migration/read_at_update_on_chat_open.md`

### Likely app files
- `./repos/tipsterino/app/lib/src/features/chat/data/chat_repository.dart`
- `./repos/tipsterino/app/lib/src/features/chat/providers/chat_providers.dart`
- `./repos/tipsterino/app/lib/src/features/chat/presentation/screens/chat_screen.dart`
- `./repos/tipsterino/app/test/widgets/chat_screen_test.dart`

### Likely DB files
- `./repos/tipsterino/supabase/migrations/<timestamp>_messages_read_at_policy_hardening.sql`

Only create the migration if a schema/RLS adjustment is actually needed.

Add any additional touched file to the YAML outputs list if necessary.

---

## Execution Phases

### Phase 1 — Reconstruct the baseline

Inspect the real current Tipsterino implementation and write a baseline section into the report covering:

- how `messages` currently works
- current RLS/update policy shape
- where the chat screen lifecycle currently has a good insertion point
- whether existing tests can be extended or a new one is preferable

Explicitly note:
- whether current update policy is broader than receiver-only read updates
- whether source repo meaningfully helps or not

**Checkpoint 1**
- report contains real baseline
- report identifies actual files to change
- report states whether DB migration is necessary

---

### Phase 2 — Create the dedicated control pack

Create this task’s own:
- canvas
- YAML
- run prompt
- checklist
- report

Important:
- do not reuse previous task docs as substitutes
- paths must follow Tipsterino conventions
- YAML outputs must include every touched file

**Checkpoint 2**
- all control-pack files exist
- YAML paths are correct
- report initialized with baseline and task scope

---

### Phase 3 — Implement repository-side mark-read logic

Implement a bounded method in the chat repository to mark unread incoming messages as read for a single conversation.

Requirements:
- current user must be the receiver
- friend must be the sender
- only rows with `read_at is null`
- use current timestamp
- safe if client/config is unavailable
- errors must be handled in a Tipsterino-compatible way

Document in the report:
- query shape
- why it is safe
- why it is idempotent

**Checkpoint 3**
- repository logic exists
- target filter is bounded to the active conversation
- operation is idempotent

---

### Phase 4 — Integrate with ChatScreen lifecycle

Wire the mark-read behavior into the chat screen in a bounded way.

Preferred behavior:
- mark as read when the screen opens with a valid authenticated user
- optionally, when new unread incoming messages arrive while the screen is open, mark them read once
- avoid rebuild-triggered write spam

Acceptable implementation styles:
- `initState` + post-frame callback
- controlled `ref.listen`
- another bounded mechanism compatible with current Riverpod/screen structure

Do not over-engineer.

Document in the report:
- chosen trigger mechanism
- why it avoids repeated unnecessary writes

**Checkpoint 4**
- chat screen triggers mark-read for active conversation
- no obvious write storm pattern
- existing send/stream behavior remains intact

---

### Phase 5 — Tighten DB policy if needed

Inspect the current `messages` update policy.

If it is too broad for the new read semantics, create a new migration that tightens it appropriately.

Examples of acceptable outcomes:
- allow receiver-side `read_at` updates without allowing unsafe broader updates
- preserve the ability for the system to function with the new mark-read path

Do not break current chat inserts/selects.

Document clearly:
- whether migration was needed
- exact policy change
- why the new policy is safer

**Checkpoint 5**
- policy review documented
- migration created only if justified
- final policy supports intended behavior safely

---

### Phase 6 — Tests and verification

Add or update tests to cover the new read behavior as far as this repo’s current test setup realistically allows.

Good bounded options:
- verify mark-read method is invoked under controlled conditions
- verify chat screen initializes without regression
- verify no obvious localization/routing regression

Then run repo verification via wrappers only:

`./scripts/verify.sh --report codex/reports/migration/read_at_update_on_chat_open.md`

If Flutter SDK is unavailable:
- record the exact blocker
- do not fake PASS

**Checkpoint 6**
- test file updated or added
- verify command attempted truthfully
- report reflects real environment outcome

---

### Phase 7 — Finalize report

The final report must include:

- status
- baseline summary
- touched files
- implementation summary
- policy decision summary
- verification summary
- DoD → Evidence matrix
- advisory notes
- next recommended task slug

Likely note:
- if read-at is complete, the remaining broad social items are no longer chat-core blockers

**Checkpoint 7**
- report finalized
- status is truthful
- next task recommendation included

---

## Verification Gates

Before concluding, verify all of the following:

1. Dedicated control pack exists for this task
2. No Firebase/Firestore introduced
3. No scope creep into unread badges, conversation list, presence, or notifications
4. Mark-read targets only unread incoming messages in the active conversation
5. Implementation is receiver-side and idempotent
6. Chat route remains auth-gated
7. Existing send/stream behavior was preserved
8. DB policy review was done and migration added only if justified
9. Tests were updated or added
10. Repo verify was run via wrapper or the exact blocker was documented

---

## Suggested Status Logic

- **PASS**
  - implementation complete
  - control pack complete
  - verify ran green

- **PASS_WITH_NOTES**
  - implementation complete
  - control pack complete
  - only tooling/environment blocked full verify

- **FAIL**
  - missing control pack
  - missing core mark-read behavior
  - unsafe or overly broad policy change
  - broken chat regression
  - verify found real code failures

---

## Final Answer Contract

At the end, print ONLY:

```text
STATUS: <PASS | FAIL | PASS_WITH_NOTES>
REPORT: <relative path>
NEXT_TASK: <slug>
