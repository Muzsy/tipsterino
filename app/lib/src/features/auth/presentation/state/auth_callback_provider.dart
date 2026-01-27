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

final authCallbackProvider =
    StateNotifierProvider<AuthCallbackNotifier, AuthCallbackState>(
      (ref) => AuthCallbackNotifier(ref),
    );
