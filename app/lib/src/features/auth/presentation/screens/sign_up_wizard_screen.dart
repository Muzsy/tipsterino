import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/signup_wizard_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/sign_up_wizard_step1.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/sign_up_wizard_step2.dart';
import 'package:tipsterino/src/features/auth/presentation/widgets/sign_up_wizard_step3.dart';

class SignUpWizardScreen extends ConsumerStatefulWidget {
  const SignUpWizardScreen({super.key});

  @override
  ConsumerState<SignUpWizardScreen> createState() => _SignUpWizardScreenState();
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
                child: _buildStepContent(
                  state: state,
                  loc: loc,
                  isOffline: isOffline,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.stepIndex > 0)
                    TextButton(
                      onPressed: () => ref
                          .read(signupWizardProvider.notifier)
                          .previousStep(),
                      child: Text(loc.common_back),
                    )
                  else
                    const SizedBox(width: 88),
                  if (state.stepIndex == 2)
                    ElevatedButton(
                      onPressed: _submitEnabled(state, isOffline)
                          ? () async {
                              await _onSubmit();
                            }
                          : null,
                      child: state.isSubmitting
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(loc.auth_signup_submit_loading),
                              ],
                            )
                          : Text(loc.auth_signup_submit),
                    )
                  else
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

  Widget _buildStepContent({
    required SignupWizardState state,
    required AppLocalizations loc,
    required bool isOffline,
  }) {
    switch (state.stepIndex) {
      case 0:
        return SignUpWizardStep1(
          state: state,
          loc: loc,
          isOffline: isOffline,
          emailController: _emailController,
          passwordController: _passwordController,
        );
      case 1:
        return SignUpWizardStep2(
          state: state,
          loc: loc,
          isOffline: isOffline,
          nicknameController: _nicknameController,
          onAvatarPickerPressed: () => _showAvatarPicker(context, state, loc),
          avatarLabel: _avatarLabel,
        );
      case 2:
        return SignUpWizardStep3(
          state: state,
          loc: loc,
          isOffline: isOffline,
          onTermsChanged: (accepted) => ref
              .read(signupWizardProvider.notifier)
              .toggleTermsAccepted(accepted),
          onPrivacyChanged: (accepted) => ref
              .read(signupWizardProvider.notifier)
              .togglePrivacyAccepted(accepted),
          avatarLabel: _avatarLabel,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _submitEnabled(SignupWizardState state, bool isOffline) {
    if (isOffline) return false;
    if (state.isSubmitting) return false;
    return state.step1Valid && state.step2Valid && state.step3Valid;
  }

  Future<void> _onSubmit() async {
    final success = await ref
        .read(signupWizardProvider.notifier)
        .submitSignUp();
    if (!mounted || !success) return;
    final email = ref.read(signupWizardProvider).email;
    final encodedEmail = Uri.encodeComponent(email);
    context.go('/auth/verify-pending?email=$encodedEmail');
  }

  String _avatarLabel(String key) {
    if (key.isEmpty) return '';
    return key
        .split('_')
        .map(
          (segment) => segment.isEmpty
              ? ''
              : segment[0].toUpperCase() + segment.substring(1),
        )
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
