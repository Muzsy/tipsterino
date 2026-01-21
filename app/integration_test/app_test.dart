import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tipsterino/main.dart' as app;
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Launch handles offline and configured flows', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    final loc = AppLocalizations.of(context)!;

    final loginButtonFinder = find.widgetWithText(
      ElevatedButton,
      loc.logInButton,
    );
    final offlineNoticeFinder = find.text(loc.offlineNotice);

    if (offlineNoticeFinder.evaluate().isNotEmpty) {
      expect(loginButtonFinder, findsOneWidget);
      final loginButtonWidget = tester.widget<ElevatedButton>(
        loginButtonFinder,
      );
      expect(loginButtonWidget.onPressed, isNull);
      expect(find.text(loc.offlineDescription), findsOneWidget);
    } else {
      final hasLogin = find.text(loc.loginTitle).evaluate().isNotEmpty;
      final hasHome = find.text(loc.homeTab).evaluate().isNotEmpty;
      expect(
        hasLogin || hasHome,
        isTrue,
        reason: 'App should show login or home when Supabase is configured.',
      );
    }
  });
}
