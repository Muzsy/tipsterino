import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/password_rules.dart';

class SignUpWizardStep1 extends StatelessWidget {
  const SignUpWizardStep1({
    super.key,
    required this.state,
    required this.loc,
    required this.isOffline,
    required this.emailController,
    required this.passwordController,
  });

  final SignupWizardState state;
  final AppLocalizations loc;
  final bool isOffline;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.auth_signup_step_account,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: loc.emailLabel,
              errorText: state.email.isEmpty
                  ? null
                  : (state.isEmailValid ? null : loc.invalidEmailError),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: loc.passwordLabel),
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 16),
          PasswordRules(
            title: loc.passwordLabel,
            rules: [
              PasswordRuleData(
                label: loc.auth_password_rule_min_length,
                isSatisfied: state.hasMinLength,
              ),
              PasswordRuleData(
                label: loc.auth_password_rule_uppercase,
                isSatisfied: state.hasUppercase,
              ),
              PasswordRuleData(
                label: loc.auth_password_rule_lowercase,
                isSatisfied: state.hasLowercase,
              ),
              PasswordRuleData(
                label: loc.auth_password_rule_special,
                isSatisfied: state.hasSpecialChar,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isOffline) ...[
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
}
