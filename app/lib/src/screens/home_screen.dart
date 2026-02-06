import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/rewards/presentation/daily_bonus_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isGuest =
        authState.status == AuthStatus.offline ||
        authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      appBar: AppBar(title: Text(loc.homeTab)),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: isGuest
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.homeGuestLoginCta,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/auth/login'),
                      child: Text(loc.homeGuestLoginCta),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/auth/register'),
                      child: Text(loc.homeGuestRegisterCta),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DailyBonusTile(),
                    const SizedBox(height: 24),
                    Text(
                      loc.homeAuthPlaceholder,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
      ),
    );
  }
}
