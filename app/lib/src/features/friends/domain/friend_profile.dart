import 'package:flutter/foundation.dart';

/// Represents a public profile viewed through the friends feature.
///
/// Uses Tipsterino's public_profiles contract: id, nickname, avatar_key.
/// Does NOT include avatar_url or score — these do not exist in Tipsterino.
@immutable
class FriendProfile {
  const FriendProfile({
    required this.id,
    required this.nickname,
    this.avatarKey,
  });

  final String id;
  final String nickname;
  final String? avatarKey;

  /// Returns initials from the nickname for avatar fallback display.
  String get initials {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length.clamp(0, 2)).toUpperCase();
  }

  factory FriendProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const FriendProfile(id: '', nickname: '');
    }
    return FriendProfile(
      id: _asString(map['id']),
      nickname: _asString(map['nickname']),
      avatarKey: _asStringOrNull(map['avatar_key']),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _asStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatarKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendProfile &&
        other.id == id &&
        other.nickname == nickname &&
        other.avatarKey == avatarKey;
  }
}
