import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';

class SignUpWizardScreen extends ConsumerStatefulWidget {
  const SignUpWizardScreen({super.key});

  @override
  ConsumerState<SignUpWizardScreen> createState() =>
      _SignUpWizardScreenState();
}

class _SignUpWizardScreenState extends ConsumerState<SignUpWizardScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_onEmailChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onPasswordChanged)
      ..dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    ref.read(signupWizardProvider.notifier).updateEmail(_emailController.text);
  }

  void _onPasswordChanged() {
    ref
        .read(signupWizardProvider.notifier)
        .updatePassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(signupWizardProvider);
    final isOffline = !ref.watch(supabaseConfigProvider).isConfigured;
    return Scaffold(
      appBar: AppBar(title: Text(loc.registerTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _stepTitle(state.stepIndex, loc),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildStepContent(state, loc, isOffline),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.stepIndex > 0)
                    TextButton(
                      onPressed: () =>
                          ref.read(signupWizardProvider.notifier).previousStep(),
                      child: Text(loc.common_back),
                    )
                  else
                    const SizedBox(width: 88),
                  ElevatedButton(
                    onPressed: _nextEnabled(state, isOffline)
                        ? () {
                            if (state.stepIndex < 2) {
                              ref
                                  .read(signupWizardProvider.notifier)
                                  .nextStep();
                            }
                          }
                        : null,
                    child: Text(loc.common_next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle(int stepIndex, AppLocalizations loc) {
    switch (stepIndex) {
      case 1:
        return loc.auth_signup_step_profile;
      case 2:
        return loc.auth_signup_step_consent;
      default:
        return loc.auth_signup_step_account;
    }
  }

  Widget _buildStepContent(
      SignupWizardState state, AppLocalizations loc, bool isOffline) {
    if (state.stepIndex == 0) {
      return _buildAccountStep(state, loc, isOffline);
    }
    final comingNext =
        state.stepIndex == 1 ? loc.auth_signup_step_profile : loc.auth_signup_step_consent;
    final description =
        state.stepIndex == 1 ? loc.common_coming_next : loc.common_coming_next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comingNext,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Center(
          child: Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStep(
    SignupWizardState state,
    AppLocalizations loc,
    bool isOffline,
  ) {
    final rules = <_PasswordRule>[
      _PasswordRule(loc.auth_password_rule_min_length, state.hasMinLength),
      _PasswordRule(loc.auth_password_rule_uppercase, state.hasUppercase),
      _PasswordRule(loc.auth_password_rule_lowercase, state.hasLowercase),
      _PasswordRule(loc.auth_password_rule_number, state.hasNumber),
    ];
    final unsatisfied = rules.where((rule) => !rule.isSatisfied).toList();
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
            controller: _emailController,
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
            controller: _passwordController,
            decoration: InputDecoration(labelText: loc.passwordLabel),
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 16),
          if (unsatisfied.isNotEmpty) ...[
            Text(
              loc.passwordLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ...unsatisfied.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rule.label)),
                  ],
                ),
              ),
            ),
          ],
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

  bool _nextEnabled(SignupWizardState state, bool isOffline) {
    if (isOffline) return false;
    if (state.stepIndex == 0) {
      return state.step1Valid;
    }
    return state.stepIndex < 2;
  }
}

class _PasswordRule {
  final String label;
  final bool isSatisfied;

  _PasswordRule(this.label, this.isSatisfied);
}
