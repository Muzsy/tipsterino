import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/rewards/data/daily_bonus_rpc.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

void main() {
  test('maps granted payload and parses next_eligible_at', () async {
    var rawCalls = 0;
    final container = ProviderContainer(
      overrides: [
        dailyBonusRpcRawCallerProvider.overrideWithValue(() async {
          rawCalls++;
          return {
            'granted': true,
            'amount': 50,
            'reason': 'granted',
            'next_eligible_at': '2025-12-31T23:59:59Z',
          };
        }),
      ],
    );
    addTearDown(container.dispose);

    final caller = container.read(dailyBonusRpcCallerProvider);
    final result = await caller();

    expect(rawCalls, 1);
    expect(result.granted, isTrue);
    expect(result.amount, 50);
    expect(result.reason, DailyBonusReason.granted);
    expect(result.nextEligibleAt, DateTime.parse('2025-12-31T23:59:59Z'));
  });

  test('maps already_claimed_today reason', () async {
    var rawCalls = 0;
    final container = ProviderContainer(
      overrides: [
        dailyBonusRpcRawCallerProvider.overrideWithValue(() async {
          rawCalls++;
          return {
            'granted': false,
            'amount': 0,
            'reason': 'already_claimed_today',
            'next_eligible_at': '2025-12-31T23:59:59Z',
          };
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(dailyBonusRpcCallerProvider)();
    expect(rawCalls, 1);
    expect(result.reason, DailyBonusReason.alreadyClaimedToday);
  });

  test('maps disabled reason', () async {
    var rawCalls = 0;
    final container = ProviderContainer(
      overrides: [
        dailyBonusRpcRawCallerProvider.overrideWithValue(() async {
          rawCalls++;
          return {
            'granted': false,
            'amount': 0,
            'reason': 'disabled',
          };
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(dailyBonusRpcCallerProvider)();
    expect(rawCalls, 1);
    expect(result.reason, DailyBonusReason.disabled);
  });

  test('null raw response maps to notConfigured', () async {
    var rawCalls = 0;
    final container = ProviderContainer(
      overrides: [
        dailyBonusRpcRawCallerProvider.overrideWithValue(() async {
          rawCalls++;
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(dailyBonusRpcCallerProvider)();
    expect(rawCalls, 1);
    expect(result.reason, DailyBonusReason.notConfigured);
    expect(result.granted, isFalse);
    expect(result.amount, 0);
  });
}
