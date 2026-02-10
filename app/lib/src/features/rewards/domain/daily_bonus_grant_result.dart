enum DailyBonusReason {
  granted,
  notConfigured,
  disabled,
  alreadyClaimedToday,
  notVerified,
  notAuthenticated,
  profileIncomplete,
  rateLimited,
}

class DailyBonusGrantResult {
  final bool granted;
  final int amount;
  final DailyBonusReason reason;
  final DateTime? nextEligibleAt;

  const DailyBonusGrantResult({
    required this.granted,
    required this.amount,
    required this.reason,
    this.nextEligibleAt,
  });

  factory DailyBonusGrantResult.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return const DailyBonusGrantResult.notConfigured();
    }

    final amountValue = map['amount'];
    late final int parsedAmount;
    if (amountValue is int) {
      parsedAmount = amountValue;
    } else if (amountValue is double) {
      parsedAmount = amountValue.toInt();
    } else if (amountValue is String) {
      parsedAmount = int.tryParse(amountValue) ?? 0;
    } else {
      parsedAmount = 0;
    }

    final nextEligibleAtValue = map['next_eligible_at'];
    DateTime? parsedNextEligibleAt;
    if (nextEligibleAtValue is String) {
      parsedNextEligibleAt = DateTime.tryParse(nextEligibleAtValue);
    } else if (nextEligibleAtValue is DateTime) {
      parsedNextEligibleAt = nextEligibleAtValue;
    }

    return DailyBonusGrantResult(
      granted: map['granted'] == true,
      amount: parsedAmount,
      reason: DailyBonusGrantResult._reasonFromString(
        map['reason']?.toString(),
      ),
      nextEligibleAt: parsedNextEligibleAt,
    );
  }

  const DailyBonusGrantResult.notConfigured()
      : granted = false,
        amount = 0,
        reason = DailyBonusReason.notConfigured,
        nextEligibleAt = null;

  static DailyBonusReason _reasonFromString(String? value) {
    switch (value) {
      case 'granted':
        return DailyBonusReason.granted;
      case 'notConfigured':
        return DailyBonusReason.notConfigured;
      case 'disabled':
        return DailyBonusReason.disabled;
      case 'already_claimed_today':
        return DailyBonusReason.alreadyClaimedToday;
      case 'not_verified':
        return DailyBonusReason.notVerified;
      case 'not_authenticated':
        return DailyBonusReason.notAuthenticated;
      case 'profile_incomplete':
        return DailyBonusReason.profileIncomplete;
      case 'rate_limited':
        return DailyBonusReason.rateLimited;
      default:
        return DailyBonusReason.notConfigured;
    }
  }
}
