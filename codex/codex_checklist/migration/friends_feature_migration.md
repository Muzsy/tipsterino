# Checklist: Friends Feature Migration

**Task slug:** `friends_feature_migration`  
**Target:** Tipsterino bounded friends feature  
**Status:** IN PROGRESS

---

## Phase 1 — Control Pack Created
- [x] Canvas: `canvases/friends_feature_migration.md`
- [x] Goal YAML: `codex/goals/canvases/fill_canvas_friends_feature_migration.yaml`
- [x] Run Prompt: `codex/prompts/migration/friends_feature_migration/run.md`
- [ ] Checklist: this file (fills on completion)
- [ ] Report: `codex/reports/migration/friends_feature_migration.md` (fills on verify)

## Phase 2 — DB Migration
- [ ] `supabase/migrations/20260322_132100_friends_table.sql` created
- [ ] `friends` table with bilateral relationship model
- [ ] statuses: `pending | accepted | rejected`
- [ ] no self-relationship (`friends_no_self` check)
- [ ] canonical pair uniqueness (`friends_user_friend_unique` constraint)
- [ ] RLS: select/update/delete for participants only
- [ ] Insert restricted to requester identity only
- [ ] No `followers` or `friend_requests` tables

## Phase 3 — Domain / Data / Providers
- [ ] `friend_status.dart`: FriendStatus enum with value/fromString
- [ ] `friend_profile.dart`: using Tipsterino `id`, `nickname`, `avatar_key` (NO avatar_url, NO score)
- [ ] `friend_search_result.dart`: FriendSearchResult model
- [ ] `friendship.dart`: Friendship model with profile + status
- [ ] `friend_operation_exception.dart`: narrow exception, ChatException-style
- [ ] `friends_repository.dart`: FriendsRepository with SupabaseConfiguration (no global singleton)
- [ ] Repository: watchAcceptedFriends, watchPendingRequests, searchProfiles, sendRequest, acceptRequest, declineRequest, removeFriendship
- [ ] NO notification service calls in repository
- [ ] `friends_providers.dart`: acceptedFriendsProvider, incomingRequestsProvider, searchQueryProvider, searchResultsProvider
- [ ] autoDispose pattern matches chat_providers.dart

## Phase 4 — Presentation
- [ ] `friends_screen.dart`: Material 3, AppLocalizations, ColorScheme, search input, 3 sections, empty states, loading, error states
- [ ] `friend_list_item.dart`: accepted friend row with chat + remove actions
- [ ] `friend_request_item.dart`: incoming request with accept/decline buttons
- [ ] `friend_search_result_item.dart`: search result with send request / status / chat
- [ ] No hardcoded colors (ColorScheme only)
- [ ] No network image / avatar URL system (initials fallback)

## Phase 5 — Routing / Navigation
- [ ] `/friends` GoRoute registered in `app_router.dart` (NOT in ShellRoute, NOT in guestAllowlist)
- [ ] Auth-gating automatic via existing redirect logic
- [ ] ProfileScreen has minimal entry to `/friends`
- [ ] Accepted friend rows deep-link to `/chat/:friendId`

## Phase 6 — Localization
- [ ] All UI strings use AppLocalizations
- [ ] EN keys in `app_en.arb`
- [ ] HU keys in `app_hu.arb`
- [ ] No hardcoded strings in friends feature code

## Phase 7 — Testing
- [ ] `friends_screen_test.dart` exists
- [ ] Test: FriendsScreen renders with AppBar
- [ ] Test: authenticated route access
- [ ] Test: empty state visible
- [ ] Test: chat action visible on friend row

## Phase 8 — Verification
- [ ] `./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md` run
- [ ] No Firebase/Firestore imports
- [ ] No `avatar_url` / `score` invented
- [ ] Schema bounded (no legacy social tables)
- [ ] Flutter SDK availability documented (PASS_WITH_NOTES if unavailable)

---

## Evidence Summary

| Created File | Evidence |
|-------------|----------|
| (fill after implementation) | |
