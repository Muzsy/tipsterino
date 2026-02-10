import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/app/startup/post_auth_startup_provider.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';

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

SupabaseClient _buildClient() {
  return SupabaseClient(
    'http://localhost',
    'anon',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
}

void main() {
  test(
    'runIfNeeded delegates to runner for configured valid session',
    () async {
      final client = _buildClient();
      addTearDown(client.dispose);

      final calls = <String>[];
      final container = ProviderContainer(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            SupabaseConfiguration(isConfigured: true, client: client),
          ),
          postAuthStartupRunnerProvider.overrideWithValue((session) async {
            calls.add(session.user.id);
          }),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(postAuthStartupProvider.notifier)
          .runIfNeeded(_buildSession('user-1'));

      final state = container.read(postAuthStartupProvider);
      expect(calls, ['user-1']);
      expect(state.lastUserId, 'user-1');
      expect(state.lastRunAt, isNotNull);
      expect(state.lastError, isNull);
      expect(state.isRunning, isFalse);
    },
  );

  test('runIfNeeded skips execution when configuration is missing', () async {
    final called = <String>[];
    final container = ProviderContainer(
      overrides: [
        supabaseConfigProvider.overrideWithValue(
          const SupabaseConfiguration(isConfigured: false),
        ),
        postAuthStartupRunnerProvider.overrideWithValue((session) async {
          called.add(session.user.id);
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(postAuthStartupProvider.notifier)
        .runIfNeeded(_buildSession('user-2'));

    final state = container.read(postAuthStartupProvider);
    expect(called, isEmpty);
    expect(state.lastRunAt, isNull);
    expect(state.lastError, isNull);
    expect(state.isRunning, isFalse);
  });

  test('runIfNeeded skips execution for empty user id', () async {
    final client = _buildClient();
    addTearDown(client.dispose);

    final called = <String>[];
    final container = ProviderContainer(
      overrides: [
        supabaseConfigProvider.overrideWithValue(
          SupabaseConfiguration(isConfigured: true, client: client),
        ),
        postAuthStartupRunnerProvider.overrideWithValue((session) async {
          called.add(session.user.id);
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(postAuthStartupProvider.notifier)
        .runIfNeeded(_buildSession(''));

    final state = container.read(postAuthStartupProvider);
    expect(called, isEmpty);
    expect(state.lastRunAt, isNull);
    expect(state.lastError, isNull);
    expect(state.isRunning, isFalse);
  });

  test('runIfNeeded swallows runner error and stores it in state', () async {
    final client = _buildClient();
    addTearDown(client.dispose);

    final boom = StateError('boom');
    final container = ProviderContainer(
      overrides: [
        supabaseConfigProvider.overrideWithValue(
          SupabaseConfiguration(isConfigured: true, client: client),
        ),
        postAuthStartupRunnerProvider.overrideWithValue((session) async {
          throw boom;
        }),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(postAuthStartupProvider.notifier)
        .runIfNeeded(_buildSession('user-3'));

    final state = container.read(postAuthStartupProvider);
    expect(state.lastUserId, 'user-3');
    expect(state.lastRunAt, isNotNull);
    expect(state.lastError, same(boom));
    expect(state.isRunning, isFalse);
  });
}
