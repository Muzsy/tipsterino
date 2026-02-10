import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';

void main() {
  group('SignupWizardState.copyWith', () {
    test('keeps submitError when omitted', () {
      const initial = SignupWizardState(submitError: 'previous error');

      final next = initial.copyWith(isSubmitting: true);

      expect(next.submitError, 'previous error');
      expect(next.isSubmitting, isTrue);
    });

    test('allows explicit submitError reset to null', () {
      const initial = SignupWizardState(submitError: 'previous error');

      final next = initial.copyWith(submitError: null);

      expect(next.submitError, isNull);
    });

    test('updates submitError when a new message is provided', () {
      const initial = SignupWizardState(submitError: 'previous error');

      final next = initial.copyWith(submitError: 'new error');

      expect(next.submitError, 'new error');
    });
  });
}
