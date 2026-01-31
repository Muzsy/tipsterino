import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/app/router/app_router.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_callback_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Registration v2 full deterministic flow', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            (ref) => AuthNotifier(
              ref,
              initialState: const AuthViewState(status: AuthStatus.unauthenticated),
              autoListen: false,
            ),
          ),
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
          nicknameAvailabilityCheckerProvider.overrideWithValue(
            (_) async => true,
          ),
          signupSubmitterProvider.overrideWithValue(
            ({
              required String email,
              required String password,
              required String nickname,
              required String avatarKey,
            }) async {},
          ),
          verifyEmailPendingResenderProvider.overrideWithValue(
            ({required String email}) async {},
          ),
          verifyEmailPendingCooldownProvider.overrideWithValue(0),
          authCallbackHandlerProvider.overrideWith(
            (_) => (uri) async {
              if (uri.queryParameters['expired'] == 'true') {
                return AuthCallbackHandlerResult(
                  AuthCallbackOutcome.expired,
                  message: 'expired',
                );
              }
              return const AuthCallbackHandlerResult(AuthCallbackOutcome.success);
            },
          ),
          goRouterProvider.overrideWith(
            (ref) => createAppRouter(
              ref,
              initialLocation: '/auth/register',
            ),
          ),
        ],
        child: const TipsterinoApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    final routerContext = tester.element(find.byType(Scaffold).first);
    final router = GoRouter.of(routerContext);
    expect(find.text(loc.registerTitle), findsOneWidget);

    await tester.enterText(
      _textFieldByLabel(loc.emailLabel),
      'qa+e2e@example.com',
    );
    await tester.enterText(
      _textFieldByLabel(loc.passwordLabel),
      'ValidP@ss1',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, loc.common_next));
    await tester.pumpAndSettle();

    await tester.enterText(
      _textFieldByLabel(loc.auth_nickname_label),
      'qa_tester',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, loc.common_next));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, loc.auth_consent_terms_label));
    await tester.tap(find.widgetWithText(CheckboxListTile, loc.auth_consent_privacy_label));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, loc.auth_signup_submit));
    await tester.pumpAndSettle();

    expect(find.text(loc.auth_verify_pending_title), findsOneWidget);
    final resendButton = find.widgetWithText(ElevatedButton, loc.auth_verify_pending_resend);
    expect(resendButton, findsOneWidget);
    await tester.tap(resendButton);
    await tester.pumpAndSettle();
    expect(find.text(loc.auth_verify_pending_resend_sent), findsOneWidget);

    router.go('/auth/callback?email=qa%40example.com');
    await tester.pumpAndSettle();

    expect(find.text(loc.auth_callback_success), findsOneWidget);
    final continueButton = find.widgetWithText(ElevatedButton, loc.auth_callback_continue);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text(loc.homeTab), findsWidgets);
  });
}

Finder _textFieldByLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
    description: 'TextField with label "$label"',
  );
}
