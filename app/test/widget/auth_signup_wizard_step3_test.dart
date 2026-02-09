import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/verify_email_pending_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/sign_up_wizard_step3.dart';

void main() {
  testWidgets('Step 3 submits only with consents and navigates', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/auth/register',
      routes: [
        GoRoute(
          path: '/auth/register',
          builder: (context, _) => const SignUpWizardScreen(),
        ),
        GoRoute(
          path: '/auth/verify-pending',
          builder: (_, state) => VerifyEmailPendingScreen(
            email: state.uri.queryParameters['email'] ?? '',
          ),
        ),
      ],
    );

    bool submitCalled = false;
    Map<String, String>? submittedData;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
          nicknameAvailabilityCheckerProvider.overrideWithValue(
            (_) async => true,
          ),
          signupSubmitterProvider.overrideWithValue(({
            required String email,
            required String password,
            required String nickname,
            required String avatarKey,
          }) async {
            submitCalled = true;
            submittedData = {
              'email': email,
              'password': password,
              'nickname': nickname,
              'avatarKey': avatarKey,
            };
          }),
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
      tester.element(find.byType(SignUpWizardScreen)),
    )!;

    await tester.enterText(
      find.widgetWithText(TextField, loc.emailLabel),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, loc.passwordLabel),
      'Aa1!aaaa',
    );
    await tester.pumpAndSettle();

    final nextButton = find.widgetWithText(ElevatedButton, loc.common_next);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, loc.auth_nickname_label),
      'hero123',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpWizardStep3), findsOneWidget);

    final submitButton = find.widgetWithText(
      ElevatedButton,
      loc.auth_signup_submit,
    );
    expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNull);

    final checkboxes = find.byType(CheckboxListTile);
    expect(checkboxes, findsNWidgets(2));
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNull);

    await tester.tap(checkboxes.last);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNotNull);

    await tester.tap(submitButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(submitCalled, isTrue);
    expect(submittedData, isNotNull);
    expect(submittedData!['nickname'], 'hero123');
    expect(find.text(loc.auth_verify_pending_title), findsWidgets);
  });
}
