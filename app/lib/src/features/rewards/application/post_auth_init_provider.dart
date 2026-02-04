import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/features/rewards/data/signup_bonus_rpc.dart';
import 'package:tipsterino/src/features/rewards/domain/signup_bonus_grant_result.dart';

class PostAuthInitState {
  final bool isRunning;
  final String? lastUserId;
  final DateTime? lastRunAt;
  final SignupBonusGrantResult? lastResult;
  final Object? lastError;

  const PostAuthInitState({
    this.isRunning = false,
    this.lastUserId,
    this.lastRunAt,
    this.lastResult,
    this.lastError,
  });

  PostAuthInitState copyWith({
    bool? isRunning,
    String? lastUserId,
    DateTime? lastRunAt,
    SignupBonusGrantResult? lastResult,
    Object? lastError,
  }) {
    return PostAuthInitState(
      isRunning: isRunning ?? this.isRunning,
      lastUserId: lastUserId ?? this.lastUserId,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      lastResult: lastResult ?? this.lastResult,
      lastError: lastError ?? this.lastError,
    );
  }
}

class PostAuthInitNotifier extends StateNotifier<PostAuthInitState> {
  PostAuthInitNotifier(this._rpcCaller) : super(const PostAuthInitState());

  final SignupBonusRpcCaller _rpcCaller;

  Future<void> runIfNeeded(Session session) async {
    if (state.isRunning) return;
    final userId = session.user.id;
    if (userId.isEmpty) return;

    state = state.copyWith(
      isRunning: true,
      lastUserId: userId,
      lastError: null,
    );

    final runAt = DateTime.now();
    try {
      final result = await _rpcCaller();
      state = state.copyWith(lastResult: result, lastRunAt: runAt);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Post-auth signup bonus failed: $error');
      }
      state = state.copyWith(lastError: error, lastRunAt: runAt);
    } finally {
      state = state.copyWith(isRunning: false);
    }
  }
}

final postAuthInitProvider = StateNotifierProvider<PostAuthInitNotifier, PostAuthInitState>(
  (ref) => PostAuthInitNotifier(ref.watch(signupBonusRpcCallerProvider)),
);
