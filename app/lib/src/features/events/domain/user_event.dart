import 'package:flutter/foundation.dart';

const Object _readAtNotProvided = Object();
const Object _codeNotProvided = Object();

@immutable
class UserEvent {
  const UserEvent({
    required this.id,
    required this.type,
    required this.code,
    required this.amount,
    required this.payload,
    required this.createdAt,
    required this.readAt,
  });

  final String id;
  final String type;
  final String? code;
  final int? amount;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  factory UserEvent.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    if (id == null) {
      throw StateError('Missing id in UserEvent payload');
    }

    final type = map['type'];
    if (type == null) {
      throw StateError('Missing type in UserEvent payload');
    }

    final createdAtValue = map['created_at'];
    final createdAt = _parseDateTime(createdAtValue, 'created_at');

    final readAtValue = map['read_at'];
    final readAt = _tryParseDateTime(readAtValue);

    return UserEvent(
      id: id.toString(),
      type: type.toString(),
      code: _parseCode(map['code']),
      amount: _parseAmount(map['amount']),
      payload: _normalizePayload(map['payload']),
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  UserEvent copyWith({
    String? id,
    String? type,
    Object? code = _codeNotProvided,
    int? amount,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    Object? readAt = _readAtNotProvided,
  }) {
    final DateTime? readAtValue = identical(readAt, _readAtNotProvided)
        ? this.readAt
        : readAt as DateTime?;
    final String? codeValue = identical(code, _codeNotProvided)
        ? this.code
        : code as String?;
    return UserEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      code: codeValue,
      amount: amount ?? this.amount,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAtValue,
    );
  }

  static int? _parseAmount(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static DateTime _parseDateTime(Object? value, String fieldName) {
    final parsed = _tryParseDateTime(value);
    if (parsed == null) {
      throw StateError('Missing or invalid $fieldName in UserEvent payload');
    }
    return parsed;
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return null;
  }

  static Map<String, dynamic>? _normalizePayload(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String? _parseCode(Object? value) {
    if (value == null) return null;
    final code = value.toString();
    if (code.isEmpty) return null;
    return code;
  }
}
