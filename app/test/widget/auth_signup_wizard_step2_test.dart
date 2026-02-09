import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/sign_up_wizard_step2.dart';

void main() {
  testWidgets('Step 2 enables Next only when nickname is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
          nicknameAvailabilityCheckerProvider.overrideWithValue(
            (_) async => true,
          ),
        ],
        child: MaterialApp(
          home: const SignUpWizardScreen(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();
    final loc = await AppLocalizations.delegate.load(const Locale('en'));

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
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.byType(SignUpWizardStep2), findsOneWidget);
    expect(find.text(loc.auth_signup_step_profile), findsWidgets);
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, loc.auth_nickname_label),
      'hero123',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text(loc.auth_nickname_available), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNotNull);
  });
}
