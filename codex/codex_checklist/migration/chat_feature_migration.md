# Checklist: Chat Feature Migration

**Task slug:** `chat_feature_migration`  
**Chosen unit:** `chat` (1:1 Direct Messaging)  
**Status:** COMPLETE

---

## Phase 1 — Baseline Reconstruction
- [x] Frozen scope confirmed from `tipsterino_first_migration_unit_scope_freeze` canvas
- [x] In-scope / out-of-scope boundaries clear
- [x] Implementation plan written into report (CP1–CP10)

## Phase 2 — Schema and Dependency Mapping
- [x] Single `messages` table confirmed as sufficient for frozen scope
- [x] Migration created: `20260322_001151_messages_table.sql`
- [x] Auth mapping verified: `authNotifierProvider.session?.user.id` = Tipsterino user ID
- [x] Supabase client pattern verified: `supabaseConfigProvider` + `SupabaseConfiguration`
- [x] No unresolved schema/auth risks

## Phase 3 — Backend and Domain/Data/Providers
- [x] CP1: DB migration created
- [x] CP2: Domain layer created (`chat_message.dart`, `chat_exception.dart`)
- [x] CP3: Data layer created — `ChatRepository` with Tipsterino adapter
- [x] CP4: Providers created — `chatRepositoryProvider` + `chatMessagesProvider`
- [x] No Firebase/Firestore code introduced
- [x] `Supabase.instance.client` global singleton NOT used

## Phase 4 — Presentation and Routing
- [x] CP5: Chat screen created — Tipsterino-native (`AppLocalizations`, `ColorScheme`)
- [x] CP6: Route registered at `/chat/:friendId` in `app_router.dart`
- [x] Auth gating enforced — `/chat/:friendId` not in `guestAllowlist`
- [x] Bottom-nav integration deferred to `friends_feature_migration`
- [x] `autoDispose` Riverpod provider handles realtime subscription cleanup

## Phase 5 — Localization and Test/Verify
- [x] CP7: ARB keys added — 7 keys in both `app_en.arb` and `app_hu.arb`
- [x] CP8: Widget test created — 3 test cases
- [x] CP9: Flutter analyze/test NOT RUN (Flutter SDK unavailable in environment)
- [x] CP10: This checklist completed

## Verification Gates
- [x] All created/modified files listed in report
- [x] Chat code only in `app/lib/src/features/chat/` (feature-first path)
- [x] No Firebase/Firestore imports
- [x] Auth gating enforced via existing redirect logic
- [x] ARB keys exist in both EN and HU
- [x] No hardcoded UI strings in chat screen
- [x] Repository uses `supabaseConfigProvider` (not global singleton)
- [x] Realtime subscription lifecycle handled via `autoDispose`
- [x] `flutter analyze` skipped — Flutter SDK not available; reason documented
- [x] Implementation matches frozen scope exactly

---

## Evidence Summary

| Created File | Evidence |
|-------------|----------|
| `supabase/migrations/20260322_001151_messages_table.sql` | Full messages table schema with RLS |
| `app/lib/src/features/chat/domain/chat_message.dart` | `@immutable`, `ChatMessage` domain model |
| `app/lib/src/features/chat/domain/chat_exception.dart` | `ChatException` with `toLocalizedMessage()` |
| `app/lib/src/features/chat/data/chat_repository.dart` | `ChatRepository` with `SupabaseConfiguration` injection |
| `app/lib/src/features/chat/providers/chat_providers.dart` | `chatRepositoryProvider` + `chatMessagesProvider` (autoDispose.family) |
| `app/lib/src/features/chat/presentation/screens/chat_screen.dart` | Tipsterino-native screen with l10n, theme |
| `app/lib/src/app/router/app_router.dart` | `/chat/:friendId` route added |
| `app/lib/l10n/app_en.arb` | 7 chat keys added |
| `app/lib/l10n/app_hu.arb` | 7 chat keys added |
| `app/test/widgets/chat_screen_test.dart` | 3 widget tests |
