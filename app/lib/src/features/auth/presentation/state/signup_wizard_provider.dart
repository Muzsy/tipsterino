import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

enum NicknameAvailabilityStatus {
  idle,
  tooShort,
  invalid,
  checking,
  available,
  unavailable,
  error,
}

typedef NicknameAvailabilityChecker = Future<bool> Function(String nickname);
typedef SignupSubmitter =
    Future<void> Function({
      required String email,
      required String password,
      required String nickname,
      required String avatarKey,
    });

class SignupWizardState {
  final int stepIndex;
  final String email;
  final String password;
  final String nickname;
  final String avatarKey;
  final NicknameAvailabilityStatus nicknameStatus;
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool isSubmitting;
  final String? submitError;

  const SignupWizardState({
    this.stepIndex = 0,
    this.email = '',
    this.password = '',
    this.nickname = '',
    this.avatarKey = 'neutral',
    this.nicknameStatus = NicknameAvailabilityStatus.idle,
    this.termsAccepted = false,
    this.privacyAccepted = false,
    this.isSubmitting = false,
    this.submitError,
  });

  static final _nicknameRegex = RegExp(r'^[a-z0-9_.]{3,20}$');
  static const _nicknameMinLength = 3;

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasSpecialChar => password.contains(
    RegExp(r'[^\w\s]'),
  ); // non-alphanumeric excluding whitespace
  bool get isEmailValid =>
      email.isNotEmpty && email.contains('@') && email.contains('.');
  bool get step1Valid =>
      isEmailValid &&
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasSpecialChar;

  bool get isNicknameFormatValid => _nicknameRegex.hasMatch(nickname);
  bool get isNicknameTooShort => nickname.length < _nicknameMinLength;
  bool get step2Valid =>
      nicknameStatus == NicknameAvailabilityStatus.available &&
      avatarKey.isNotEmpty;

  bool get step3Valid => termsAccepted && privacyAccepted;

  SignupWizardState copyWith({
    int? stepIndex,
    String? email,
    String? password,
    String? nickname,
    String? avatarKey,
    NicknameAvailabilityStatus? nicknameStatus,
    bool? termsAccepted,
    bool? privacyAccepted,
    bool? isSubmitting,
    String? submitError,
  }) {
    return SignupWizardState(
      stepIndex: stepIndex ?? this.stepIndex,
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      avatarKey: avatarKey ?? this.avatarKey,
      nicknameStatus: nicknameStatus ?? this.nicknameStatus,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
    );
  }
}

class SignupWizardNotifier extends StateNotifier<SignupWizardState> {
  SignupWizardNotifier(this._ref) : super(const SignupWizardState());

  final Ref _ref;
  Timer? _nicknameDebounceTimer;
  int _nicknameRequestId = 0;
  static final _debounceDuration = const Duration(milliseconds: 450);

  bool get _isSupabaseConfigured =>
      _ref.read(supabaseConfigProvider).isConfigured;

  void updateEmail(String email) {
    state = state.copyWith(email: email.trim());
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateNickname(String raw) {
    final normalized = raw.trim().toLowerCase();
    final status = _initialNicknameStatus(normalized);
    state = state.copyWith(nickname: normalized, nicknameStatus: status);
    _nicknameDebounceTimer?.cancel();

    if (status == NicknameAvailabilityStatus.checking &&
        _isSupabaseConfigured) {
      _nicknameDebounceTimer = Timer(_debounceDuration, () {
        _checkNicknameAvailability(normalized);
      });
    }
  }

  void updateAvatarKey(String avatarKey) {
    state = state.copyWith(avatarKey: avatarKey);
  }

  void toggleTermsAccepted(bool accepted) {
    state = state.copyWith(termsAccepted: accepted, submitError: null);
  }

  void togglePrivacyAccepted(bool accepted) {
    state = state.copyWith(privacyAccepted: accepted, submitError: null);
  }

  Future<bool> submitSignUp() async {
    if (state.isSubmitting) return false;
    if (!state.step1Valid || !state.step2Valid || !state.step3Valid) {
      return false;
    }
    final submitter = _ref.read(signupSubmitterProvider);
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      await submitter(
        email: state.email,
        password: state.password,
        nickname: state.nickname,
        avatarKey: state.avatarKey,
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error) {
      final message = error.toString();
      state = state.copyWith(isSubmitting: false, submitError: message);
      return false;
    }
  }

  NicknameAvailabilityStatus _initialNicknameStatus(String normalized) {
    if (normalized.isEmpty) return NicknameAvailabilityStatus.idle;
    if (normalized.length < SignupWizardState._nicknameMinLength) {
      return NicknameAvailabilityStatus.tooShort;
    }
    if (!SignupWizardState._nicknameRegex.hasMatch(normalized)) {
      return NicknameAvailabilityStatus.invalid;
    }
    return NicknameAvailabilityStatus.checking;
  }

  Future<void> _checkNicknameAvailability(String normalized) async {
    if (!_isSupabaseConfigured) return;
    final checker = _ref.read(nicknameAvailabilityCheckerProvider);
    final requestId = ++_nicknameRequestId;
    state = state.copyWith(nicknameStatus: NicknameAvailabilityStatus.checking);
    try {
      final available = await checker(normalized);
      if (_nicknameRequestId != requestId) return;
      state = state.copyWith(
        nicknameStatus: available
            ? NicknameAvailabilityStatus.available
            : NicknameAvailabilityStatus.unavailable,
      );
    } catch (_) {
      if (_nicknameRequestId != requestId) return;
      state = state.copyWith(nicknameStatus: NicknameAvailabilityStatus.error);
    }
  }

  @override
  void dispose() {
    _nicknameDebounceTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    final nextIndex = (state.stepIndex + 1).clamp(0, 2);
    state = state.copyWith(stepIndex: nextIndex);
  }

  void previousStep() {
    final previousIndex = (state.stepIndex - 1).clamp(0, 2);
    state = state.copyWith(stepIndex: previousIndex);
  }
}

final signupWizardProvider =
    StateNotifierProvider<SignupWizardNotifier, SignupWizardState>(
      (ref) => SignupWizardNotifier(ref),
    );

final nicknameAvailabilityCheckerProvider =
    Provider<NicknameAvailabilityChecker>((ref) {
      final config = ref.watch(supabaseConfigProvider);
      if (config.isConfigured && config.client != null) {
        return (nickname) async {
          final response = await config.client!.rpc(
            'check_nickname_available',
            params: {'p_nickname': nickname},
          );
          final error = response.error;
          if (error != null) {
            throw error;
          }
          final available = response.data as bool?;
          return available ?? false;
        };
      }
      return (_) async => false;
    });

final signupSubmitterProvider = Provider<SignupSubmitter>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return ({
      required String email,
      required String password,
      required String nickname,
      required String avatarKey,
    }) async {
      throw StateError('Supabase is not configured');
    };
  }
  final client = config.client!;
  return ({
    required String email,
    required String password,
    required String nickname,
    required String avatarKey,
  }) async {
    await client.auth.signUp(
      email: email,
      password: password,
      data: {'nickname': nickname, 'avatar_key': avatarKey},
    );
  };
});
