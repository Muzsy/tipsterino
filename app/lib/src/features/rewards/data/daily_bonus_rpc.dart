import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

typedef DailyBonusRpcCaller = Future<DailyBonusGrantResult> Function();
typedef DailyBonusRpcRawCaller = Future<Map<String, dynamic>?> Function();

final dailyBonusRpcRawCallerProvider = Provider<DailyBonusRpcRawCaller>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return () async => null;
  }

  final client = config.client!;
  return () async => client
      .rpc<Map<String, dynamic>>('grant_daily_bonus_if_eligible')
      .maybeSingle();
});

final dailyBonusRpcCallerProvider = Provider<DailyBonusRpcCaller>((ref) {
  final raw = ref.watch(dailyBonusRpcRawCallerProvider);
  return () async {
    final response = await raw();
    return DailyBonusGrantResult.fromJson(response);
  };
});
