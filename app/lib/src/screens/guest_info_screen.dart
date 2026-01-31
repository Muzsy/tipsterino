import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class GuestInfoScreen extends StatelessWidget {
  const GuestInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.guestInfoTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.guestInfoBody,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(loc.guestInfoLoginCta),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/auth/register'),
              child: Text(loc.guestInfoRegisterCta),
            ),
          ],
        ),
      ),
    );
  }
}
