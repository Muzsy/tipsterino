/// Friend-operation-specific error codes.
///
/// Narrow exception scoped to the bounded friends context.
/// Localization is handled at the presentation layer via AppLocalizations
/// (consistent with the ChatException pattern).
class FriendOperationException implements Exception {
  const FriendOperationException(this.code);

  /// Machine-readable error code.
  final String code;

  /// ARB localization key for AppLocalizations lookup at presentation layer.
  String get localizedKey {
    switch (code) {
      case 'self_friendship':
        return 'friends_error_self';
      case 'already_friends':
        return 'friends_error_already_friends';
      case 'request_exists':
        return 'friends_error_request_exists';
      case 'incoming_exists':
        return 'friends_error_incoming_exists';
      case 'request_missing':
        return 'friends_error_request_missing';
      case 'not_pending':
        return 'friends_error_not_pending';
      case 'friendship_not_found':
        return 'friends_error_not_found';
      case 'operation_failed':
      default:
        return 'friends_error_generic';
    }
  }

  @override
  String toString() => 'FriendOperationException(code: $code)';
}
