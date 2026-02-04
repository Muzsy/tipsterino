enum SignupBonusReason {
  granted,
  notConfigured,
  disabled,
  alreadyGranted,
  notVerified,
  notAuthenticated,
}

class SignupBonusGrantResult {
  final bool granted;
  final int amount;
  final SignupBonusReason reason;

  const SignupBonusGrantResult({
    required this.granted,
    required this.amount,
    required this.reason,
  });

  factory SignupBonusGrantResult.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return const SignupBonusGrantResult(
        granted: false,
        amount: 0,
        reason: SignupBonusReason.notConfigured,
      );
    }

    final amountValue = map['amount'];
    int amount = 0;
    if (amountValue is int) {
      amount = amountValue;
    } else if (amountValue is double) {
      amount = amountValue.toInt();
    } else if (amountValue is String) {
      amount = int.tryParse(amountValue) ?? 0;
    }

    return SignupBonusGrantResult(
      granted: map['granted'] == true,
      amount: amount,
      reason: SignupBonusGrantResult._reasonFromString(
        map['reason']?.toString(),
      ),
    );
  }

  const SignupBonusGrantResult.notConfigured()
      : granted = false,
        amount = 0,
        reason = SignupBonusReason.notConfigured;

  static SignupBonusReason _reasonFromString(String? value) {
    switch (value) {
      case 'granted':
        return SignupBonusReason.granted;
      case 'not_verified':
        return SignupBonusReason.notVerified;
      case 'disabled':
        return SignupBonusReason.disabled;
      case 'already_granted':
        return SignupBonusReason.alreadyGranted;
      case 'not_authenticated':
        return SignupBonusReason.notAuthenticated;
      default:
        return SignupBonusReason.notConfigured;
    }
  }
}
