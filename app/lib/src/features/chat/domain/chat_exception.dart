/// Chat-specific error codes.
///
/// These are intentionally narrow — scoped to the 1:1 messaging
/// bounded context defined in the frozen scope.
///
/// NOTE: `toLocalizedMessage()` was removed from domain — localization
/// must be handled at the presentation layer using AppLocalizations.
class ChatException implements Exception {
  const ChatException(this.code);

  /// Machine-readable error code.
  final String code;

  /// ARB key for AppLocalizations lookup at presentation layer.
  String get localizedKey {
    switch (code) {
      case 'empty':
        return 'chat_error_empty';
      case 'too_long':
        return 'chat_error_too_long';
      case 'invalid_participants':
        return 'chat_error_generic';
      case 'send_failed':
      default:
        return 'chat_error_generic';
    }
  }

  @override
  String toString() => 'ChatException(code: $code)';
}
