class SignupBonusGrantResult {
  final bool granted;
  final int amount;
  final String reason;

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
        reason: 'unknown',
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
      reason: map['reason']?.toString() ?? 'unknown',
    );
  }

  const SignupBonusGrantResult.notConfigured()
      : granted = false,
        amount = 0,
        reason = 'not_configured';
}
