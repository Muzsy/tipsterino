import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

Widget _buildChatScreen({required String friendId}) {
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

      // Navigate to chat screen
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/chat/friend-123');
      await tester.pumpAndSettle();

      // Title visible
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

      // Send button (Icon) should be present
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

      // Message input hint should be visible
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.chat_message_hint), findsOneWidget);
    });
  });
}
