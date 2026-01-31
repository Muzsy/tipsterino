import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

enum AuthCallbackStatus { processing, success, expired, error }

class AuthCallbackState {
  final AuthCallbackStatus status;
  final String? message;
  final String? email;

  const AuthCallbackState({
    this.status = AuthCallbackStatus.processing,
    this.message,
    this.email,
  });

  AuthCallbackState copyWith({
    AuthCallbackStatus? status,
    String? message,
    String? email,
  }) {
    return AuthCallbackState(
      status: status ?? this.status,
      message: message ?? this.message,
      email: email ?? this.email,
    );
  }
}

enum AuthCallbackOutcome { success, expired, error }

class AuthCallbackHandlerResult {
  final AuthCallbackOutcome outcome;
  final String? message;

  const AuthCallbackHandlerResult(this.outcome, {this.message});
}

typedef AuthCallbackHandler =
  Future<AuthCallbackHandlerResult> Function(Uri uri);

final authCallbackHandlerProvider = Provider<AuthCallbackHandler>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  return (Uri uri) async {
    debugPrint('AuthCallbackHandler process uri: ${_describeUri(uri)}');
    if (!config.isConfigured || config.client == null) {
      return const AuthCallbackHandlerResult(
        AuthCallbackOutcome.error,
        message: 'Supabase nincs konfigurálva',
      );
    }

    try {
      await config.client!.auth.getSessionFromUrl(uri);
      return const AuthCallbackHandlerResult(AuthCallbackOutcome.success);
    } on AuthException catch (error) {
      debugPrint(
        'AuthCallbackHandler AuthException code=${error.code} status=${error.statusCode}',
      );
      if (_isExpiredDeepLink(error)) {
        return AuthCallbackHandlerResult(
          AuthCallbackOutcome.expired,
          message: error.message,
        );
      }
      return AuthCallbackHandlerResult(
        AuthCallbackOutcome.error,
        message: error.message,
      );
    } catch (error) {
      debugPrint('AuthCallbackHandler exception: $error');
      return AuthCallbackHandlerResult(
        AuthCallbackOutcome.error,
        message: error.toString(),
      );
    }
  };
});

bool _isExpiredDeepLink(AuthException error) {
  final message = error.message.toLowerCase();
  final code = error.code?.toLowerCase();
  final statusCode = error.statusCode;

  return message.contains('expired') ||
      message.contains('invalid') ||
      message.contains('access_denied') ||
      code == 'access_denied' ||
      statusCode == '403';
}

class AuthCallbackNotifier extends StateNotifier<AuthCallbackState> {
  AuthCallbackNotifier(this._ref) : super(const AuthCallbackState());

  final Ref _ref;
  String? _lastProcessedUri;

  Future<void> process(Uri uri) async {
    final email = uri.queryParameters['email'];
    final uriString = uri.toString();
    if (_lastProcessedUri == uriString &&
        state.status != AuthCallbackStatus.processing) {
      return;
    }

    _lastProcessedUri = uriString;
    state = AuthCallbackState(
      status: AuthCallbackStatus.processing,
      email: email,
    );

    final handler = _ref.read(authCallbackHandlerProvider);
    final result = await handler(uri);
    debugPrint(
      'AuthCallbackHandler outcome: ${result.outcome}${result.message != null ? ', message=${result.message}' : ''}',
    );
    final nextStatus = _mapOutcomeToStatus(result.outcome);

    state = state.copyWith(
      status: nextStatus,
      message: result.message,
      email: email,
    );
  }

  AuthCallbackStatus _mapOutcomeToStatus(AuthCallbackOutcome outcome) {
    switch (outcome) {
      case AuthCallbackOutcome.success:
        return AuthCallbackStatus.success;
      case AuthCallbackOutcome.expired:
        return AuthCallbackStatus.expired;
      case AuthCallbackOutcome.error:
        return AuthCallbackStatus.error;
    }
  }
}

String _describeUri(Uri uri) {
  final queryKeys = uri.queryParameters.keys.toList();
  final fragmentKeys = _extractFragmentKeyNames(uri.fragment);
  final queryPart =
      queryKeys.isEmpty ? 'none' : queryKeys.join(', ');
  final fragmentPart =
      fragmentKeys.isEmpty ? 'none' : fragmentKeys.join(', ');
  return 'path=${uri.path}, queryKeys=[$queryPart], fragmentKeys=[$fragmentPart]';
}

List<String> _extractFragmentKeyNames(String fragment) {
  if (fragment.isEmpty) return [];
  return fragment
      .split('&')
      .map((segment) => segment.split('=').first)
      .where((key) => key.isNotEmpty)
      .toList();
}
final authCallbackProvider =
    StateNotifierProvider<AuthCallbackNotifier, AuthCallbackState>(
      (ref) => AuthCallbackNotifier(ref),
    );
