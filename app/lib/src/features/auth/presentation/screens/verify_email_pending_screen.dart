import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/verify_email_pending_provider.dart';

class VerifyEmailPendingScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailPendingScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailPendingScreen> createState() =>
      _VerifyEmailPendingScreenState();
}

class _VerifyEmailPendingScreenState
    extends ConsumerState<VerifyEmailPendingScreen> {
  DateTime? _lastSuccessSnackbar;

  Future<void> _onResend() async {
    await ref
        .read(verifyEmailPendingProvider.notifier)
        .resendEmail(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(verifyEmailPendingProvider);
    final cooldownSeconds = state.cooldownRemainingSeconds;
    final cooldownActive = cooldownSeconds > 0;
    final canResend =
        widget.email.isNotEmpty && cooldownSeconds == 0 && !state.isSending;
    final resendLabel = cooldownActive
        ? loc.auth_verify_pending_resend_cooldown(cooldownSeconds)
        : loc.auth_verify_pending_resend;

    if (state.lastSuccess != null &&
        state.lastSuccess != _lastSuccessSnackbar) {
      _lastSuccessSnackbar = state.lastSuccess;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.auth_verify_pending_resend_sent)),
        );
      });
    }

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
                loc.auth_verify_pending_body(widget.email),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canResend ? _onResend : null,
                child: state.isSending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(loc.auth_verify_pending_resend),
                        ],
                      )
                    : Text(resendLabel),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
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
