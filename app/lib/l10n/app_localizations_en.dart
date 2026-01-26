// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tipsterino';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitle => 'Access your Tipsterino profile.';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle => 'Create a new Tipsterino account.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRepeatLabel => 'Confirm password';

  @override
  String get enterPasswordError => 'Please enter a password';

  @override
  String get invalidEmailError => 'Please enter a valid email';

  @override
  String get passwordMismatchError => 'Passwords must match';

  @override
  String get logInButton => 'Log in';

  @override
  String get registerButton => 'Register';

  @override
  String get dontHaveAccountPrompt => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get offlineNotice => 'Supabase not configured';

  @override
  String get offlineDescription => 'Define SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define to enable authentication.';

  @override
  String get authGenericError => 'Authentication failed';

  @override
  String get registerSuccess => 'Account created! Check your inbox for confirmation.';

  @override
  String get homeTab => 'Home';

  @override
  String get ticketsTab => 'Tickets';

  @override
  String get leaderboardTab => 'Leaderboard';

  @override
  String get settingsTab => 'Settings';

  @override
  String get logoutLabel => 'Log out';

  @override
  String get common_next => 'Next';

  @override
  String get common_back => 'Back';

  @override
  String get common_coming_next => 'Coming next';

  @override
  String get auth_signup_step_account => 'Step 1 – Account';

  @override
  String get auth_signup_step_profile => 'Step 2 – Profile';

  @override
  String get auth_signup_step_consent => 'Step 3 – Consent';

  @override
  String get auth_password_rule_min_length => 'At least 8 characters';

  @override
  String get auth_password_rule_uppercase => 'Contains an uppercase letter';

  @override
  String get auth_password_rule_lowercase => 'Contains a lowercase letter';

  @override
  String get auth_password_rule_number => 'Contains a number';
}
