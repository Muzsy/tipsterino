# Canvas: Friends Feature Migration

**Task slug:** `friends_feature_migration`  
**Target:** Tipsterino (app/) — bounded friends feature  
**Source/reference:** TippmixApp friends feature (adapted, not copied)  
**Status:** IN PROGRESS

---

## 🎯 Feature Goal

Implement a bounded, auth-gated friends feature in Tipsterino providing:
- accepted friends list
- incoming pending friend requests
- nickname-based public profile search
- send / accept / decline / remove friendship flows
- deep-link from accepted friends into `/chat/:friendId`
- minimal entry point from ProfileScreen

**This is NOT a broader social system.** Followers, public profiles, notifications, leaderboards, and club chat are explicitly out.

---

## 🚫 Non-Goals (explicit out-of-scope)

- Followers system
- `friend_requests` separate table
- Push notifications / notification service migration
- Public profile page
- Score / leaderboard enrichment
- Avatar URL/network image system from TippmixApp
- Club chat / group chat
- `read_at` update in chat when opening conversation
- Message unread counters
- Blocking / muting / reporting users
- Social feed redesign
- Bottom-nav friends tab
- Advanced debounce/search analytics/pagination

---

## 📁 Affected Files (control-pack outputs)

### DB Migration
- `supabase/migrations/<timestamp>_friends_table.sql`

### Domain Layer
- `app/lib/src/features/friends/domain/friend_status.dart`
- `app/lib/src/features/friends/domain/friend_profile.dart`
- `app/lib/src/features/friends/domain/friend_search_result.dart`
- `app/lib/src/features/friends/domain/friendship.dart`
- `app/lib/src/features/friends/domain/friend_operation_exception.dart`

### Data Layer
- `app/lib/src/features/friends/data/friends_repository.dart`

### Providers
- `app/lib/src/features/friends/providers/friends_providers.dart`

### Presentation
- `app/lib/src/features/friends/presentation/screens/friends_screen.dart`
- `app/lib/src/features/friends/presentation/widgets/friend_list_item.dart`
- `app/lib/src/features/friends/presentation/widgets/friend_request_item.dart`
- `app/lib/src/features/friends/presentation/widgets/friend_search_result_item.dart`

### Routing / Navigation
- `app/lib/src/app/router/app_router.dart` (add `/friends` route)
- `app/lib/src/features/profile/presentation/screens/profile_screen.dart` (add entry point)

### Localization
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`

### Testing
- `app/test/widgets/friends_screen_test.dart`

### Control Pack
- `canvases/friends_feature_migration.md` (this file)
- `codex/goals/canvases/fill_canvas_friends_feature_migration.yaml`
- `codex/prompts/migration/friends_feature_migration/run.md`
- `codex/codex_checklist/migration/friends_feature_migration.md`
- `codex/reports/migration/friends_feature_migration.md`

---

## 🔑 Key Adaptation Decisions (mandatory)

1. **Tipsterino profile contract only**: `id`, `nickname`, `avatar_key`. No `avatar_url` or `score`.
2. **No notification side-effects**: remove all TippmixApp `NotificationService` calls.
3. **No legacy schema replay**: create the final clean `friends` table directly.
4. **No global Supabase singleton**: use `supabaseConfigProvider` / `SupabaseConfiguration` pattern.
5. **No AppError/AppErrorMapper**: use a narrow `FriendOperationException` similar to `ChatException`.
6. **No deprecated filter APIs**: use the same Supabase PostgREST API style proven in the chat migration.
7. **No avatar URL system**: use initials-based fallback (no network image assets).

---

## 📋 Checklist / DoD

### DB & Schema
- [ ] `friends` table with bilateral relationship model
- [ ] statuses: `pending | accepted | rejected`
- [ ] no self-relationship (`friends_no_self` check)
- [ ] canonical pair uniqueness (`friends_user_friend_unique` constraint)
- [ ] RLS: select/update/delete for participants only
- [ ] Insert restricted to requester identity only
- [ ] No `followers` or `friend_requests` tables

### Domain / Data / Providers
- [ ] `FriendStatus` enum with `value` and `fromString`
- [ ] `FriendProfile` using Tipsterino profile fields (`id`, `nickname`, `avatar_key`)
- [ ] `FriendSearchResult` model
- [ ] `Friendship` model with profile + status
- [ ] `FriendOperationException` (narrow, ChatException-style)
- [ ] `FriendsRepository` using `SupabaseConfiguration` (no global singleton)
- [ ] Repository methods: watchAcceptedFriends, watchPendingRequests, searchProfiles, sendRequest, acceptRequest, declineRequest, removeFriendship
- [ ] Riverpod providers: acceptedFriendsProvider, incomingRequestsProvider, searchQueryProvider, searchResultsProvider

### Presentation
- [ ] `FriendsScreen` — Material 3, AppLocalizations, ColorScheme
- [ ] Search input (min 2 chars, debounced)
- [ ] Incoming requests section (accept/decline buttons)
- [ ] Accepted friends section (list with chat action)
- [ ] Empty states for all three sections
- [ ] Loading and error states
- [ ] `FriendListItem` widget
- [ ] `FriendRequestItem` widget
- [ ] `FriendSearchResultItem` widget

### Routing / Navigation
- [ ] `/friends` route registered (auth-gated — not in guestAllowlist)
- [ ] Minimal entry from `ProfileScreen` (button or list tile)
- [ ] Accepted friend items deep-link to `/chat/:friendId`

### Localization
- [ ] All UI strings in EN+HU ARB
- [ ] No hardcoded strings in friends feature

### Testing
- [ ] Widget test: friends screen renders
- [ ] Widget test: authenticated route access
- [ ] Widget test: at least one core interaction

### Verification
- [ ] Repo gate via `./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md`
- [ ] No Firebase/Firestore imports
- [ ] No `avatar_url` / `score` invented
- [ ] `friends` schema bounded

---

## 🔄 Rollback Notes

If the migration must be rolled back:
1. Drop the `friends` table migration file (keep for potential re-apply)
2. Remove all `app/lib/src/features/friends/` files
3. Remove `/friends` route from `app_router.dart`
4. Revert `profile_screen.dart` to previous state
5. Remove friends-related keys from ARB files
6. Remove test file

---

## 🔍 Verification Expectations

- `./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md`
- If Flutter SDK is unavailable, document the blocker and use `PASS_WITH_NOTES`
- Do NOT fake a green result if tooling is missing

---

## 📌 Context: Deferred Chat Items

This task makes `/chat/:friendId` reachable from the friends list. The following chat deferred items remain for later tasks:
- `read_at` update on conversation open
- broader chat deep-link polish outside friends/profile context
