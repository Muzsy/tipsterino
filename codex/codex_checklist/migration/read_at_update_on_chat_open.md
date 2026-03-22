# Checklist: read_at_update_on_chat_open

**Task:** Implement mark-read on chat open
**Repo:** `./repos/tipsterino`
**Created:** 2026-03-22

---

## Control Pack

- [x] `canvases/read_at_update_on_chat_open.md` created
- [x] `codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml` created
- [x] `codex/prompts/migration/read_at_update_on_chat_open/run.md` created
- [x] `codex/codex_checklist/migration/read_at_update_on_chat_open.md` created
- [x] `codex/reports/migration/read_at_update_on_chat_open.md` initialized

---

## Phase 1 — Baseline

- [x] Inspected `messages` table migration: `read_at timestamptz` column present
- [x] Inspected RLS update policy: `Messages update participants` covers receiver updates
- [x] Inspected `ChatRepository`: no `markConversationAsRead` method exists
- [x] Inspected `ChatScreen`: no mark-read on open logic
- [x] Inspected `ChatMessage`: does not parse/store `readAt`

**DB migration needed?** NO — existing RLS policy allows receiver updates

---

## Phase 2 — Control Pack

- [x] Canvas created
- [x] YAML created with all outputs listed
- [x] Run prompt created
- [x] Checklist created
- [x] Report initialized

---

## Phase 3 — Repository

- [x] `ChatMessage.readAt` field added (nullable DateTime)
- [x] `ChatMessage.fromMap` parses `read_at`
- [x] `ChatMessage.copyWith` includes `readAt`
- [x] `ChatMessage.toMap` serializes `read_at`
- [x] `ChatMessage.==` and `hashCode` include `readAt`
- [x] `ChatRepository.markConversationAsRead()` added
  - Target: `receiver_id = currentUserId`, `sender_id = friendId`, `read_at is null`
  - Uses `now()` as read timestamp
  - Idempotent: re-running updates same rows (no harm)
  - Handles null client gracefully (no-op)

---

## Phase 4 — Screen Integration

- [x] `_ChatScreenState.initState()` calls `markConversationAsRead` via `addPostFrameCallback`
- [x] Guard: checks `currentUserId.isNotEmpty` before calling
- [x] Guard: checks mounted before calling repository
- [x] No repeated writes on rebuild (single post-frame callback, not in build())
- [x] Existing send/stream behavior unchanged

---

## Phase 5 — Policy Review

- [x] Existing RLS update policy: `auth.uid() = sender_id or auth.uid() = receiver_id`
- [x] Policy allows receiver to update `read_at` on their incoming messages ✅
- [x] No new migration required
- [x] Decision documented in report

---

## Phase 6 — Tests & Verification

- [x] Widget test: `chat_screen_test.dart` updated to test mark-read integration
- [x] `flutter analyze` attempted (Flutter SDK availability varies)
- [x] Blocker documented if SDK unavailable

---

## Phase 7 — Report

- [x] Status set honestly (PASS_WITH_NOTES if SDK unavailable)
- [x] All touched files listed
- [x] Implementation summary written
- [x] Policy decision documented
- [x] Advisory notes included
- [x] Next task recommended

---

## Verification Gates (final check)

1. [x] Dedicated control pack exists
2. [x] No Firebase/Firestore introduced
3. [x] No scope creep (no badges, conversation list, notifications, presence)
4. [x] Mark-read targets only unread incoming messages in active conversation
5. [x] Implementation is receiver-side and idempotent
6. [x] Chat route remains auth-gated (unchanged)
7. [x] Existing send/stream behavior preserved
8. [x] DB policy review done; no migration needed
9. [x] Tests updated
10. [x] Verify attempted truthfully (SDK noted as limitation)
