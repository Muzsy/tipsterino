import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/chat/data/chat_repository.dart';
import 'package:tipsterino/src/features/chat/domain/chat_exception.dart';
import 'package:tipsterino/src/features/chat/domain/chat_message.dart';
import 'package:tipsterino/src/features/chat/providers/chat_providers.dart';

/// 1:1 direct messaging screen.
///
/// Accessible at `/chat/:friendId` for authenticated users.
/// Realtime message stream via [chatMessagesProvider].
/// Send via [ChatRepository.sendMessage].
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.friendId,
  });

  final String friendId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _readMarked = false;

  @override
  void initState() {
    super.initState();
    // Mark unread incoming messages as read once when the screen mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markReadIfNeeded();
    });
  }

  void _markReadIfNeeded() {
    if (_readMarked) return;
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.session?.user.id;
    if (currentUserId == null || currentUserId.isEmpty) return;
    _readMarked = true;
    final repository = ref.read(chatRepositoryProvider);
    repository.markConversationAsRead(
      currentUserId: currentUserId,
      friendId: widget.friendId,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_isSending) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final authState = ref.read(authNotifierProvider);
    final senderId = authState.session?.user.id;
    if (senderId == null || senderId.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendMessage(
        senderId: senderId,
        receiverId: widget.friendId,
        content: text,
      );
      _textController.clear();
      _scrollToBottom();
    } on ChatException catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      final key = e.localizedKey;
      final message = key == 'chat_error_empty'
          ? loc.chat_error_empty
          : key == 'chat_error_too_long'
              ? loc.chat_error_too_long
              : loc.chat_error_generic;
      _showError(message);
    } catch (_) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.chat_error_generic);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.friendId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chat_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          loc.chat_empty_state,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(
                        message: messages[index],
                        isMine: messages[index].senderId ==
                            ref.read(authNotifierProvider).session?.user.id,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      loc.chat_error_generic,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            _MessageInputBar(
              controller: _textController,
              enabled: !_isSending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMine ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: (isMine
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant)
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: loc.chat_message_hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: enabled
                ? const Icon(Icons.send)
                : const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
          ),
        ],
      ),
    );
  }
}
