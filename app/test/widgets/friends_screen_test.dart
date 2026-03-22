import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

Widget _buildFriendsScreen() {
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
  group('FriendsScreen', () {
    testWidgets('renders with AppBar title', (tester) async {
      await tester.pumpWidget(_buildFriendsScreen());
      await tester.pumpAndSettle();

      // Navigate to friends screen.
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/friends');
      await tester.pumpAndSettle();

      // AppBar title should be present.
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('shows search input field', (tester) async {
      await tester.pumpWidget(_buildFriendsScreen());
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/friends');
      await tester.pumpAndSettle();

      // Search TextField should be present.
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.friends_search_placeholder), findsOneWidget);
    });

    testWidgets('shows empty state for accepted friends section',
        (tester) async {
      await tester.pumpWidget(_buildFriendsScreen());
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/friends');
      await tester.pumpAndSettle();

      // Empty state message should be visible (since no friends loaded).
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.friends_empty_state), findsOneWidget);
    });

    testWidgets('shows incoming requests section header', (tester) async {
      await tester.pumpWidget(_buildFriendsScreen());
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/friends');
      await tester.pumpAndSettle();

      // Requests section header should be present.
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.friends_requests_title), findsOneWidget);
    });

    testWidgets('shows friends section header', (tester) async {
      await tester.pumpWidget(_buildFriendsScreen());
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/friends');
      await tester.pumpAndSettle();

      // Friends section header should be present.
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(loc.friends_section_friends), findsOneWidget);
    });
  });
}
