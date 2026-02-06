import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/application/daily_bonus_claim_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';
import 'package:tipsterino/src/features/rewards/presentation/daily_bonus_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithLocalizations(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      home: Scaffold(body: child),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  Future<void> pumpTile(
    WidgetTester tester,
    DailyBonusClaimState state, {
    bool isSupabaseConfigured = true,
  }) async {
    final notifier = DailyBonusClaimNotifier(
      () async => const DailyBonusGrantResult.notConfigured(),
    );
    notifier.state = state;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            SupabaseConfiguration(isConfigured: isSupabaseConfigured),
          ),
          dailyBonusClaimProvider.overrideWith((ref) => notifier),
        ],
        child: wrapWithLocalizations(const DailyBonusTile()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('default state shows CTA and available text', (tester) async {
    await pumpTile(tester, const DailyBonusClaimState());

    expect(find.text('Claim'), findsOneWidget);
    expect(find.text('Claim your daily TippCoins.'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('claimed state disables CTA and shows claimed label', (tester) async {
    final futureClaim = DateTime.now().toUtc().add(const Duration(hours: 1));
    await pumpTile(
      tester,
      DailyBonusClaimState(
        cachedNextEligibleAt: futureClaim,
        lastResult: const DailyBonusGrantResult(
          granted: false,
          amount: 0,
          reason: DailyBonusReason.alreadyClaimedToday,
        ),
      ),
    );

    expect(find.text('Claimed'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('disabled result with cached nextEligibleAt does not show claimed label', (tester) async {
    final futureClaim = DateTime.now().toUtc().add(const Duration(hours: 1));
    await pumpTile(
      tester,
      DailyBonusClaimState(
        cachedNextEligibleAt: futureClaim,
        lastResult: const DailyBonusGrantResult(
          granted: false,
          amount: 0,
          reason: DailyBonusReason.disabled,
        ),
      ),
    );

    expect(find.text('Daily bonus is not active.'), findsOneWidget);
    expect(find.text('Claimed'), findsNothing);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('notConfigured result shows offline notice and keeps CTA disabled', (tester) async {
    await pumpTile(
      tester,
      const DailyBonusClaimState(
        lastResult: DailyBonusGrantResult.notConfigured(),
      ),
      isSupabaseConfigured: false,
    );

    expect(find.text('Daily bonus is unavailable (not configured).'), findsOneWidget);
    expect(find.text('Claimed'), findsNothing);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('offline error shows retry CTA when Supabase configured', (tester) async {
    await pumpTile(
      tester,
      const DailyBonusClaimState(lastError: Object()),
      isSupabaseConfigured: true,
    );

    expect(find.text('You appear to be offline. Try again.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });
}
