# Chat Feature — Full Code & Function Audit

**Feature:** `chat` (1:1 direct messaging)
**Auditor:** tipmig agent
**Date:** 2026-03-24
**Repo:** `./repos/tipsterino`
**Files audited:**
- `app/lib/src/features/chat/domain/chat_message.dart`
- `app/lib/src/features/chat/domain/chat_exception.dart`
- `app/lib/src/features/chat/data/chat_repository.dart`
- `app/lib/src/features/chat/providers/chat_providers.dart`
- `app/lib/src/features/chat/presentation/screens/chat_screen.dart`
- `supabase/migrations/20260322_001151_messages_table.sql`
- `app/test/widgets/chat_screen_test.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/lib/l10n/app_en.arb` / `app_hu.arb`

---

## Overall Status: `PASS_WITH_FIXES`

**Fixes applied:**
- ✅ MEDIUM-2 fixed: realtime-aware auto-scroll via `ref.listen` + `NotificationListener` in `chat_screen.dart` (`c3a5411`)
- ✅ MEDIUM-3 fixed: 9 new widget tests added covering send interaction, error states, multiple messages, loading state (`c3a5411`)
- ✅ CLEANUP done: `chat_send` dead ARB key removed from EN and HU (`c3a5411`)
- ✅ MEDIUM-3 fixed (unit): 30 new unit tests added covering validation, domain model, and edge cases (`b32da64`)

**CRITICAL-1 clarification (no code change):**
`isFilter('read_at', null)` is the **correct** API in `postgrest 2.6.0`.
`isFilter(String column, bool? value)` — passing `null` as `bool?` correctly generates SQL `IS NULL`.
The audit claim that `.is()` would be the correct form was incorrect; `.is()` does not exist in this API.
Audit was wrong to flag this as CRITICAL. Corrected in `b32da64`.

---

## 1. Functional Compliance vs Frozen Scope

| Frozen Scope Requirement | Status | Evidence |
|---|---|---|
| 1:1 private messaging | ✅ | DB `messages` table, bidirectional filter in Dart |
| Realtime message stream | ✅ | `watchConversation` + `StreamProvider.autoDispose` |
| Send trimmed ≤2000 chars | ✅ | `content.trim()`, `trimmed.length > 2000` check |
| View conversation history | ✅ | ListView with `created_at` ascending |
| `read_at` implicit tracking | ✅ | DB column + `markConversationAsRead()` |
| sender ≠ receiver | ✅ | `messages_no_self` check constraint |
| Auth-gated access | ✅ | Not in guestAllowlist → global redirect to `/auth/login` |
| EN/HU localization | ✅ | 7 keys in both ARB files |
| Tipsterino-native screen | ✅ | Material 3, ColorScheme, no hardcoded colors |
| Supabase migration | ✅ | `20260322_001151_messages_table.sql` |

**Deferred items (legit, documented):**
- `read_at` update on conversation open → separate task ✅
- No club chat / notifications ✅

---

## 2. Critical Issues

### CRITICAL-1: Wrong Supabase filter API — `isFilter` vs `is`

**File:** `chat_repository.dart:116`

```dart
.isFilter('read_at', null)
```

**Problem:** `.isFilter()` is an internal Supabase Dart method. The correct public API for filtering null values is `.is('column', null)`. Using `.isFilter()` here:

- May throw a runtime error if the method signature changed
- May silently not apply the filter at all, causing **all** messages (including already-read) to be updated with the current timestamp on every conversation open

**Impact:** On every chat open, ALL historical messages from friend→currentUser would be re-marked as read (with current timestamp), overwriting accurate per-message read timestamps. The "idempotent" claim in the doc comment is technically true (no crash) but the behavior is semantically wrong.

**Fix:**
```dart
// WRONG:
.isFilter('read_at', null)
// RIGHT:
.is('read_at', null)
```

**Severity:** High — data correctness bug in read tracking.

---

## 3. Medium Issues

### MEDIUM-1: `watchConversation` — expensive Supabase stream filtering

**File:** `chat_repository.dart:39-55`

```dart
.inFilter('sender_id', participants)  // participants = [currentUserId, otherUserId]
...
.where((message) =>
    (message.senderId == currentUserId && message.receiverId == otherUserId) ||
    (message.senderId == otherUserId && message.receiverId == currentUserId))
```

**Problem:** `.inFilter('sender_id', participants)` tells Supabase to broadcast ALL events where `sender_id` is EITHER currentUser OR otherUser. In a busy system with many messages between either participant and others, this creates broad unnecessary broadcasts.

The bidirectional conversation filter is done entirely in Dart — Supabase cannot optimize this at the database level.

**Impact:** Performance inefficiency on realtime events. Not a correctness bug (Dart filter is correct), but a scalability issue.

