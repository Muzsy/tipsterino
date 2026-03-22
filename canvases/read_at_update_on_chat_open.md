# Canvas: Read-at Update on Chat Open

**Task slug:** `read_at_update_on_chat_open`
**Created:** 2026-03-22

---

## Feature Goal

When an authenticated user opens `/chat/:friendId`, all unread incoming messages in that conversation (from friend → current user, where `read_at is null`) are marked as read.

---

## Non-Goals (Explicitly Excluded)

- unread badge counters
- conversations list / last-message preview
- message edit/delete
- typing indicators / delivery status
- push notifications
- club/group chat
- bottom-nav redesign

---

## Affected Files

### Core implementation
- `app/lib/src/features/chat/domain/chat_message.dart` — add `readAt` field
- `app/lib/src/features/chat/data/chat_repository.dart` — add `markConversationAsRead()`
- `app/lib/src/features/chat/presentation/screens/chat_screen.dart` — trigger mark-read on open
- `app/lib/src/features/chat/providers/chat_providers.dart` — may need ref for lifecycle

### Tests
- `app/test/widgets/chat_screen_test.dart` — extend to cover mark-read

### Control pack
- `canvases/read_at_update_on_chat_open.md` — this file
- `codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml`
- `codex/prompts/migration/read_at_update_on_chat_open/run.md`
- `codex/codex_checklist/migration/read_at_update_on_chat_open.md`
- `codex/reports/migration/read_at_update_on_chat_open.md`

---

## Definition of Done

1. `markConversationAsRead()` method exists in `ChatRepository`
2. Method targets only: `receiver_id = currentUserId`, `sender_id = friendId`, `read_at is null`
3. Operation is idempotent — re-running marks same messages no worse
4. `ChatScreen` triggers mark-read on mount
5. `ChatMessage` model includes `readAt` field
6. Existing send/stream behavior unchanged
7. RLS policy review: no new migration required (existing policy covers receiver updates)
8. Widget test updated or added

---

## Rollback Notes

- If `read_at` column logic causes issues: revert `ChatMessage` model changes only — DB column was already present before this task
- No migration rollback needed — no new schema was added

---

## Verification Expectations

- `flutter analyze` on chat feature passes
- Chat screen continues to render and stream messages
- Mark-read does not fire excessive repeated writes
- No Firebase/Firestore introduced
- No scope creep items introduced
