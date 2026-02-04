import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/signup_bonus_grant_result.dart';

typedef SignupBonusRpcCaller = Future<SignupBonusGrantResult> Function();

final signupBonusRpcCallerProvider = Provider<SignupBonusRpcCaller>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return () async => const SignupBonusGrantResult.notConfigured();
  }

  final client = config.client!;
  return () async {
    final response = await client
        .rpc<Map<String, dynamic>>('grant_signup_bonus_if_eligible')
        .maybeSingle();
    if (response == null) {
      return const SignupBonusGrantResult(
        granted: false,
        amount: 0,
        reason: SignupBonusReason.disabled,
      );
    }
    return SignupBonusGrantResult.fromJson(response);
  };
});
