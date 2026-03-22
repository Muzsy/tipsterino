/// Chat-specific error codes.
///
/// These are intentionally narrow — scoped to the 1:1 messaging
/// bounded context defined in the frozen scope.
class ChatException implements Exception {
  const ChatException(this.code);

  /// Machine-readable error code.
  final String code;

  /// Returns a human-readable message for the given error code.
  String toLocalizedMessage() {
    switch (code) {
      case 'empty':
        return 'Cannot send an empty message.';
      case 'too_long':
        return 'Message is too long (max 2000 characters).';
      case 'invalid_participants':
        return 'Invalid sender or receiver.';
      case 'send_failed':
      default:
        return 'Failed to send message. Please try again.';
    }
  }

  @override
  String toString() => 'ChatException(code: $code)';
}
