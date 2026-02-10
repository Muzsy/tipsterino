import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/src/features/events/domain/user_event.dart';

Map<String, dynamic> _basePayload({Object? code = 'signup_bonus'}) {
  return <String, dynamic>{
    'id': 'evt-1',
    'type': 'tippcoin_credit',
    'code': code,
    'amount': 100,
    'payload': null,
    'created_at': '2026-01-01T10:00:00Z',
    'read_at': null,
  };
}

void main() {
  group('UserEvent.fromMap', () {
    test('accepts null code without throwing', () {
      final event = UserEvent.fromMap(_basePayload(code: null));

      expect(event.code, isNull);
      expect(event.type, 'tippcoin_credit');
      expect(event.id, 'evt-1');
    });

    test('normalizes empty code to null', () {
      final event = UserEvent.fromMap(_basePayload(code: ''));

      expect(event.code, isNull);
    });
  });

  group('UserEvent.copyWith', () {
    test('keeps code when omitted', () {
      final event = UserEvent.fromMap(_basePayload(code: 'daily_bonus'));
      final copied = event.copyWith(type: 'custom_type');

      expect(copied.code, 'daily_bonus');
      expect(copied.type, 'custom_type');
    });

    test('allows explicit code reset to null', () {
      final event = UserEvent.fromMap(_basePayload(code: 'daily_bonus'));
      final copied = event.copyWith(code: null);

      expect(copied.code, isNull);
    });
  });
}
