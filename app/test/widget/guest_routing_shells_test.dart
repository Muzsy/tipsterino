import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';

Widget _buildApp({required AuthViewState state}) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(ref, initialState: state, autoListen: false),
      ),
      supabaseConfigProvider.overrideWithValue(
        const SupabaseConfiguration(isConfigured: false),
      ),
    ],
    child: const TipsterinoApp(),
  );
}

void main() {
  testWidgets('Guest settings route redirects to login', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _buildApp(state: const AuthViewState(status: AuthStatus.unauthenticated)),
    );

    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('/settings');
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ElevatedButton, loc.logInButton),
      findsOneWidget,
    );
  });

  testWidgets('Guest bottom nav shows Home-Bets-Forum', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _buildApp(state: const AuthViewState(status: AuthStatus.offline)),
    );

    await tester.pumpAndSettle();
    expect(find.text(loc.homeTab), findsWidgets);
    expect(find.text(loc.betsTab), findsOneWidget);
    expect(find.text(loc.forumTab), findsOneWidget);
  });

  testWidgets('Auth bottom nav shows Home-Profile-Settings', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _buildApp(state: const AuthViewState(status: AuthStatus.authenticated)),
    );

    await tester.pumpAndSettle();
    expect(find.text(loc.homeTab), findsWidgets);
    expect(find.text(loc.profileTab), findsOneWidget);
    expect(find.text(loc.settingsTab), findsOneWidget);
  });
}
