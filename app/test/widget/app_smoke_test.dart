import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';

void main() {
  testWidgets('App boots to login screen without Supabase', (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfiguration(isConfigured: false),
          ),
        ],
        child: const TipsterinoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(loc.logInButton), findsWidgets);
    expect(find.text(loc.dontHaveAccountPrompt), findsOneWidget);

    await tester.tap(find.text(loc.dontHaveAccountPrompt));
    await tester.pumpAndSettle();

    expect(find.text(loc.registerTitle), findsWidgets);
  });
}
