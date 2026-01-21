import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final loc = AppLocalizations.of(context)!;
    final location = router.state.uri.path;
    final tabs = <_ShellTab>[
      _ShellTab(path: '/home', icon: Icons.home, label: loc.homeTab),
      _ShellTab(
        path: '/tickets',
        icon: Icons.confirmation_number,
        label: loc.ticketsTab,
      ),
      _ShellTab(
        path: '/leaderboard',
        icon: Icons.emoji_events,
        label: loc.leaderboardTab,
      ),
      _ShellTab(
        path: '/settings',
        icon: Icons.settings,
        label: loc.settingsTab,
      ),
    ];

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
