import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';

class SignUpWizardStep3 extends StatelessWidget {
  const SignUpWizardStep3({
    super.key,
    required this.state,
    required this.loc,
    required this.isOffline,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.avatarLabel,
  });

  final SignupWizardState state;
  final AppLocalizations loc;
  final bool isOffline;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final String Function(String key) avatarLabel;

  @override
  Widget build(BuildContext context) {
    final errorText = state.submitError;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.auth_consent_title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(context),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: state.termsAccepted,
            onChanged: (value) => onTermsChanged(value ?? false),
            title: Text(loc.auth_consent_terms_label),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: state.privacyAccepted,
            onChanged: (value) => onPrivacyChanged(value ?? false),
            title: Text(loc.auth_consent_privacy_label),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              loc.auth_signup_submit_error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 4),
            Text(
              errorText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (isOffline) ...[
            const SizedBox(height: 16),
            Text(
              loc.offlineNotice,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              loc.offlineDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow(context, loc.emailLabel, state.email),
            _summaryRow(
              context,
              loc.auth_nickname_label,
              state.nickname.isNotEmpty ? state.nickname : loc.auth_nickname_help,
            ),
            _summaryRow(
              context,
              loc.auth_avatar_label,
              avatarLabel(state.avatarKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
