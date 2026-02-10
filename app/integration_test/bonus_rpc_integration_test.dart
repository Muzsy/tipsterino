import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _BonusCredentials {
  const _BonusCredentials({
    required this.email,
    required this.password,
    required this.nickname,
    required this.usedConfiguredCredentials,
  });

  final String email;
  final String password;
  final String nickname;
  final bool usedConfiguredCredentials;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const overrideSupabaseUrl = String.fromEnvironment('IT_SUPABASE_URL');
  const overrideSupabaseAnonKey = String.fromEnvironment(
    'IT_SUPABASE_ANON_KEY',
  );
  const defaultSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const defaultSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final supabaseUrl = overrideSupabaseUrl.isNotEmpty
      ? overrideSupabaseUrl
      : defaultSupabaseUrl;
  final supabaseAnonKey = overrideSupabaseAnonKey.isNotEmpty
      ? overrideSupabaseAnonKey
      : defaultSupabaseAnonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    fail(
      'Missing SUPABASE_URL/SUPABASE_ANON_KEY dart-defines for bonus RPC integration test. '
      'You can also pass IT_SUPABASE_URL/IT_SUPABASE_ANON_KEY overrides.',
    );
  }

  late SupabaseClient client;
  setUpAll(() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    client = Supabase.instance.client;
  });

  test('Signup and daily bonus RPC reasons stay deterministic', () async {
    final credentials = _resolvePrimaryCredentials();

    await _authenticateUser(
      client: client,
      email: credentials.email,
      password: credentials.password,
      nickname: credentials.nickname,
      usedConfiguredCredentials: credentials.usedConfiguredCredentials,
    );

    expect(client.auth.currentUser, isNotNull);

    final signupFirst = await _callRpc(
      client,
      'grant_signup_bonus_if_eligible',
    );
    expect(signupFirst['granted'], isTrue);
    expect(signupFirst['reason'], 'granted');

    final signupSecond = await _callRpc(
      client,
      'grant_signup_bonus_if_eligible',
    );
    expect(signupSecond['granted'], isFalse);
    expect(signupSecond['reason'], 'already_granted');

    final dailyFirst = await _callRpc(client, 'grant_daily_bonus_if_eligible');
    expect(dailyFirst['granted'], isTrue);
    expect(dailyFirst['reason'], 'granted');

    final dailySecond = await _callRpc(client, 'grant_daily_bonus_if_eligible');
    expect(dailySecond['granted'], isFalse);
    expect(dailySecond['reason'], 'already_claimed_today');

    await client.auth.signOut();
  });

  test('Bonus RPC rate_limited branch stays deterministic', () async {
    final credentials = _resolveRateLimitCredentials();

    await _authenticateUser(
      client: client,
      email: credentials.email,
      password: credentials.password,
      nickname: credentials.nickname,
      usedConfiguredCredentials: credentials.usedConfiguredCredentials,
    );

    expect(client.auth.currentUser, isNotNull);

    final responses = <Map<String, dynamic>>[];
    for (var i = 0; i < 6; i++) {
      responses.add(await _callRpc(client, 'grant_signup_bonus_if_eligible'));
    }

    final reasons = responses
        .map((response) => response['reason']?.toString() ?? '')
        .toList(growable: false);
    expect(
      reasons,
      contains('rate_limited'),
      reason: 'Expected rate_limited reason within 6 rapid signup RPC calls.',
    );
    expect(responses.last['granted'], isFalse);
    expect(responses.last['amount'], 0);
    expect(responses.last['reason'], 'rate_limited');

    await client.auth.signOut();
  });
}

Future<void> _authenticateUser({
  required SupabaseClient client,
  required String email,
  required String password,
  required String nickname,
  required bool usedConfiguredCredentials,
}) async {
  try {
    final signInResult = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (signInResult.session != null) {
      return;
    }
  } on AuthApiException catch (error) {
    final isInvalidCredentials = error.code == 'invalid_credentials';
    if (!isInvalidCredentials) {
      rethrow;
    }
    if (usedConfiguredCredentials) {
      fail(
        'Configured BONUS_TEST_EMAIL/BONUS_TEST_PASSWORD could not sign in '
        'on the active Supabase project. Verify SUPABASE_URL/ANON_KEY and '
        'credentials target the same backend.',
      );
    }
  }

  try {
    final signUpResult = await client.auth.signUp(
      email: email,
      password: password,
      data: {'nickname': nickname, 'avatar_key': 'default'},
    );
    if (signUpResult.session != null) {
      return;
    }
  } on AuthApiException catch (error) {
    final isRateLimited =
        error.statusCode == '429' || error.code == 'over_email_send_rate_limit';
    if (isRateLimited) {
      fail(
        'Auth signup rate-limited. Re-run with BONUS_TEST_EMAIL and '
        'BONUS_TEST_PASSWORD dart-defines pointing to an existing test user, '
        'or raise local auth.rate_limit.email_sent in supabase/config.toml. '
        'configured_credentials_present=$usedConfiguredCredentials',
      );
    }
    rethrow;
  }

  final signInResult = await client.auth.signInWithPassword(
    email: email,
    password: password,
  );
  expect(signInResult.session, isNotNull);
}

_BonusCredentials _resolvePrimaryCredentials() {
  const configuredEmail = String.fromEnvironment('BONUS_TEST_EMAIL');
  const configuredPassword = String.fromEnvironment('BONUS_TEST_PASSWORD');

  if ((configuredEmail.isEmpty) != (configuredPassword.isEmpty)) {
    fail(
      'BONUS_TEST_EMAIL and BONUS_TEST_PASSWORD must be set together, or omitted together.',
    );
  }

  if (configuredEmail.isNotEmpty && configuredPassword.isNotEmpty) {
    return const _BonusCredentials(
      email: configuredEmail,
      password: configuredPassword,
      nickname: 'ci_bonus_user',
      usedConfiguredCredentials: true,
    );
  }

  final suffix = _randomSuffix();
  return _BonusCredentials(
    email: 'bonus$suffix@example.com',
    password: 'ValidP@ss1',
    nickname: 'bonus$suffix',
    usedConfiguredCredentials: false,
  );
}

_BonusCredentials _resolveRateLimitCredentials() {
  const configuredEmail = String.fromEnvironment('BONUS_RATE_LIMIT_TEST_EMAIL');
  const configuredPassword = String.fromEnvironment(
    'BONUS_RATE_LIMIT_TEST_PASSWORD',
  );

  if ((configuredEmail.isEmpty) != (configuredPassword.isEmpty)) {
    fail(
      'BONUS_RATE_LIMIT_TEST_EMAIL and BONUS_RATE_LIMIT_TEST_PASSWORD must be set together, or omitted together.',
    );
  }

  if (configuredEmail.isNotEmpty && configuredPassword.isNotEmpty) {
    return const _BonusCredentials(
      email: configuredEmail,
      password: configuredPassword,
      nickname: 'ci_bonus_rl_user',
      usedConfiguredCredentials: true,
    );
  }

  final suffix = _randomSuffix();
  return _BonusCredentials(
    email: 'bonus-rate$suffix@example.com',
    password: 'ValidP@ss1',
    nickname: 'bonusrate$suffix',
    usedConfiguredCredentials: false,
  );
}

Future<Map<String, dynamic>> _callRpc(SupabaseClient client, String fn) async {
  final response = await client.rpc<Map<String, dynamic>>(fn).maybeSingle();
  if (response == null) {
    fail('RPC $fn returned null response.');
  }
  return response;
}

String _randomSuffix() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
}
