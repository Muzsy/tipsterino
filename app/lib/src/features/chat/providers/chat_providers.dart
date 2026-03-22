import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';

import '../data/chat_repository.dart';
import '../domain/chat_message.dart';

/// Provides the [ChatRepository] using Tipsterino's [supabaseConfigProvider].
///
/// Do NOT use the global `Supabase.instance.client` singleton.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  return ChatRepository(config);
});

/// Stream of [ChatMessage] list for the conversation with [friendId].
///
/// The stream is empty if the current user is not authenticated.
/// Uses `autoDispose` so the subscription is cleaned up when the
/// screen is disposed — satisfying the realtime lifecycle requirement.
final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, friendId) {
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.session?.user.id;

    if (currentUserId == null || currentUserId.isEmpty) {
      return Stream.value(const <ChatMessage>[]);
    }

    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchConversation(
      currentUserId: currentUserId,
      otherUserId: friendId,
    );
  },
);
