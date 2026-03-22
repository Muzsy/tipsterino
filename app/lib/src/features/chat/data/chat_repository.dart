import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

import '../domain/chat_exception.dart';
import '../domain/chat_message.dart';

/// 1:1 direct messaging repository backed by Supabase.
///
/// Uses the `messages` table with realtime subscriptions to deliver
/// a live conversation stream between two authenticated profiles.
class ChatRepository {
  ChatRepository(this._config);

  final SupabaseConfiguration _config;

  /// Watches the 1:1 conversation between [currentUserId] and [otherUserId].
  ///
  /// Returns an empty stream if either ID is empty.
  /// The stream emits the full conversation ordered by `created_at` ascending
  /// (oldest first), matching the TippmixApp behaviour.
  Stream<List<ChatMessage>> watchConversation({
    required String currentUserId,
    required String otherUserId,
  }) {
    if (currentUserId.isEmpty || otherUserId.isEmpty) {
      return Stream.value(const <ChatMessage>[]);
    }

    final client = _config.client;
    if (client == null) {
      return Stream.value(const <ChatMessage>[]);
    }

    final participants = [currentUserId, otherUserId];

    return client
        .from('messages')
        .stream(primaryKey: const ['id'])
        .inFilter('sender_id', participants)
        .order('created_at', ascending: true)
        .map((rows) {
          final list = rows.cast<Map<String, dynamic>>();
          return list
              .map(ChatMessage.fromMap)
              .where(
                (message) =>
                    (message.senderId == currentUserId &&
                        message.receiverId == otherUserId) ||
                    (message.senderId == otherUserId &&
                        message.receiverId == currentUserId),
              )
              .toList();
        });
  }

  /// Sends a trimmed text message from [senderId] to [receiverId].
  ///
  /// Throws [ChatException] on validation failure or on a Supabase error.
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final trimmed = content.trim();

    if (trimmed.isEmpty) {
      throw const ChatException('empty');
    }
    if (trimmed.length > 2000) {
      throw const ChatException('too_long');
    }
    if (senderId.isEmpty || receiverId.isEmpty) {
      throw const ChatException('invalid_participants');
    }

    final client = _config.client;
    if (client == null) {
      throw const ChatException('send_failed');
    }

    try {
      await client.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': trimmed,
      });
    } on sb.PostgrestException catch (error) {
      throw ChatException(error.code ?? 'send_failed');
    } catch (_) {
      throw const ChatException('send_failed');
    }
  }

  /// Marks all unread incoming messages from [friendId] to [currentUserId] as read.
  ///
  /// Targets only: receiver_id = currentUserId, sender_id = friendId, read_at is null.
  /// Uses now() as the read timestamp.
  ///
  /// This operation is idempotent — re-running it updates rows that are already
  /// marked read with the same timestamp, causing no functional harm.
  ///
  /// Returns silently (no throw) if the client is unavailable.
  Future<void> markConversationAsRead({
    required String currentUserId,
    required String friendId,
  }) async {
    if (currentUserId.isEmpty || friendId.isEmpty) return;

    final client = _config.client;
    if (client == null) return;

    try {
      await client.from('messages').update({
        'read_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('receiver_id', currentUserId).eq('sender_id', friendId).is_('read_at', null);
    } catch (_) {
      // Silently ignore errors — read marking is best-effort.
    }
  }
}
