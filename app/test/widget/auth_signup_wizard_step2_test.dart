import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';

void main() {
  testWidgets('Step 2 enables Next only when nickname is available',
      (tester) async {
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

    await tester.enterText(
      find.widgetWithText(TextField, 'Email address'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Aa1!aaaa',
    );
    await tester.pumpAndSettle();

    final nextButton = find.widgetWithText(ElevatedButton, 'Next');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Step 2 – Profile'), findsWidgets);
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nickname'),
      'hero123',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Nickname available'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNotNull);
  });
}
