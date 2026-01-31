import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/app/router/app_router.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_callback_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';

const _registerTitle = 'Register';
const _emailLabel = 'Email address';
const _passwordLabel = 'Password';
const _commonNext = 'Next';
const _nicknameLabel = 'Nickname';
const _consentTermsLabel = 'I agree to the Terms of Service';
const _consentPrivacyLabel = 'I agree to the Data Processing Policy';
const _signupSubmit = 'Create account';
const _verifyPendingTitle = 'Verify your email';
const _verifyPendingResend = 'Resend verification';
const _verifyPendingResent = 'Verification email resent';
const _callbackSuccess = 'Authentication succeeded!';
const _callbackContinue = 'Continue';
const _homeTab = 'Home';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Registration v2 full deterministic flow', (tester) async {

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
          appLocaleProvider.overrideWithValue(const Locale('en')),
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
    expect(find.text(_registerTitle), findsOneWidget);

    await tester.enterText(
      _textFieldByLabel(_emailLabel),
      'qa+e2e@example.com',
    );
    await tester.enterText(
      _textFieldByLabel(_passwordLabel),
      'ValidP@ss1',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, _commonNext));
    await tester.pumpAndSettle();

    await tester.enterText(
      _textFieldByLabel(_nicknameLabel),
      'qa_tester',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, _commonNext));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, _consentTermsLabel));
    await tester.tap(find.widgetWithText(CheckboxListTile, _consentPrivacyLabel));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, _signupSubmit));
    await tester.pumpAndSettle();

    expect(find.text(_verifyPendingTitle), findsWidgets);
    final resendButton = find.widgetWithText(ElevatedButton, _verifyPendingResend);
    expect(resendButton, findsOneWidget);
    await tester.tap(resendButton);
    await tester.pumpAndSettle();
    expect(find.text(_verifyPendingResent), findsOneWidget);

    router.go('/auth/callback?email=qa%40example.com');
    await tester.pumpAndSettle();

    expect(find.text(_callbackSuccess), findsOneWidget);
    final continueButton = find.widgetWithText(ElevatedButton, _callbackContinue);
    expect(continueButton, findsOneWidget);
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    router.go('/home');
    await tester.pumpAndSettle();

    expect(find.text(_homeTab), findsWidgets);
  });
}

Finder _textFieldByLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
    description: 'TextField with label "$label"',
  );
}
