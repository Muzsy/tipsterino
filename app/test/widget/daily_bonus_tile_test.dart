import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/rewards/application/daily_bonus_claim_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';
import 'package:tipsterino/src/features/rewards/presentation/daily_bonus_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithLocalizations(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  Future<void> pumpTile(
    WidgetTester tester,
    DailyBonusClaimState state,
  ) async {
    final notifier = DailyBonusClaimNotifier(
      () async => const DailyBonusGrantResult.notConfigured(),
    );
    notifier.state = state;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
      ),
    );

    expect(find.text('Claimed'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('disabled reason shows disabled text and CTA disabled', (tester) async {
    await pumpTile(
      tester,
      DailyBonusClaimState(
        lastResult: const DailyBonusGrantResult(
          granted: false,
          amount: 0,
          reason: DailyBonusReason.disabled,
        ),
      ),
    );

    expect(find.text('Daily bonus is not active.'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
