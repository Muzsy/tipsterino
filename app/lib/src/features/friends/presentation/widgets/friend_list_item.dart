import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import '../../domain/friendship.dart';

/// List item for an accepted friend row.
///
/// Shows friend nickname with initials-based avatar fallback,
/// a chat action button, and a remove action.
class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.friendship,
    required this.onMessage,
    required this.onRemove,
    this.isRemovalInProgress = false,
  });

  final Friendship friendship;
  final VoidCallback onMessage;
  final VoidCallback onRemove;
  final bool isRemovalInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nickname = friendship.profile.nickname;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: _Avatar(friendId: friendship.otherUserId, nickname: nickname),
        title: Text(
          nickname,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: isRemovalInProgress
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_outlined),
                    tooltip: AppLocalizations.of(context)!.friends_open_chat,
                    onPressed: onMessage,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_remove_outlined,
                      color: colorScheme.error,
                    ),
                    tooltip: AppLocalizations.of(context)!.friends_remove,
                    onPressed: onRemove,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.friendId,
    required this.nickname,
  });

  final String friendId;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Initials fallback: no network image assets.
    final initials = _deriveInitials(nickname);

    return CircleAvatar(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      child: Text(
        initials,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
