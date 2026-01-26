import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';

void main() {
  testWidgets('Step 1 Next button enables after email+password rules', (
    tester,
  ) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: true),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignUpWizardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nextButtonFinder = find.widgetWithText(
      ElevatedButton,
      loc.common_next,
    );
    expect(nextButtonFinder, findsOneWidget);
    var nextButton = tester.widget<ElevatedButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(1), 'Abcd!efg');
    await tester.pumpAndSettle();

    expect(find.text(loc.auth_password_rule_min_length), findsNothing);
    expect(find.text(loc.auth_password_rule_uppercase), findsNothing);
    expect(find.text(loc.auth_password_rule_lowercase), findsNothing);
    expect(find.text(loc.auth_password_rule_special), findsNothing);

    nextButton = tester.widget<ElevatedButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNotNull);
  });
}
