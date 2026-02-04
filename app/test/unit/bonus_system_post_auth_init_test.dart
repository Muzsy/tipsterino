import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/features/rewards/application/post_auth_init_provider.dart';
import 'package:tipsterino/src/features/rewards/data/signup_bonus_rpc.dart';
import 'package:tipsterino/src/features/rewards/domain/signup_bonus_grant_result.dart';

Session _buildSession(String userId) {
  final session = Session.fromJson(<String, dynamic>{
    'access_token': 'token',
    'refresh_token': 'refresh',
    'token_type': 'bearer',
    'aud': 'authenticated',
    'user': <String, dynamic>{
      'id': userId,
      'app_metadata': <String, dynamic>{},
      'aud': 'authenticated',
      'created_at': '2024-01-01T00:00:00Z',
    },
  });
  return session!;
}

void main() {
  const userId = 'user-123';
  final session = _buildSession(userId);

  test('records granted result when RPC returns success', () async {
    final container = ProviderContainer(overrides: [
      signupBonusRpcCallerProvider.overrideWithValue(() async => const SignupBonusGrantResult(granted: true, amount: 42, reason: 'granted')),
    ]);
    addTearDown(container.dispose);

    await container.read(postAuthInitProvider.notifier).runIfNeeded(session);
    final state = container.read(postAuthInitProvider);

    expect(state.lastResult?.granted, isTrue);
    expect(state.lastResult?.amount, 42);
    expect(state.lastResult?.reason, 'granted');
    expect(state.lastUserId, userId);
    expect(state.isRunning, isFalse);
    expect(state.lastError, isNull);
  });

  test('records not_verified result without marking error', () async {
    final container = ProviderContainer(overrides: [
      signupBonusRpcCallerProvider.overrideWithValue(() async => const SignupBonusGrantResult(granted: false, amount: 0, reason: 'not_verified')),
    ]);
    addTearDown(container.dispose);

    await container.read(postAuthInitProvider.notifier).runIfNeeded(session);
    final state = container.read(postAuthInitProvider);

    expect(state.lastResult?.reason, 'not_verified');
    expect(state.lastError, isNull);
    expect(state.isRunning, isFalse);
  });

  test('captures errors thrown by RPC and keeps running flag false', () async {
    final error = StateError('rpc failure');
    final container = ProviderContainer(overrides: [
      signupBonusRpcCallerProvider.overrideWithValue(() async { throw error; }),
    ]);
    addTearDown(container.dispose);

    await container.read(postAuthInitProvider.notifier).runIfNeeded(session);
    final state = container.read(postAuthInitProvider);

    expect(state.lastError, same(error));
    expect(state.lastResult, isNull);
    expect(state.isRunning, isFalse);
  });
}
