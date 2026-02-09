import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';

class SignUpWizardStep2 extends StatelessWidget {
  const SignUpWizardStep2({
    super.key,
    required this.state,
    required this.loc,
    required this.isOffline,
    required this.nicknameController,
    required this.onAvatarPickerPressed,
    required this.avatarLabel,
  });

  final SignupWizardState state;
  final AppLocalizations loc;
  final bool isOffline;
  final TextEditingController nicknameController;
  final VoidCallback onAvatarPickerPressed;
  final String Function(String key) avatarLabel;

  @override
  Widget build(BuildContext context) {
    final statusWidget = _buildNicknameStatus(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.auth_signup_step_profile,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nicknameController,
            decoration: InputDecoration(
              labelText: loc.auth_nickname_label,
              helperText: loc.auth_nickname_help,
              errorText: _nicknameFieldError(),
            ),
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.text,
            autocorrect: false,
          ),
          if (statusWidget != null) ...[
            const SizedBox(height: 8),
            statusWidget,
          ],
          const SizedBox(height: 24),
          Text(
            loc.auth_avatar_label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  state.avatarKey.isNotEmpty
                      ? state.avatarKey[0].toUpperCase()
                      : '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avatarLabel(state.avatarKey),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    TextButton(
                      onPressed: onAvatarPickerPressed,
                      child: Text(loc.auth_avatar_change),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isOffline) ...[
            const SizedBox(height: 24),
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

  Widget? _buildNicknameStatus(BuildContext context) {
    final status = state.nicknameStatus;
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case NicknameAvailabilityStatus.tooShort:
        return Text(
          loc.auth_nickname_too_short,
          style: TextStyle(color: scheme.error),
        );
      case NicknameAvailabilityStatus.checking:
        return Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(loc.auth_nickname_checking),
          ],
        );
      case NicknameAvailabilityStatus.available:
        return Row(
          children: [
            Icon(Icons.check_circle, color: scheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              loc.auth_nickname_available,
              style: TextStyle(color: scheme.primary),
            ),
          ],
        );
      case NicknameAvailabilityStatus.unavailable:
        return Text(
          loc.auth_nickname_unavailable,
          style: TextStyle(color: scheme.error),
        );
      case NicknameAvailabilityStatus.error:
        return Text(
          loc.auth_nickname_error,
          style: TextStyle(color: scheme.error),
        );
      default:
        return null;
    }
  }

  String? _nicknameFieldError() {
    if (state.nicknameStatus == NicknameAvailabilityStatus.invalid) {
      return loc.auth_nickname_help;
    }
    if (state.nicknameStatus == NicknameAvailabilityStatus.error) {
      return loc.auth_nickname_error;
    }
    return null;
  }
}
