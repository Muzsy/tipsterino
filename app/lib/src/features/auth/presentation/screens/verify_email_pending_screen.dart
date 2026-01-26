import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

class VerifyEmailPendingScreen extends StatelessWidget {
  final String email;

  const VerifyEmailPendingScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.auth_verify_pending_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.auth_verify_pending_title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                loc.auth_verify_pending_body(email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(loc.auth_verify_pending_back_to_login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
