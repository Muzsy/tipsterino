import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/features/rewards/data/daily_bonus_rpc.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

class DailyBonusClaimState {
  const DailyBonusClaimState({
    this.isRunning = false,
    this.lastResult,
    this.cachedNextEligibleAt,
    this.lastError,
  });

  final bool isRunning;
  final DailyBonusGrantResult? lastResult;
  final DateTime? cachedNextEligibleAt;
  final Object? lastError;

  bool get isClaimedNow {
    final nextEligible = cachedNextEligibleAt;
    if (nextEligible == null) {
      return false;
    }
    return nextEligible.toUtc().isAfter(DateTime.now().toUtc());
  }

  DailyBonusClaimState copyWith({
    bool? isRunning,
    DailyBonusGrantResult? lastResult,
    DateTime? cachedNextEligibleAt,
    Object? lastError,
  }) {
    return DailyBonusClaimState(
      isRunning: isRunning ?? this.isRunning,
      lastResult: lastResult ?? this.lastResult,
      cachedNextEligibleAt: cachedNextEligibleAt ?? this.cachedNextEligibleAt,
      lastError: lastError ?? this.lastError,
    );
  }
}

class DailyBonusClaimNotifier extends StateNotifier<DailyBonusClaimState> {
  DailyBonusClaimNotifier(this._rpcCaller) : super(const DailyBonusClaimState());

  final DailyBonusRpcCaller _rpcCaller;

  Future<DailyBonusGrantResult?> claim() async {
    if (state.isRunning) {
      return null;
    }

    state = state.copyWith(isRunning: true, lastError: null);

    try {
      final result = await _rpcCaller();
      state = state.copyWith(
        lastResult: result,
        cachedNextEligibleAt: result.nextEligibleAt ?? state.cachedNextEligibleAt,
        isRunning: false,
      );
      return result;
    } catch (error) {
      state = state.copyWith(lastError: error, isRunning: false);
      return null;
    }
  }
}

final dailyBonusClaimProvider = StateNotifierProvider<DailyBonusClaimNotifier, DailyBonusClaimState>(
  (ref) => DailyBonusClaimNotifier(ref.watch(dailyBonusRpcCallerProvider)),
);
