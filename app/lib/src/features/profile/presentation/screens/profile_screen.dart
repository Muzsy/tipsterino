import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.profileTab)),
      body: ListView(
        children: [
          // Profile info placeholder
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.profileTab,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const Divider(),
          // Friends entry point — minimal, no redesign.
          ListTile(
            leading: Icon(
              Icons.group_outlined,
              color: colorScheme.primary,
            ),
            title: Text(loc.friends_title),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.pushNamed('friends'),
          ),
        ],
      ),
    );
  }
}
