import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(ref, initialState: const AuthViewState(status: AuthStatus.authenticated), autoListen: false),
      ),
      supabaseConfigProvider.overrideWithValue(
        const SupabaseConfiguration(isConfigured: false),
      ),
    ],
    child: const TipsterinoApp(),
  );
}

void main() {
  testWidgets('/events renders offline inbox content', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('/events');
    await tester.pumpAndSettle();

    expect(find.text(loc.eventsInboxTitle), findsNWidgets(1));
    expect(find.text(loc.offlineNotice), findsOneWidget);
  });
}
