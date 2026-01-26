import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupWizardState {
  final int stepIndex;
  final String email;
  final String password;

  const SignupWizardState({
    this.stepIndex = 0,
    this.email = '',
    this.password = '',
  });

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[^\w\s]')); // non-alphanumeric excluding whitespace
  bool get isEmailValid =>
      email.isNotEmpty && email.contains('@') && email.contains('.');
  bool get step1Valid =>
      isEmailValid &&
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasSpecialChar;

  SignupWizardState copyWith({
    int? stepIndex,
    String? email,
    String? password,
  }) {
    return SignupWizardState(
      stepIndex: stepIndex ?? this.stepIndex,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class SignupWizardNotifier extends StateNotifier<SignupWizardState> {
  SignupWizardNotifier() : super(const SignupWizardState());

  void updateEmail(String email) {
    state = state.copyWith(email: email.trim());
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
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
  (ref) => SignupWizardNotifier(),
);
