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
  static const _avatarOptions = ['neutral', 'golden_mask', 'arcade'];

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_onEmailChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onPasswordChanged)
      ..dispose();
    _nicknameController
      ..removeListener(_onNicknameChanged)
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

  void _onNicknameChanged() {
    ref
        .read(signupWizardProvider.notifier)
        .updateNickname(_nicknameController.text);
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
    switch (state.stepIndex) {
      case 0:
        return _buildAccountStep(state, loc, isOffline);
      case 1:
        return _buildProfileStep(state, loc, isOffline);
      default:
        return _buildPlaceholderStep(state, loc);
    }
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
      _PasswordRule(loc.auth_password_rule_special, state.hasSpecialChar),
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

  Widget _buildProfileStep(
    SignupWizardState state,
    AppLocalizations loc,
    bool isOffline,
  ) {
    final statusWidget = _buildNicknameStatus(state, loc);
    final nicknameError = _nicknameFieldError(state.nicknameStatus, loc);
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
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: loc.auth_nickname_label,
              helperText: loc.auth_nickname_help,
              errorText: nicknameError,
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
                      _avatarLabel(state.avatarKey),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    TextButton(
                      onPressed: () => _showAvatarPicker(context, state, loc),
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

  Widget _buildPlaceholderStep(SignupWizardState state, AppLocalizations loc) {
    final description = loc.common_coming_next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.stepIndex == 2
              ? loc.auth_signup_step_consent
              : loc.common_coming_next,
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

  Widget? _buildNicknameStatus(
    SignupWizardState state,
    AppLocalizations loc,
  ) {
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

  String? _nicknameFieldError(
      NicknameAvailabilityStatus status, AppLocalizations loc) {
    if (status == NicknameAvailabilityStatus.invalid) {
      return loc.auth_nickname_help;
    }
    if (status == NicknameAvailabilityStatus.error) {
      return loc.auth_nickname_error;
    }
    return null;
  }

  String _avatarLabel(String key) {
    if (key.isEmpty) return '';
    return key
        .split('_')
        .map((segment) => segment.isEmpty
            ? ''
            : segment[0].toUpperCase() + segment.substring(1))
        .join(' ');
  }

  void _showAvatarPicker(
    BuildContext context,
    SignupWizardState state,
    AppLocalizations loc,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (pickerContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.auth_avatar_sheet_title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _avatarOptions.map((option) {
                  final selected = option == state.avatarKey;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(signupWizardProvider.notifier)
                          .updateAvatarKey(option);
                      Navigator.of(pickerContext).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              child: Text(option[0].toUpperCase()),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _avatarLabel(option),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(pickerContext).pop(),
                  child: Text(loc.common_done),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _nextEnabled(SignupWizardState state, bool isOffline) {
    if (isOffline) return false;
    if (state.stepIndex == 0) return state.step1Valid;
    if (state.stepIndex == 1) return state.step2Valid;
    return false;
  }
}

class _PasswordRule {
  final String label;
  final bool isSatisfied;

  _PasswordRule(this.label, this.isSatisfied);
}
