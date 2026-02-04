import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isOffline = !ref.watch(supabaseConfigProvider).isConfigured;
    final userEmail = authState.session?.user.email;
    final canLogout =
        authState.status == AuthStatus.authenticated && !isOffline;
    final canOpenEvents =
        authState.status == AuthStatus.authenticated && !isOffline;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTab)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.settingsTab,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              userEmail ?? loc.offlineNotice,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: canLogout
                  ? () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(loc.logoutLabel)),
                          );
                      }
                    }
                  : null,
              child: Text(loc.logoutLabel),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inbox),
              title: Text(loc.eventsInboxEntry),
              trailing: const Icon(Icons.chevron_right),
              enabled: canOpenEvents,
              onTap: canOpenEvents ? () => context.goNamed('events') : null,
            ),
            if (isOffline) ...[
              const SizedBox(height: 12),
              Text(
                loc.offlineNotice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                loc.offlineDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