**Fix options:**
1. Keep as-is with a comment documenting the trade-off (acceptable for MVP)
2. Use a Supabase view or RPC to filter at DB level
3. Use `eq('sender_id', currentUserId).eq('receiver_id', otherUserId)` combined with a `UNION` pattern — but this doesn't work cleanly with realtime streams

**Severity:** Medium — works correctly, but inefficient under load.

---

### MEDIUM-2: No auto-scroll on incoming realtime messages

**File:** `chat_screen.dart`

**Problem:** `_scrollToBottom()` is only called after `_sendMessage()` succeeds. If a new message arrives via realtime subscription, the list view does NOT auto-scroll.

**Current behavior:**
```dart
// Only triggered on send:
await repository.sendMessage(...);
_textController.clear();
_scrollToBottom();  // ← only here
```

**Expected:** New realtime messages should also trigger scroll-to-bottom if the user is already at the bottom.

**Fix:** Add a listener on the `messagesAsync` stream state to trigger scroll when new data arrives, using a `ScrollController.position.atEdge` check to determine if user is near bottom.

**Severity:** Medium — UX degradation; not a crash.

---

### MEDIUM-3: Test coverage is minimal

**File:** `chat_screen_test.dart`

**Current tests (4):**
1. Empty state renders ✅
2. Send button present ✅
3. Input field present ✅
4. `markConversationAsRead` called on mount ✅

**Missing tests:**
- Message send interaction (tap send, message appears in list)
- Error state display when `sendMessage` throws
- Send button disabled during `_isSending` state
- Multiple messages render correctly
- "Mine" vs "theirs" bubble alignment
- Empty input → no send (send button disabled when empty)
- Unauthorized/unauthenticated redirect

**Severity:** Medium — basic rendering tested, but interaction and error paths not covered.

---

## 4. Minor Issues

### MINOR-1: `_markReadIfNeeded` guards against re-run but not against rapid calls

**File:** `chat_screen.dart:41-51`

The `_readMarked` bool prevents re-running after first call, which is correct. However, the `postFrameCallback` fires after the first frame regardless — the guard works correctly.

**Status:** Acceptable.

---

### MINOR-2: `ChatScreen` class lacks doc comments

**File:** `chat_screen.dart:17-28`

The public class has no doc comment. The frozen scope requires Tipsterino-native patterns — other screens in the repo do have doc comments. Not a functional issue, but inconsistent with documentation-as-code norms.

**Status:** Low — conventions not enforced by analyzer.

---

### MINOR-3: `ChatException.localizedKey` default case falls through to `chat_error_generic`

**File:** `chat_exception.dart`

```dart
case 'send_failed':
default:
  return 'chat_error_generic';
```

The `send_failed` code returns the same as the default. This is fine in practice but makes error differentiation impossible at the UI layer.

**Severity:** Low — all errors show generic message to user anyway.

---

## 5. What's Good

- **No Firebase/Firestore code** — clean Supabase-only implementation ✅
- **`SupabaseConfiguration` pattern** — no global singleton shortcut ✅
- **`autoDispose` on stream provider** — correct realtime lifecycle cleanup ✅
- **DB migration quality** — proper indexes, RLS policies, check constraints ✅
- **Domain model** — `@immutable`, correct `==`/`hashCode`, `@non播撒` annotations ✅
- **Auth gating** — global redirect handles it cleanly, chat not in guestAllowlist ✅
- **ColorScheme/TextTheme only** — no hardcoded colors ✅
- **Realtime subscription cleanup** — Riverpod `autoDispose` handles stream disposal ✅
- **Snake_case DB columns** — consistent with Supabase conventions ✅
- **Error handling in `_sendMessage`** — catches `ChatException`, handles generic errors ✅
- **RLS update policy** — receiver CAN update `read_at` via `(auth.uid() = receiver_id)` ✅

---

## 6. Localization Audit

| Key | EN | HU | Used in code | Type |
|---|---|---|---|---|
| `chat_title` | "Chat" | "Csevegés" | ✅ `loc.chat_title` | Screen title |
| `chat_message_hint` | "Type a message..." | "Írj üzenetet..." | ✅ hint | Input hint |
| `chat_send` | "Send" | "Küldés" | ❌ NOT USED in screen | Key exists but send button uses `Icons.send` with no label |
| `chat_empty_state` | "No messages yet" | "Még nincs üzenet" | ✅ | Empty state |
| `chat_error_empty` | "Cannot send an empty message." | "Üres üzenet nem küldhető." | ✅ | Error |
| `chat_error_too_long` | "Message is too long (max 2000 characters)." | "Az üzenet túl hosszú..." | ✅ | Error |
| `chat_error_generic` | "Failed to send message. Please try again." | "Az üzenet küldése sikertelen..." | ✅ | Error |
| `friends_open_chat` | "Open chat" | "Csevegés megnyitása" | ✅ FriendsScreen | Navigation |

