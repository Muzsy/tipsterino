import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';

void main() {
  group('VerifyEmailPendingState.copyWith', () {
    test('keeps errorMessage when omitted', () {
      const initial = VerifyEmailPendingState(errorMessage: 'previous error');

      final next = initial.copyWith(isSending: true);

      expect(next.errorMessage, 'previous error');
      expect(next.isSending, isTrue);
    });

    test('allows explicit errorMessage reset to null', () {
      const initial = VerifyEmailPendingState(errorMessage: 'previous error');

      final next = initial.copyWith(errorMessage: null);

      expect(next.errorMessage, isNull);
    });

    test('updates errorMessage when a new message is provided', () {
      const initial = VerifyEmailPendingState(errorMessage: 'previous error');

      final next = initial.copyWith(errorMessage: 'new error');

      expect(next.errorMessage, 'new error');
    });
  });
}
