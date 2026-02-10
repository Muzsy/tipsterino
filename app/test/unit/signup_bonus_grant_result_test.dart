import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/rewards/domain/signup_bonus_grant_result.dart';

void main() {
  group('SignupBonusGrantResult', () {
    test('fromJson null returns notConfigured', () {
      final result = SignupBonusGrantResult.fromJson(null);
      expect(result.granted, isFalse);
      expect(result.amount, 0);
      expect(result.reason, SignupBonusReason.notConfigured);
    });

    test('fromJson maps profile_incomplete and rate_limited', () {
      final profileIncomplete = SignupBonusGrantResult.fromJson(
        {'reason': 'profile_incomplete', 'granted': false, 'amount': 0},
      );
      expect(profileIncomplete.reason, SignupBonusReason.profileIncomplete);

      final rateLimited = SignupBonusGrantResult.fromJson(
        {'reason': 'rate_limited', 'granted': false, 'amount': 0},
      );
      expect(rateLimited.reason, SignupBonusReason.rateLimited);
    });

    test('fromJson unknown reason falls back to notConfigured', () {
      final result = SignupBonusGrantResult.fromJson(
        {'reason': 'unexpected_reason', 'granted': false, 'amount': 0},
      );
      expect(result.reason, SignupBonusReason.notConfigured);
    });

    test('fromJson parses amount values robustly', () {
      final fromInt = SignupBonusGrantResult.fromJson(
        {'reason': 'granted', 'granted': true, 'amount': 25},
      );
      expect(fromInt.amount, 25);

      final fromString = SignupBonusGrantResult.fromJson(
        {'reason': 'granted', 'granted': true, 'amount': '30'},
      );
      expect(fromString.amount, 30);
    });
  });
}
