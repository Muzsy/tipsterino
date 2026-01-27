import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

class AuthCallbackScreen extends StatelessWidget {
  final String? error;

  const AuthCallbackScreen({super.key, this.error});

  bool get hasError => (error ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.auth_callback_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.auth_callback_title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                hasError
                    ? loc.auth_callback_error(error ?? '')
                    : loc.auth_callback_processing,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (hasError)
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text(loc.auth_callback_back_to_login),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
