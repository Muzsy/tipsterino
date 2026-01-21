import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/supabase_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final successMessage = loc.registerSuccess;
    final genericError = loc.authGenericError;
    final localContext = context;
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      _showError(AppLocalizations.of(context)!.passwordMismatchError);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (localContext.mounted) {
        ScaffoldMessenger.of(localContext)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(successMessage)));
        localContext.go('/auth/login');
      }
    } on AuthFailure catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError(genericError);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isOffline = !ref.watch(supabaseConfigProvider).isConfigured;

    return Scaffold(
      appBar: AppBar(title: Text(loc.registerTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.registerTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              loc.registerSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: loc.emailLabel),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return loc.invalidEmailError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: loc.passwordLabel),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.enterPasswordError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    decoration: InputDecoration(
                      labelText: loc.passwordRepeatLabel,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.enterPasswordError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isOffline || _isSubmitting ? null : _submit,
                    child: Text(loc.registerButton),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (isOffline) ...[
              Text(
                loc.offlineNotice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                loc.offlineDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => context.go('/auth/login'),
                child: Text(loc.alreadyHaveAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
