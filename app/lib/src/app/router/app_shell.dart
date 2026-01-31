import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final tabs = isAuthenticated ? _authTabs(loc) : _guestTabs(loc);
    final location = router.state.uri.path;

    final selectedIndex = tabs.indexWhere(
      (entry) => location.startsWith(entry.path),
    );
    final currentIndex = selectedIndex == -1 ? 0 : selectedIndex;

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          final destination = tabs[index].path;
          if (router.state.uri.path != destination) {
            router.go(destination);
          }
        },
        items: tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }

  static List<_ShellTab> _guestTabs(AppLocalizations loc) => [
    _ShellTab(path: '/home', icon: Icons.home, label: loc.homeTab),
    _ShellTab(path: '/bets', icon: Icons.sports_handball, label: loc.betsTab),
    _ShellTab(path: '/forum', icon: Icons.forum, label: loc.forumTab),
  ];

  static List<_ShellTab> _authTabs(AppLocalizations loc) => [
    _ShellTab(path: '/home', icon: Icons.home, label: loc.homeTab),
    _ShellTab(path: '/profile', icon: Icons.person, label: loc.profileTab),
    _ShellTab(path: '/settings', icon: Icons.settings, label: loc.settingsTab),
  ];
}

class _ShellTab {
  final String path;
  final IconData icon;
  final String label;
  const _ShellTab({
    required this.path,
    required this.icon,
    required this.label,
  });
}
