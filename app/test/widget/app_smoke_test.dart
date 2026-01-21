import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/app.dart';
import 'package:tipsterino/src/providers/supabase_provider.dart';

void main() {
  testWidgets('App boots to login screen without Supabase', (tester) async {
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

    expect(find.text('Log in'), findsWidgets);
    expect(find.text("Don't have an account? Register"), findsOneWidget);

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsWidgets);
  });
}