**`chat_send` key is dead** — defined in ARB but never referenced in chat_screen.dart. The send button uses `Icons.send` with no text label. Either use the key or remove it.

---

## 7. Router Audit

| Check | Status |
|---|---|
| `/chat/:friendId` route exists | ✅ |
| Auth-gated (not in guestAllowlist) | ✅ |
| Uses path parameter `friendId` | ✅ |
| Graceful fallback if `friendId` is empty | ✅ (`?? ''`) |
| `createAppRouter` is a proper factory | ✅ |
| Auth redirect is correct | ✅ |

**Router comment says "Not in the guest allowlist, so unauthenticated users are redirected to /auth/login"** — this is correct but indirect. A future reader might not understand why the route is gated. Consider adding an explicit `requiresAuth: true` pattern or a more explicit comment.

---

## 8. DB Migration Audit

| Check | Status |
|---|---|
| `sender_id` references `public.profiles(id)` | ✅ |
| `receiver_id` references `public.profiles(id)` | ✅ |
| `on delete cascade` | ✅ |
| `char_length(content) <= 2000` | ✅ |
| `messages_no_self` check | ✅ |
| Index on `(sender_id, created_at desc)` | ✅ |
| Index on `(receiver_id, created_at desc)` | ✅ |
| Index on `(sender_id, receiver_id, created_at desc)` | ✅ conversation-level |
| RLS enabled | ✅ |
| Select policy: participants only | ✅ |
| Insert policy: sender only | ✅ |
| Update policy: participants can update | ✅ (receiver can update `read_at`) |
| Delete policy: participants only | ✅ |

**One note:** The composite index `messages_conversation_idx` on `(sender_id, receiver_id, created_at desc)` is not used efficiently by the current repository query (which uses `primaryKey: ['id']` stream + Dart filter). This is acceptable — the index would be useful for direct DB queries.

---

## 9. Summary Matrix

| Area | Verdict | Issues |
|---|---|---|
| Functional compliance | ✅ PASS | All frozen scope requirements met |
| Auth / routing | ✅ PASS | Correctly gated |
| DB migration | ✅ PASS | Solid RLS, constraints, indexes |
| Domain model | ✅ PASS | Immutable, correct equality |
| Repository | ✅ PASS | isFilter(null) confirmed correct; performance deferred (MEDIUM-1) |
| Presentation | ✅ FIXED | Realtime auto-scroll added (c3a5411) |
| Tests | ✅ FIXED | 9 widget + 30 unit tests (c3a5411 + b32da64) |
| Localization | ✅ PASS (minor) | `chat_send` key unused |
| No Firebase | ✅ PASS | Clean Supabase-only |
| Architecture patterns | ✅ PASS | Correct SupabaseConfiguration, autoDispose |

---

## 10. Recommended Fixes (Priority Order)

1. ~~**FIX CRITICAL-1**~~ ✅ **RETACTED** — `isFilter('read_at', null)` is the correct API (postgrest 2.6.0). Audit was wrong; no code change needed.
2. ~~**FIX MEDIUM-2**~~ ✅ **DONE** (`c3a5411`) — `ref.listen` + `NotificationListener` for realtime auto-scroll
3. ~~**FIX MEDIUM-3**~~ ✅ **DONE** (`c3a5411` + `b32da64`) — 9 widget + 30 unit tests
4. ~~**CLEANUP**~~ ✅ **DONE** (`c3a5411`) — `chat_send` dead key removed from EN/HU ARB
5. **CONSIDER MEDIUM-1** — If conversation volume is expected to be high, revisit `watchConversation` stream filtering strategy

---

## 11. DoD → Evidence

| Criterion | Evidence |
|---|---|
| Auth-gated | `app_router.dart` — chat not in guestAllowlist |
| Realtime lifecycle managed | `StreamProvider.autoDispose` in `chat_providers.dart` |
| No Firebase | No imports from `firebase_*` packages anywhere in chat/ |
| Repository uses SupabaseConfiguration | `_config.client` pattern in `chat_repository.dart` |
| DB migration present | `20260322_001151_messages_table.sql` with RLS |
| ARB keys in EN/HU | Verified in both ARB files |
| No hardcoded UI strings | All strings via `AppLocalizations.of(context)!` |
| `messages` table bounded | No follower/group chat tables |
| Rollback boundary documented | DB migration is additive only (new table, no destructive changes) |

---

**Audit complete.** The feature is functionally correct against the frozen scope with one critical bug (wrong null-filter API) and two medium issues (realtime scroll, test coverage). The architecture is sound — the issues are in the details of a specific API call and UX polish.
