import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/rewards/data/daily_bonus_rpc.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

void main() {
  group('DailyBonusGrantResult', () {
    test('fromJson null returns notConfigured', () {
      final result = DailyBonusGrantResult.fromJson(null);
      expect(result.granted, isFalse);
      expect(result.amount, 0);
      expect(result.reason, DailyBonusReason.notConfigured);
      expect(result.nextEligibleAt, isNull);
    });

    test('fromJson maps reasons correctly', () {
      final already = DailyBonusGrantResult.fromJson(
        {'reason': 'already_claimed_today', 'granted': false, 'amount': 0},
      );
      expect(already.reason, DailyBonusReason.alreadyClaimedToday);

      final profile = DailyBonusGrantResult.fromJson(
        {'reason': 'profile_incomplete', 'granted': false, 'amount': 0},
      );
      expect(profile.reason, DailyBonusReason.profileIncomplete);

      final rateLimited = DailyBonusGrantResult.fromJson(
        {'reason': 'rate_limited', 'granted': false, 'amount': 0},
      );
      expect(rateLimited.reason, DailyBonusReason.rateLimited);
    });

    test('fromJson unknown reason falls back to notConfigured', () {
      final fallback = DailyBonusGrantResult.fromJson(
        {'reason': 'unexpected_reason', 'granted': false, 'amount': 0},
      );
      expect(fallback.reason, DailyBonusReason.notConfigured);
    });

    test('fromJson parses nextEligibleAt string', () {
      const timestamp = '2025-12-31T23:59:59Z';
      final result = DailyBonusGrantResult.fromJson({
        'granted': true,
        'amount': 25,
        'reason': 'granted',
        'next_eligible_at': timestamp,
      });
      expect(result.nextEligibleAt, isNotNull);
      expect(result.nextEligibleAt, DateTime.parse(timestamp));
    });
  });

  test('dailyBonusRpcCallerProvider guard returns notConfigured when unconfigured', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final caller = container.read(dailyBonusRpcCallerProvider);
    final result = await caller();
    expect(result.reason, DailyBonusReason.notConfigured);
    expect(result.granted, isFalse);
  });
}
