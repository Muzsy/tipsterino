import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/chat/providers/chat_providers.dart';
import 'package:tipsterino/src/features/chat/data/chat_repository.dart';
import 'package:tipsterino/src/features/chat/domain/chat_message.dart';
import 'package:tipsterino/src/features/chat/domain/chat_exception.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

Session _buildTestSession(String userId) {
  return Session.fromJson({
    'access_token': 'test-token',
    'refresh_token': 'test-refresh',
    'token_type': 'bearer',
    'aud': 'authenticated',
    'user': {
      'id': userId,
      'app_metadata': <String, dynamic>{},
      'aud': 'authenticated',
      'created_at': '2024-01-01T00:00:00Z',
    },
  })!;
}

/// Configurable fake repository for testing chat screen behaviour.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    List<ChatMessage> initialMessages = const [],
    this.sendError,
    this.onSend,
  }) : _messagesController = _StreamController<List<ChatMessage>>.broadcast() {
    // Emit initial messages then allow external emission via add()
    if (initialMessages.isNotEmpty) {
      _messagesController.add(initialMessages);
    }
  }

  final _StreamController<List<ChatMessage>> _messagesController;
  final Object? sendError;
  final void Function({
    required String senderId,
    required String receiverId,
    required String content,
  })? onSend;

  final List<_SendCall> _sentMessages = [];
  List<_SendCall> get sentMessages => List.unmodifiable(_sentMessages);

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
    return _messagesController.stream;
  }

  @override
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    _sentMessages.add(_SendCall(senderId, receiverId, content));
    onSend?.call(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
    if (sendError != null) throw sendError!;

    // Simulate new message appearing in stream
    _messagesController.add([
      ChatMessage(
        id: 'msg-${_sentMessages.length}',
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        createdAt: DateTime.now(),
      ),
    ]);
  }

  void dispose() {
    _messagesController.close();
  }
}

class _SendCall {
  _SendCall(this.senderId, this.receiverId, this.content);
  final String senderId;
  final String receiverId;
  final String content;
}

Widget _buildChatScreen({
  required String friendId,
  FakeChatRepository? repository,
  String userId = 'current-user-123',
}) {
  final session = _buildTestSession(userId);
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(
          ref,
          initialState: AuthViewState(
            status: AuthStatus.authenticated,
            session: session,
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
  group('ChatScreen — rendering', () {
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
      await tester.pumpAndSettle();

      expect(fakeRepo.markConversationAsReadCalled, isTrue);
      expect(fakeRepo.lastFriendId, equals('friend-123'));
    });
  });

  group('ChatScreen — multiple messages', () {
    testWidgets('renders multiple messages from both participants', (tester) async {
      final now = DateTime.now();
      final messages = [
        ChatMessage(
          id: '1',
          senderId: 'current-user-123',
          receiverId: 'friend-456',
          content: 'Hello!',
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          id: '2',
          senderId: 'friend-456',
          receiverId: 'current-user-123',
          content: 'Hi there!',
          createdAt: now.subtract(const Duration(minutes: 1)),
        ),
        ChatMessage(
          id: '3',
          senderId: 'current-user-123',
          receiverId: 'friend-456',
          content: 'How are you?',
          createdAt: now,
        ),
      ];
      final fakeRepo = FakeChatRepository(initialMessages: messages);

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-456', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-456');
      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.text('Hi there!'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);
    });
  });

  group('ChatScreen — send interaction', () {
    testWidgets('send button is disabled when input is empty', (tester) async {
      final fakeRepo = FakeChatRepository();

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Find the send IconButton
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      // The button should be disabled (onPressed: null) when text is empty
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('send button is enabled when input has text', (tester) async {
      final fakeRepo = FakeChatRepository();

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Type some text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello friend!');
      await tester.pumpAndSettle();

      // Now the button should be enabled
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('tapping send calls repository.sendMessage', (tester) async {
      final fakeRepo = FakeChatRepository();

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Type and send
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test message');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(fakeRepo.sentMessages.length, equals(1));
      expect(fakeRepo.sentMessages[0].senderId, equals('current-user-123'));
      expect(fakeRepo.sentMessages[0].receiverId, equals('friend-123'));
      expect(fakeRepo.sentMessages[0].content, equals('Test message'));
    });

    testWidgets('send button shows loading indicator while sending', (tester) async {
      bool sendBlocked = true;
      final fakeRepo = FakeChatRepository(
        onSend: ({senderId, receiverId, content}) async {
          // Block briefly to observe loading state
          await Future.delayed(const Duration(milliseconds: 200));
        },
      );

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Type text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Loading test');
      await tester.pumpAndSettle();

      // Start send (blocked)
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // immediately after tap

      // Should show CircularProgressIndicator instead of send icon
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for send to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Send icon should be back
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows error snackbar when sendMessage throws ChatException',
        (tester) async {
      final fakeRepo = FakeChatRepository(
        sendError: const ChatException('too_long'),
      );

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Type and send
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'x' * 2001);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.chat_error_too_long), findsOneWidget);
    });

    testWidgets('shows generic error snackbar on unknown exception',
        (tester) async {
      final fakeRepo = FakeChatRepository(
        sendError: Exception('network failure'),
      );

      await tester.pumpWidget(
        _buildChatScreen(friendId: 'friend-123', repository: fakeRepo),
      );
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.chat_error_generic), findsOneWidget);
    });
  });
}
