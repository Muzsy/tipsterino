import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Signup and daily bonus RPC reasons stay deterministic', () async {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      fail(
        'Missing SUPABASE_URL/SUPABASE_ANON_KEY dart-defines for bonus RPC integration test.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final client = Supabase.instance.client;

    const configuredEmail = String.fromEnvironment('BONUS_TEST_EMAIL');
    const configuredPassword = String.fromEnvironment('BONUS_TEST_PASSWORD');

    final suffix = _randomSuffix();
    final email =
        configuredEmail.isNotEmpty ? configuredEmail : 'bonus$suffix@test.com';
    final password =
        configuredPassword.isNotEmpty ? configuredPassword : 'ValidP@ss1';
    final nickname = 'bonus$suffix';

    await _authenticateUser(
      client: client,
      email: email,
      password: password,
      nickname: nickname,
      usedConfiguredCredentials:
          configuredEmail.isNotEmpty && configuredPassword.isNotEmpty,
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

    final dailyFirst = await _callRpc(
      client,
      'grant_daily_bonus_if_eligible',
    );
    expect(dailyFirst['granted'], isTrue);
    expect(dailyFirst['reason'], 'granted');

    final dailySecond = await _callRpc(
      client,
      'grant_daily_bonus_if_eligible',
    );
    expect(dailySecond['granted'], isFalse);
    expect(dailySecond['reason'], 'already_claimed_today');

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
      data: {
        'nickname': nickname,
        'avatar_key': 'default',
      },
    );
    if (signUpResult.session != null) {
      return;
    }
  } on AuthApiException catch (error) {
    final isRateLimited = error.statusCode == '429' ||
        error.code == 'over_email_send_rate_limit';
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
