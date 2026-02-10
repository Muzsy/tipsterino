import 'package:flutter/widgets.dart';

import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';

@Deprecated(
  'Legacy register screen is retired. Use SignUpWizardScreen via /auth/register.',
)
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpWizardScreen();
  }
}
