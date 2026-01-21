import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tipsterino/main.dart' as app;
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Launch shows login screen', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).first);
    final loc = AppLocalizations.of(context)!;
    expect(find.text(loc.loginTitle), findsWidgets);
    expect(find.text(loc.offlineNotice), findsOneWidget);
  });
}
