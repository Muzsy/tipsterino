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

5. **Control pack**
   - create dedicated canvas, YAML, run prompt, checklist, report

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

---

## Expected Output Files

### Control-pack files
- `canvases/read_at_update_on_chat_open.md`
- `codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml`
- `codex/prompts/migration/read_at_update_on_chat_open/run.md`
- `codex/codex_checklist/migration/read_at_update_on_chat_open.md`
- `codex/reports/migration/read_at_update_on_chat_open.md`

### App files
- `app/lib/src/features/chat/domain/chat_message.dart`
- `app/lib/src/features/chat/data/chat_repository.dart`
- `app/lib/src/features/chat/presentation/screens/chat_screen.dart`
- `app/test/widgets/chat_screen_test.dart`

Only create DB migration if RLS policy change is actually needed.

---

## Execution Phases

### Phase 1 — Reconstruct the baseline
Inspect current messages schema, RLS policy, ChatRepository, ChatScreen lifecycle.
Checkpoint: report contains real baseline and states whether DB migration is necessary.

### Phase 2 — Create the dedicated control pack
Create canvas, YAML, run prompt, checklist, report.
Checkpoint: all control-pack files exist.

### Phase 3 — Implement repository-side mark-read logic
Add `readAt` to `ChatMessage`. Add `markConversationAsRead()` to `ChatRepository`.
Checkpoint: method exists, bounded to active conversation, idempotent.

### Phase 4 — Integrate with ChatScreen lifecycle
Wire mark-read into screen using addPostFrameCallback on mount.
Checkpoint: chat screen triggers mark-read for active conversation; no write storm.

### Phase 5 — Tighten DB policy if needed
Review existing RLS update policy. No new migration expected (existing policy allows receiver updates).
Checkpoint: policy review documented; migration only if justified.

### Phase 6 — Tests and verification
Update widget test. Run `./scripts/verify.sh --report codex/reports/migration/read_at_update_on_chat_open.md`.
Checkpoint: test updated; verify attempted truthfully.

### Phase 7 — Finalize report
Final report must include status, baseline, touched files, implementation summary, DoD→Evidence, advisory notes, next task.
Checkpoint: report finalized; truthful status.

---

## Verification Gates

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

## Final Answer Contract

At the end, print ONLY:

```text
STATUS: <PASS | FAIL | PASS_WITH_NOTES>
REPORT: <relative path>
NEXT_TASK: <slug>
```
