import 'package:flutter/foundation.dart';

/// Represents a single chat message in a 1:1 conversation.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  /// When the receiver marked this message as read.
  /// Null means unread.
  final DateTime? readAt;

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: _asString(map['id']),
      senderId: _asString(map['sender_id']),
      receiverId: _asString(map['receiver_id']),
      content: _asString(map['content']),
      createdAt: _parseDateTime(map['created_at']),
      readAt: _parseNullableDateTime(map['read_at']),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
    };
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is num) {
      final milliseconds = value.abs().toInt();
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is num && value.abs() > 0) {
      final milliseconds = value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return null;
  }

  @override
  int get hashCode => Object.hash(
        id,
        senderId,
        receiverId,
        content,
        createdAt.millisecondsSinceEpoch,
        readAt?.millisecondsSinceEpoch,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.readAt == readAt;
  }
}
