import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import '../../domain/friendship.dart';

/// List item for an incoming pending friend request.
///
/// Shows requester nickname with initials-based avatar fallback,
/// and accept/decline buttons with loading states.
class FriendRequestItem extends StatelessWidget {
  const FriendRequestItem({
    super.key,
    required this.friendship,
    required this.onAccept,
    required this.onDecline,
    this.isAccepting = false,
    this.isDeclining = false,
  });

  final Friendship friendship;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isAccepting;
  final bool isDeclining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nickname = friendship.profile.nickname;
    final loc = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
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
          loc.friends_request_subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDeclining)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                ),
                tooltip: loc.friends_accept,
                onPressed: onAccept,
              ),
            if (isAccepting || isDeclining)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: colorScheme.error,
                ),
                tooltip: loc.friends_decline,
                onPressed: onDecline,
              ),
          ],
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
