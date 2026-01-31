import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthState, Session;

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, offline }

class AuthViewState {
  final AuthStatus status;
  final Session? session;
  const AuthViewState({required this.status, this.session});
}

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
}

class AuthNotifier extends StateNotifier<AuthViewState> {
  AuthNotifier(this._ref, {AuthViewState? initialState, bool autoListen = true})
    : super(initialState ?? const AuthViewState(status: AuthStatus.unknown)) {
    _stateController.add(state);
    if (autoListen) {
      _listenAuthChanges();
    }
  }

  final Ref _ref;
  StreamSubscription<AuthState>? _authSubscription;
  final StreamController<AuthViewState> _stateController =
      StreamController<AuthViewState>.broadcast();

  Stream<AuthViewState> get stateStream => _stateController.stream;

  void _listenAuthChanges() {
    final config = _ref.read(supabaseConfigProvider);
    if (!config.isConfigured || config.client == null) {
      _updateState(const AuthViewState(status: AuthStatus.offline));
      return;
    }

    final client = config.client!;
    final session = client.auth.currentSession;
    if (session != null) {
      _updateState(
        AuthViewState(status: AuthStatus.authenticated, session: session),
      );
    } else {
      _updateState(const AuthViewState(status: AuthStatus.unauthenticated));
    }

    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      final currentSession = data.session;
      if (currentSession != null) {
        _updateState(
          AuthViewState(
            status: AuthStatus.authenticated,
            session: currentSession,
          ),
        );
      } else {
        _updateState(const AuthViewState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    final config = _ref.read(supabaseConfigProvider);
    if (!config.isConfigured || config.client == null) {
      throw const AuthFailure('Supabase nincs konfigurálva');
    }

    try {
      await config.client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    } catch (error) {
      throw AuthFailure(error.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final config = _ref.read(supabaseConfigProvider);
    if (!config.isConfigured || config.client == null) {
      throw const AuthFailure('Supabase nincs konfigurálva');
    }

    try {
      await config.client!.auth.signUp(email: email, password: password);
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    } catch (error) {
      throw AuthFailure(error.toString());
    }
  }

  Future<void> signOut() async {
    final config = _ref.read(supabaseConfigProvider);
    if (!config.isConfigured || config.client == null) {
      _updateState(const AuthViewState(status: AuthStatus.unauthenticated));
      return;
    }

    await config.client!.auth.signOut();
    _updateState(const AuthViewState(status: AuthStatus.unauthenticated));
  }

  void _updateState(AuthViewState next) {
    state = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _stateController.close();
    super.dispose();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthViewState>(
  (ref) => AuthNotifier(ref),
);

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<AuthViewState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  StreamSubscription<AuthViewState>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authRefreshNotifierProvider = ChangeNotifierProvider<AuthRefreshNotifier>(
  (ref) {
    final stream = ref.watch(authNotifierProvider.notifier).stateStream;
    return AuthRefreshNotifier(stream);
  },
);
