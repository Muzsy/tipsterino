# Run Prompt: Friends Feature Migration

**Task slug:** `friends_feature_migration`  
**Runtime:** agent=tipmig | tipsterino workspace

---

## Pre-Read (done — do not re-read unless asked)

All required reading has been completed before this prompt was issued. The agent has established:

1. Tipsterino profile contract: `id`, `nickname`, `avatar_key` (from `public_profiles` view)
2. No `avatar_url` or `score` fields in Tipsterino
3. Supabase config via `supabaseConfigProvider` / `SupabaseConfiguration`
4. Auth via `authNotifierProvider` (session?.user.id)
5. Chat repository pattern as reference for Supabase integration
6. TippmixApp friends feature as adaptation source (notifications removed, profile contract adapted)
7. DB migration: `20260322_001151_messages_table.sql` as naming reference
8. Localization: ARB files at `app/lib/l10n/app_en.arb` and `app/lib/l10n/app_hu.arb`

---

## Mission Summary

Implement the bounded friends feature in Tipsterino:

1. **DB**: `friends` table (bilateral, statuses: pending/accepted/rejected, RLS, canonical pair uniqueness)
2. **Domain**: FriendStatus, FriendProfile, FriendSearchResult, Friendship, FriendOperationException
3. **Data**: FriendsRepository (Tipsterino SupabaseConfiguration pattern, no notifications)
4. **Providers**: acceptedFriendsProvider, incomingRequestsProvider, searchQueryProvider, searchResultsProvider
5. **Presentation**: FriendsScreen + 3 widgets (Material 3, AppLocalizations, ColorScheme)
6. **Routing**: `/friends` auth-gated route + ProfileScreen entry point + deep-link to `/chat/:friendId`
7. **L10n**: Full EN/HU ARB keys
8. **Test**: Widget test

---

## Execution

Follow the goal YAML steps in order. For each step:
- Use only actual files/paths that exist in the repo
- Adapt TippmixApp patterns to Tipsterino contracts
- No Firebase/Firestore, no notifications, no AppError/AppErrorMapper
- All UI via AppLocalizations, ColorScheme, TextTheme

After all implementation steps, run the repo gate:
```
./scripts/verify.sh --report codex/reports/migration/friends_feature_migration.md
```

---

## Expected Output Files

All files listed in the goal YAML `outputs` fields. Key files:

- `supabase/migrations/20260322_132100_friends_table.sql`
- `app/lib/src/features/friends/domain/*.dart` (5 files)
- `app/lib/src/features/friends/data/friends_repository.dart`
- `app/lib/src/features/friends/providers/friends_providers.dart`
- `app/lib/src/features/friends/presentation/screens/friends_screen.dart`
- `app/lib/src/features/friends/presentation/widgets/*.dart` (3 files)
- `app/lib/src/app/router/app_router.dart` (modified)
- `app/lib/src/features/profile/presentation/screens/profile_screen.dart` (modified)
- `app/lib/l10n/app_en.arb` (modified)
- `app/lib/l10n/app_hu.arb` (modified)
- `app/test/widgets/friends_screen_test.dart`
- `canvases/friends_feature_migration.md`
- `codex/goals/canvases/fill_canvas_friends_feature_migration.yaml`
- `codex/prompts/migration/friends_feature_migration/run.md`
- `codex/codex_checklist/migration/friends_feature_migration.md`
- `codex/reports/migration/friends_feature_migration.md`

---

## Status Contract

Print ONLY at the end:

```
STATUS: <PASS | FAIL | PASS_WITH_NOTES>
REPORT: codex/reports/migration/friends_feature_migration.md
NEXT_TASK: <slug>
```
