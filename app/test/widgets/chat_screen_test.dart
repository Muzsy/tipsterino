import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/chat/providers/chat_providers.dart';
import 'package:tipsterino/src/features/chat/data/chat_repository.dart';
import 'package:tipsterino/src/features/chat/domain/chat_message.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

/// A fake ChatRepository that records whether markConversationAsRead was called.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository();

  bool markConversationAsReadCalled = false;
  String? lastCurrentUserId;
  String? lastFriendId;

  @override
  Future<void> markConversationAsRead({
    required String currentUserId,
    required String friendId,
  }) async {
    markConversationAsReadCalled = true;
    lastCurrentUserId = currentUserId;
    lastFriendId = friendId;
  }

  @override
  Stream<List<ChatMessage>> watchConversation({
    required String currentUserId,
    required String otherUserId,
  }) {
    return Stream.value(const <ChatMessage>[]);
  }

  @override
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {}
}

Widget _buildChatScreen({required String friendId, ChatRepository? repository}) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(
          ref,
          initialState: const AuthViewState(
            status: AuthStatus.authenticated,
          ),
          autoListen: false,
        ),
      ),
      if (repository != null)
        chatRepositoryProvider.overrideWithValue(repository),
      supabaseConfigProvider.overrideWithValue(
        const SupabaseConfiguration(isConfigured: false),
      ),
    ],
    child: const TipsterinoApp(),
  );
}

void main() {
  group('ChatScreen', () {
    testWidgets('renders empty state when no messages', (tester) async {
      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123'),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('shows send button', (tester) async {
      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123'),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('input field is present', (tester) async {
      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123'),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.chat_message_hint), findsOneWidget);
    });

    testWidgets('calls markConversationAsRead on screen mount', (tester) async {
      final fakeRepo = FakeChatRepository();

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Give the post-frame callback a chance to fire
      await tester.pumpAndSettle();

      expect(fakeRepo.markConversationAsReadCalled, isTrue);
      expect(fakeRepo.lastFriendId, equals('friend-123'));
    });
  });
}
