import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

class VerifyEmailPendingState {
  final bool isSending;
  final int cooldownRemainingSeconds;
  final String? errorMessage;
  final DateTime? lastSuccess;

  const VerifyEmailPendingState({
    this.isSending = false,
    this.cooldownRemainingSeconds = 0,
    this.errorMessage,
    this.lastSuccess,
  });

  VerifyEmailPendingState copyWith({
    bool? isSending,
    int? cooldownRemainingSeconds,
    String? errorMessage,
    DateTime? lastSuccess,
  }) {
    return VerifyEmailPendingState(
      isSending: isSending ?? this.isSending,
      cooldownRemainingSeconds:
          cooldownRemainingSeconds ?? this.cooldownRemainingSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSuccess: lastSuccess ?? this.lastSuccess,
    );
  }
}

typedef VerifyEmailResender = Future<void> Function({required String email});

final verifyEmailPendingCooldownProvider = Provider<int>((_) => 60);

final verifyEmailPendingResenderProvider = Provider<VerifyEmailResender>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return ({required String email}) async {
      throw StateError('Supabase is not configured');
    };
  }
  final client = config.client!;
  return ({required String email}) async {
    await client.auth.resend(type: OtpType.signup, email: email);
  };
});

class VerifyEmailPendingNotifier
    extends StateNotifier<VerifyEmailPendingState> {
  VerifyEmailPendingNotifier(this._ref)
    : super(const VerifyEmailPendingState());

  final Ref _ref;
  Timer? _cooldownTimer;

  Future<bool> resendEmail(String email) async {
    if (email.isEmpty ||
        state.isSending ||
        state.cooldownRemainingSeconds > 0) {
      return false;
    }

    final sender = _ref.read(verifyEmailPendingResenderProvider);
    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await sender(email: email);
      final now = DateTime.now();
      state = state.copyWith(
        isSending: false,
        lastSuccess: now,
        errorMessage: null,
      );
      _startCooldown();
      return true;
    } catch (error) {
      state = state.copyWith(isSending: false, errorMessage: error.toString());
      return false;
    }
  }

  void _startCooldown() {
    final seconds = _ref.read(verifyEmailPendingCooldownProvider);
    _cooldownTimer?.cancel();
    if (seconds <= 0) {
      state = state.copyWith(cooldownRemainingSeconds: 0);
      return;
    }
    state = state.copyWith(cooldownRemainingSeconds: seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.cooldownRemainingSeconds - 1;
      if (next <= 0) {
        state = state.copyWith(cooldownRemainingSeconds: 0);
        timer.cancel();
      } else {
        state = state.copyWith(cooldownRemainingSeconds: next);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}

final verifyEmailPendingProvider =
    StateNotifierProvider<VerifyEmailPendingNotifier, VerifyEmailPendingState>(
      (ref) => VerifyEmailPendingNotifier(ref),
    );
