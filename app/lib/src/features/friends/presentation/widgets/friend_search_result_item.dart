import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import '../../domain/friend_search_result.dart';
import '../../domain/friend_status.dart';

/// List item for a public profile search result within the friends feature.
///
/// Shows the profile nickname with initials-based avatar fallback,
/// the current friendship status, and appropriate action buttons.
class FriendSearchResultItem extends StatelessWidget {
  const FriendSearchResultItem({
    super.key,
    required this.result,
    required this.onSendRequest,
    required this.onOpenChat,
    required this.onRemoveFriend,
    this.isProcessing = false,
    this.isRemoveInProgress = false,
  });

  final FriendSearchResult result;
  final VoidCallback onSendRequest;
  final VoidCallback? onOpenChat;
  final VoidCallback? onRemoveFriend;
  final bool isProcessing;
  final bool isRemoveInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final nickname = result.profile.nickname;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
          child: Text(
            _deriveInitials(nickname),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nickname,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          _statusLabel(loc),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: _actionButton(context, loc, colorScheme),
      ),
    );
  }

  String _statusLabel(AppLocalizations loc) {
    if (result.isFriend) return loc.friends_status_friend;
    if (result.status == FriendStatus.pending) {
      return result.isRequester
          ? loc.friends_status_request_sent
          : loc.friends_status_request_received;
    }
    return '';
  }

  Widget? _actionButton(
    BuildContext context,
    AppLocalizations loc,
    ColorScheme colorScheme,
  ) {
    if (isProcessing || isRemoveInProgress) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (result.isFriend) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: loc.friends_open_chat,
            onPressed: onOpenChat,
          ),
          IconButton(
            icon: Icon(
              Icons.person_remove_outlined,
              color: colorScheme.error,
            ),
            tooltip: loc.friends_remove,
            onPressed: onRemoveFriend,
          ),
        ],
      );
    }

    if (result.canSendRequest) {
      return IconButton(
        icon: Icon(
          Icons.person_add_outlined,
          color: colorScheme.primary,
        ),
        tooltip: loc.friends_send_request,
        onPressed: onSendRequest,
      );
    }

    return const SizedBox.shrink();
  }

  String _deriveInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length.clamp(0, 2)).toUpperCase();
  }
}
