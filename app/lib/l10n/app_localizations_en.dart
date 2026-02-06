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
  String get auth_password_rule_special => 'Contains a special character';

  @override
  String get common_done => 'Done';

  @override
  String get auth_nickname_label => 'Nickname';

  @override
  String get auth_nickname_help => '3-20 characters, lowercase letters, numbers, dot, or underscore.';

  @override
  String get auth_nickname_too_short => 'Enter at least 3 characters.';

  @override
  String get auth_nickname_checking => 'Checking availability...';

  @override
  String get auth_nickname_available => 'Nickname available';

  @override
  String get auth_nickname_unavailable => 'Nickname already taken';

  @override
  String get auth_nickname_error => 'Unable to verify nickname';

  @override
  String get auth_avatar_label => 'Avatar';

  @override
  String get auth_avatar_change => 'Change avatar';

  @override
  String get auth_avatar_sheet_title => 'Choose an avatar';

  @override
  String get auth_consent_title => 'Consent';

  @override
  String get auth_consent_terms_label => 'I agree to the Terms of Service';

  @override
  String get auth_consent_privacy_label => 'I agree to the Data Processing Policy';

  @override
  String get auth_signup_submit => 'Create account';

  @override
  String get auth_signup_submit_loading => 'Creating account...';

  @override
  String get auth_signup_submit_error => 'Unable to create account';

  @override
  String get auth_verify_pending_title => 'Verify your email';

  @override
  String auth_verify_pending_body(Object email) {
    return 'We sent a verification link to $email. Please confirm to continue.';
  }

  @override
  String get auth_verify_pending_back_to_login => 'Back to login';

  @override
  String get auth_verify_pending_resend => 'Resend verification';

  @override
  String get auth_verify_pending_resend_sent => 'Verification email resent';

  @override
  String auth_verify_pending_resend_cooldown(Object seconds) {
    return 'Resend available in ${seconds}s';
  }

  @override
  String get auth_callback_title => 'Authentication callback';

  @override
  String get auth_callback_processing => 'Processing authentication callback...';

  @override
  String get auth_callback_success => 'Authentication succeeded!';

  @override
  String get auth_callback_continue => 'Continue';

  @override
  String get auth_callback_expired => 'The link is invalid or has expired.';

  @override
  String get auth_callback_error_generic => 'Unable to complete authentication. Please try logging in again.';

  @override
  String get auth_callback_resend => 'Resend verification';

  @override
  String auth_callback_error(Object error) {
    return 'Callback failed: $error';
  }

  @override
  String get auth_callback_back_to_login => 'Back to login';

  @override
  String get betsTab => 'Bets';

  @override
  String get forumTab => 'Forum';

  @override
  String get profileTab => 'Profile';

  @override
  String get guestInfoTitle => 'Guest access info';

  @override
  String get guestInfoBody => 'Enjoy a peek at Tipsterino while you decide to log in or register.';

  @override
  String get guestInfoLoginCta => 'Log in';

  @override
  String get guestInfoRegisterCta => 'Register';

  @override
  String get homeGuestLoginCta => 'Log in';

  @override
  String get homeGuestRegisterCta => 'Register';

  @override
  String get homeAuthPlaceholder => 'User stats coming soon.';

  @override
  String get eventsInboxTitle => 'Events';

  @override
  String get eventsInboxEntry => 'Events inbox';

  @override
  String get eventsEmptyTitle => 'No events yet';

  @override
  String get eventsEmptyBody => 'We will show your events here as soon as they arrive.';

  @override
  String get eventSignupBonusTitle => 'Signup bonus';

  @override
  String eventSignupBonusBody(Object amount) {
    return 'You earned $amount TippCoins as a signup bonus.';
  }

  @override
  String get daily_bonus_title => 'Daily bonus';

  @override
  String get daily_bonus_body_available => 'Claim your daily TippCoins.';

  @override
  String get daily_bonus_body_claimed => 'Already claimed today. Come back tomorrow.';

  @override
  String get daily_bonus_body_disabled => 'Daily bonus is not active.';

  @override
  String get daily_bonus_body_not_verified => 'Verify your email to claim the daily bonus.';

  @override
  String get daily_bonus_body_profile_incomplete =>
      'Complete your profile to claim the daily bonus.';

  @override
  String get daily_bonus_cta_claim => 'Claim';

  @override
  String get daily_bonus_cta_claimed => 'Claimed';

  @override
  String daily_bonus_snackbar_granted(Object amount) {
    return 'Daily bonus claimed: +$amount TippCoins!';
  }
}
