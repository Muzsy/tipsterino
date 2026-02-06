import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

typedef DailyBonusRpcCaller = Future<DailyBonusGrantResult> Function();

final dailyBonusRpcCallerProvider = Provider<DailyBonusRpcCaller>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return () async => const DailyBonusGrantResult.notConfigured();
  }

  final client = config.client!;
  return () async {
    final response = await client
        .rpc<Map<String, dynamic>>('grant_daily_bonus_if_eligible')
        .maybeSingle();
    return DailyBonusGrantResult.fromJson(response);
  };
});
