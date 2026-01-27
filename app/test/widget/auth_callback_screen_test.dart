import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_callback_provider.dart';

void main() {
  testWidgets('success state surfaces continue CTA', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authCallbackHandlerProvider.overrideWithValue(
            (_) async =>
                const AuthCallbackHandlerResult(AuthCallbackOutcome.success),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthCallbackScreen(
            uri: Uri.parse('io.tipsterino://auth-callback/auth/callback'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(loc.auth_callback_success), findsOneWidget);
    expect(find.text(loc.auth_callback_continue), findsOneWidget);
  });

  testWidgets('expired state shows login and resend actions', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authCallbackHandlerProvider.overrideWithValue(
            (_) async =>
                const AuthCallbackHandlerResult(AuthCallbackOutcome.expired),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthCallbackScreen(
            uri: Uri.parse(
              'io.tipsterino://auth-callback/auth/callback?email=test@example.com',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(loc.auth_callback_expired), findsOneWidget);
    expect(find.text(loc.auth_callback_back_to_login), findsOneWidget);
    expect(find.text(loc.auth_callback_resend), findsOneWidget);
  });
}
