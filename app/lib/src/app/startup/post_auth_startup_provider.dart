import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/rewards.dart';

typedef PostAuthStartupRunner = Future<void> Function(Session session);
const Object _startupUndefined = Object();

class PostAuthStartupState {
  const PostAuthStartupState({
    this.isRunning = false,
    this.lastUserId,
    this.lastRunAt,
    this.lastError,
  });

  final bool isRunning;
  final String? lastUserId;
  final DateTime? lastRunAt;
  final Object? lastError;

  PostAuthStartupState copyWith({
    bool? isRunning,
    String? lastUserId,
    DateTime? lastRunAt,
    Object? lastError = _startupUndefined,
  }) {
    return PostAuthStartupState(
      isRunning: isRunning ?? this.isRunning,
      lastUserId: lastUserId ?? this.lastUserId,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      lastError: identical(lastError, _startupUndefined)
          ? this.lastError
          : lastError,
    );
  }
}

final postAuthStartupRunnerProvider = Provider<PostAuthStartupRunner>((ref) {
  return (Session session) async {
    await ref.read(postAuthInitProvider.notifier).runIfNeeded(session);
  };
});

class PostAuthStartupNotifier extends StateNotifier<PostAuthStartupState> {
  PostAuthStartupNotifier(this._ref) : super(const PostAuthStartupState());

  final Ref _ref;

  Future<void> runIfNeeded(Session? session) async {
    if (state.isRunning || session == null) {
      return;
    }

    final userId = session.user.id;
    if (userId.isEmpty) {
      return;
    }

    final config = _ref.read(supabaseConfigProvider);
    if (!config.isConfigured || config.client == null) {
      return;
    }

    state = state.copyWith(
      isRunning: true,
      lastUserId: userId,
      lastError: null,
    );

    final runAt = DateTime.now();
    try {
      final runner = _ref.read(postAuthStartupRunnerProvider);
      await runner(session);
      state = state.copyWith(lastRunAt: runAt);
    } catch (error) {
      state = state.copyWith(lastRunAt: runAt, lastError: error);
    } finally {
      state = state.copyWith(isRunning: false);
    }
  }
}

final postAuthStartupProvider =
    StateNotifierProvider<PostAuthStartupNotifier, PostAuthStartupState>(
      (ref) => PostAuthStartupNotifier(ref),
    );
