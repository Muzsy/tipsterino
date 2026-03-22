import 'package:flutter/foundation.dart';

import 'friend_profile.dart';
import 'friend_status.dart';

/// Represents a friendship record as seen by the current user.
///
/// The [profile] field holds the OTHER user's profile (the friend/requester).
/// [isRequester] indicates whether the current user sent the original request.
@immutable
class Friendship {
  const Friendship({
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    required this.profile,
    required this.isRequester,
  });

  /// The user who initiated the friend record.
  final String userId;
  /// The target user of the friend record.
  final String friendId;
  /// Current status of this friendship record.
  final FriendStatus status;
  /// When this record was created.
  final DateTime createdAt;
  /// The OTHER user's profile (the friend or requester).
  final FriendProfile profile;
  /// True if the current user is the one who created this record (sent the request).
  final bool isRequester;

  /// The other user's ID (the friend's ID from the current user's perspective).
  String get otherUserId => profile.id;

  factory Friendship.fromMap(
    Map<String, dynamic> row,
    String viewerId,
    Map<String, FriendProfile> profiles,
  ) {
    final userId = _asString(row['user_id']);
    final friendId = _asString(row['friend_id']);
    final createdAt = _parseDateTime(row['created_at']);
    final status = FriendStatusX.fromString(row['status'] as String?);
    final isRequester = userId == viewerId;

    final requesterProfile =
        profiles[userId] ?? const FriendProfile(id: '', nickname: '');
    final addresseeProfile =
        profiles[friendId] ?? const FriendProfile(id: '', nickname: '');
    final profile = isRequester ? addresseeProfile : requesterProfile;

    return Friendship(
      userId: userId,
      friendId: friendId,
      status: status,
      createdAt: createdAt,
      profile: profile,
      isRequester: isRequester,
    );
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

  @override
  int get hashCode => Object.hash(
        userId,
        friendId,
        status,
        createdAt,
        profile,
        isRequester,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friendship &&
        other.userId == userId &&
        other.friendId == friendId &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.profile == profile &&
        other.isRequester == isRequester;
  }
}

// Re-export for convenience in providers/repository.
export 'friend_profile.dart';
export 'friend_search_result.dart';
export 'friend_status.dart';
