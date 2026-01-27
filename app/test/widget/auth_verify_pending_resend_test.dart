import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/verify_email_pending_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';

void main() {
  testWidgets('Verify pending resend throttles and shows feedback', (
    tester,
  ) async {
    bool resendCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
          verifyEmailPendingResenderProvider.overrideWithValue(({
            required String email,
          }) async {
            resendCalled = true;
          }),
          verifyEmailPendingCooldownProvider.overrideWithValue(1),
        ],
        child: MaterialApp(
          home: const VerifyEmailPendingScreen(email: 'noreply@example.com'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();
    final loc = AppLocalizations.of(
      tester.element(find.byType(VerifyEmailPendingScreen)),
    )!;

    final resendButton = find.widgetWithText(
      ElevatedButton,
      loc.auth_verify_pending_resend,
    );
    expect(resendButton, findsOneWidget);

    await tester.tap(resendButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(resendCalled, isTrue);
    expect(find.text(loc.auth_verify_pending_resend_sent), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text(loc.auth_verify_pending_resend_cooldown(1)),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(
              ElevatedButton,
              loc.auth_verify_pending_resend_cooldown(1),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(loc.auth_verify_pending_resend), findsWidgets);
  });

  testWidgets('Auth callback route handles errors gracefully', (tester) async {
    final router = GoRouter(
      initialLocation: '/auth/callback?error=expired',
      routes: [
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) =>
              AuthCallbackScreen(error: state.uri.queryParameters['error']),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();
    final loc = AppLocalizations.of(
      tester.element(find.byType(AuthCallbackScreen)),
    )!;

    expect(find.text(loc.auth_callback_error('expired')), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, loc.auth_callback_back_to_login),
      findsOneWidget,
    );
  });
}
