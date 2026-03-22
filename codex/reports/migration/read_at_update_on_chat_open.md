# Report: read_at_update_on_chat_open

**Task slug:** `read_at_update_on_chat_open`
**Status:** IN_PROGRESS
**Created:** 2026-03-22

---

## Phase 1 — Baseline

**messages table schema (`20260322_001151_messages_table.sql`):**
- `id uuid primary key`
- `sender_id uuid not null references public.profiles(id)`
- `receiver_id uuid not null references public.profiles(id)`
- `content text not null check (char_length <= 2000)`
- `created_at timestamptz not null default now()`
- `read_at timestamptz` — already present, nullable ✅
- `messages_no_self` check constraint

**RLS policies:**
- Select: `auth.uid() = sender_id or auth.uid() = receiver_id`
- Insert: `auth.uid() = sender_id` (sender only)
- Update: `auth.uid() = sender_id or auth.uid() = receiver_id` ✅ — receiver CAN update read_at
- Delete: `auth.uid() = sender_id or auth.uid() = receiver_id`

**Key finding: NO new migration needed.** Existing update policy allows receiver to update `read_at`.

**`ChatMessage` before:** 5 fields (id, senderId, receiverId, content, createdAt); `read_at` was NOT parsed.

**`ChatRepository` before:** `watchConversation()` + `sendMessage()` only. No `markConversationAsRead()`.

**`ChatScreen` before:** No mark-read logic. Stream consumer only.

**Source repo relevance:** TippmixApp `chat_repository.dart` was inspected but does not contain a read-at-on-open implementation that applies cleanly — Tipsterino implementation is native.

---

## Phase 2 — Control Pack

| File | Status |
|------|--------|
| `canvases/read_at_update_on_chat_open.md` | ✅ Created |
| `codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml` | ✅ Created |
| `codex/prompts/migration/read_at_update_on_chat_open/run.md` | ✅ Created |
| `codex/codex_checklist/migration/read_at_update_on_chat_open.md` | ✅ Created |
| `codex/reports/migration/read_at_update_on_chat_open.md` | ✅ This file |

---

## Phase 3 — Repository Implementation

### `ChatMessage` changes
- Added `readAt` field (nullable `DateTime?`)
- `fromMap()` parses `read_at` via `_parseNullableDateTime()`
- `copyWith()` includes `readAt`
- `toMap()` serializes `read_at` (conditional — only if not null)
- `==` and `hashCode` include `readAt`

### `ChatRepository.markConversationAsRead()` added
```dart
Future<void> markConversationAsRead({
  required String currentUserId,
  required String friendId,
}) async
```
- Guard: no-op if either ID is empty
- Guard: no-op if client is null
- Query: `update messages set read_at = now() where receiver_id = currentUserId and sender_id = friendId and read_at is null`
- Errors: swallowed silently (best-effort)
- Idempotent: re-running updates already-read rows harmlessly

---

## Phase 4 — Screen Integration

### `_ChatScreenState` changes
- Added `_readMarked` bool flag to prevent double-firing
- `initState()` schedules `_markReadIfNeeded()` via `addPostFrameCallback`
- `_markReadIfNeeded()`:
  - Checks `_readMarked` guard
  - Reads current user from `authNotifierProvider`
  - Calls `chatRepositoryProvider.markConversationAsRead()`
  - Sets `_readMarked = true`
- `build()` is untouched — no rebuild-triggered writes
- Existing send/stream behavior: unchanged ✅

---

## Phase 5 — Policy Review

**Decision: NO new migration needed.**

Existing RLS update policy (`Messages update participants`) allows any participant (sender OR receiver) to update any column. This is intentionally broad for 1:1 messaging. The `markConversationAsRead` operation uses a bounded query (`receiver_id = currentUserId, sender_id = friendId, read_at is null`) so it only touches the intended rows even though the policy is broad.

If a future tightening is desired, a separate policy restricting `read_at` updates to the receiver only would be appropriate, but that is out of scope for this bounded task.

---

## Phase 6 — Tests & Verification

**Test file updated:** `app/test/widgets/chat_screen_test.dart`
- Added `FakeChatRepository` implementing `ChatRepository`
- Records `markConversationAsReadCalled`, `lastCurrentUserId`, `lastFriendId`
- New test: "calls markConversationAsRead on screen mount"
- Verifies the method is called with correct `friendId`

**Flutter SDK status:** Flutter is not installed in this execution environment (`flutter: not found`). Per Hard Rule #9, PASS will not be faked.

---

## Touched Files

| File | Change |
|------|--------|
| `app/lib/src/features/chat/domain/chat_message.dart` | Added `readAt` field + full support |
| `app/lib/src/features/chat/data/chat_repository.dart` | Added `markConversationAsRead()` |
| `app/lib/src/features/chat/presentation/screens/chat_screen.dart` | Added `initState` mark-read trigger |
| `app/test/widgets/chat_screen_test.dart` | Added FakeChatRepository + mark-read test |
| `canvases/read_at_update_on_chat_open.md` | New canvas |
| `codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml` | New goal YAML |
| `codex/prompts/migration/read_at_update_on_chat_open/run.md` | New run prompt |
| `codex/codex_checklist/migration/read_at_update_on_chat_open.md` | New checklist |
| `codex/reports/migration/read_at_update_on_chat_open.md` | This report |

