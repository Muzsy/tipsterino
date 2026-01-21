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
  String get offlineDescription =>
      'Add SUPABASE_URL and SUPABASE_ANON_KEY in .env to enable authentication.';

  @override
  String get authGenericError => 'Authentication failed';

  @override
  String get registerSuccess =>
      'Account created! Check your inbox for confirmation.';

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
}
