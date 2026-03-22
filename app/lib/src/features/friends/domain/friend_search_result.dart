import 'package:flutter/foundation.dart';

import 'friend_profile.dart';
import 'friend_status.dart';

/// Result of a public profile search within the friends feature.
@immutable
class FriendSearchResult {
  const FriendSearchResult({
    required this.profile,
    this.status,
    this.isRequester = false,
  });

  final FriendProfile profile;
  final FriendStatus? status;
  final bool isRequester;

  /// True if the current user can send a friend request to this profile.
  /// Allowed when there is no existing relationship or the existing
  /// relationship was rejected.
  bool get canSendRequest =>
      status == null ||
      status == FriendStatus.rejected ||
      (status == FriendStatus.pending && !isRequester);

  /// True if this profile is already an accepted friend.
  bool get isFriend => status == FriendStatus.accepted;

  @override
  int get hashCode => Object.hash(profile, status, isRequester);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendSearchResult &&
        other.profile == profile &&
        other.status == status &&
        other.isRequester == isRequester;
  }
}
