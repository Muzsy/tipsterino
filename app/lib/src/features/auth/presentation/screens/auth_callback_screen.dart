import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_callback_provider.dart';

class AuthCallbackScreen extends ConsumerStatefulWidget {
  final Uri uri;

  const AuthCallbackScreen({super.key, required this.uri});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _scheduleProcessing();
  }

  void _scheduleProcessing() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authCallbackProvider.notifier).process(widget.uri);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(authCallbackProvider);
    final hasEmail = (state.email?.isNotEmpty ?? false);
    final message = _buildStateMessage(state, loc, hasEmail);

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
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              if (state.message != null && state.message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  state.message!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const Spacer(),
              _buildActionArea(context, state, hasEmail, loc),
            ],
          ),
        ),
      ),
    );
  }

  String _buildStateMessage(
    AuthCallbackState state,
    AppLocalizations loc,
    bool hasEmail,
  ) {
    switch (state.status) {
      case AuthCallbackStatus.processing:
        return loc.auth_callback_processing;
      case AuthCallbackStatus.success:
        return loc.auth_callback_success;
      case AuthCallbackStatus.expired:
        return loc.auth_callback_expired;
      case AuthCallbackStatus.error:
        return loc.auth_callback_error_generic;
    }
  }

  Widget _buildActionArea(
    BuildContext context,
    AuthCallbackState state,
    bool hasEmail,
    AppLocalizations loc,
  ) {
    switch (state.status) {
      case AuthCallbackStatus.processing:
        return const Center(child: CircularProgressIndicator());
      case AuthCallbackStatus.success:
        return Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: Text(loc.auth_callback_continue),
          ),
        );
      case AuthCallbackStatus.expired:
      case AuthCallbackStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: Text(loc.auth_callback_back_to_login),
            ),
            if (hasEmail) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.go(
                  '/auth/verify-pending?email=${Uri.encodeQueryComponent(state.email!)}',
                ),
                child: Text(loc.auth_callback_resend),
              ),
            ],
          ],
        );
    }
  }
}