---

## Verification Summary

| Gate | Status |
|------|--------|
| Dedicated control pack exists | ✅ |
| No Firebase/Firestore introduced | ✅ |
| No scope creep (badges, conversation list, notifications, presence) | ✅ |
| Mark-read targets only unread incoming messages in active conversation | ✅ |
| Implementation is receiver-side and idempotent | ✅ |
| Chat route remains auth-gated | ✅ (unchanged router) |
| Existing send/stream behavior preserved | ✅ |
| DB policy review done; migration only if justified | ✅ (none needed) |
| Tests updated | ✅ |
| Flutter SDK unavailable — verified truthfully | ✅ |

---

## Advisory Notes

1. **Flutter SDK not available in execution environment.** Full `flutter analyze` / `flutter test` could not be run. Implementation is complete and uses correct patterns — verification should pass in a properly configured CI environment with Flutter 3.41.5 installed.

2. **RLS policy is broad by design.** The existing update policy allows any participant to update any column. The `markConversationAsRead` query is bounded to the intended rows. A future tightening PR could restrict `read_at` updates to receiver-only, but that is a separate hardening task.

3. **Best-effort read marking.** Errors during `markConversationAsRead` are silently swallowed. This is intentional — read state is not critical path for chat functionality. Messages remain readable regardless.

4. **`_readMarked` flag.** Prevents double-firing if `initState` somehow runs twice. The `addPostFrameCallback` in `initState` combined with the mounted guard provides sufficient protection against write storms.

---

## DoD → Evidence

| DoD item | Evidence |
|----------|----------|
| `markConversationAsRead()` exists in ChatRepository | ✅ `chat_repository.dart` updated |
| Method targets correct rows (receiver, friend, unread) | ✅ `.eq('receiver_id', currentUserId).eq('sender_id', friendId).is_('read_at', null)` |
| Operation is idempotent | ✅ Updates `read_at = now()` on null rows; re-running is safe |
| ChatScreen triggers mark-read on mount | ✅ `addPostFrameCallback` in `initState` |
| `ChatMessage` includes `readAt` field | ✅ `chat_message.dart` updated |
| Existing send/stream unchanged | ✅ No changes to `watchConversation` or `sendMessage` |
| DB policy review: no new migration needed | ✅ Existing policy allows receiver updates |
| Widget test updated | ✅ `FakeChatRepository` + test case |

---

## Next Recommended Task

**`events_feature_completion`** — the events feature has pre-existing localization errors (missing `eventDailyBonusTitle` / `eventDailyBonusBody` keys) that were noted during `chat_feature_migration` post-run repair. Fixing those keys would unblock the widget test for `events_inbox_screen`.

Alternatively: **`bets_feature_migration`** to begin migrating the bets feature from TippmixApp.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **FAIL**
- check.sh exit kód: `127`
- futás: 2026-03-22T15:58:57+01:00 → 2026-03-22T15:58:57+01:00 (0s)
- parancs: `./scripts/check.sh`
- log: `/home/openclaw/.openclaw/workspace/repos/tipsterino/codex/reports/migration/read_at_update_on_chat_open.verify.log`
- git: `main@bc8b900`
- módosított fájlok (git status): 11

**git diff --stat**

```text
 .../src/features/chat/data/chat_repository.dart    | 27 ++++++++++
 app/lib/src/features/chat/domain/chat_message.dart | 26 ++++++++-
 .../chat/presentation/screens/chat_screen.dart     | 23 ++++++++
 app/test/widgets/chat_screen_test.dart             | 62 ++++++++++++++++++++--
 4 files changed, 132 insertions(+), 6 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/features/chat/data/chat_repository.dart
 M app/lib/src/features/chat/domain/chat_message.dart
 M app/lib/src/features/chat/presentation/screens/chat_screen.dart
 M app/test/widgets/chat_screen_test.dart
?? canvases/read_at_update_on_chat_open.md
?? codex/codex_checklist/migration/read_at_update_on_chat_open.md
?? codex/goals/canvases/fill_canvas_read_at_update_on_chat_open.yaml
?? codex/prompts/migration/read_at_update_on_chat_open/
?? codex/prompts/openclaw/read_at_update_on_chat_open_task.md
?? codex/reports/migration/read_at_update_on_chat_open.md
?? codex/reports/migration/read_at_update_on_chat_open.verify.log
```

**FAIL tail (utolsó ~60 sor a logból)**

```text
/home/openclaw/.openclaw/workspace/repos/tipsterino/scripts/flutter.sh: line 38: exec: flutter: not found
```

<!-- AUTO_VERIFY_END -->
