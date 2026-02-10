import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/verify_email_pending_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_callback_provider.dart';

void main() {
  testWidgets('Verify pending resend throttles and shows feedback', (
    tester,
  ) async {
    int resendCalls = 0;
    final successCompleter = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
          verifyEmailPendingResenderProvider.overrideWithValue(({
            required String email,
          }) async {
            resendCalls++;
            if (resendCalls == 1) {
              throw Exception('resend failed');
            }
            await successCompleter.future;
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

    expect(resendCalls, 1);
    expect(find.text('Exception: resend failed'), findsOneWidget);

    await tester.tap(resendButton);
    await tester.pump();

    expect(resendCalls, 2);
    expect(find.text('Exception: resend failed'), findsNothing);

    successCompleter.complete();
    await tester.pump();
    await tester.pumpAndSettle();

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
      initialLocation: '/auth/callback?error=expired&email=test%40example.com',
      routes: [
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => AuthCallbackScreen(uri: state.uri),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authCallbackHandlerProvider.overrideWithValue(
            (_) async =>
                const AuthCallbackHandlerResult(AuthCallbackOutcome.expired),
          ),
        ],
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

    expect(find.text(loc.auth_callback_expired), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, loc.auth_callback_back_to_login),
      findsOneWidget,
    );
    expect(find.text(loc.auth_callback_resend), findsOneWidget);
  });
}
