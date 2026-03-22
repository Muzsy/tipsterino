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
  String get eventsFilterAll => 'All';

  @override
  String get eventsFilterCredits => 'Credits';

  @override
  String get eventsFilterChallenges => 'Challenges';

  @override
  String get eventsFilterSocial => 'Social';

  @override
  String get eventsFilterSystem => 'System';

  @override
  String get eventsMarkAllReadTooltip => 'Mark all as read';

  @override
  String get eventsMarkAllReadSuccess => 'All marked as read';

  @override
  String eventsMarkAllReadPartial(Object failed, Object succeeded) {
    return 'Marked $succeeded, failed $failed';
  }

  @override
  String get eventSignupBonusTitle => 'Signup bonus';

  @override
  String eventSignupBonusBody(Object amount) {
    return 'You earned $amount TippCoins as a signup bonus.';
  }

  @override
  String get event_daily_bonus_title => 'Daily bonus';

  @override
  String event_daily_bonus_body(Object amount) {
    return 'Daily bonus credited: +$amount TippCoins.';
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
  String get daily_bonus_body_profile_incomplete => 'Complete your profile to claim the daily bonus.';

  @override
  String get daily_bonus_cta_claim => 'Claim';

  @override
  String get daily_bonus_cta_claimed => 'Claimed';

  @override
  String daily_bonus_snackbar_granted(Object amount) {
    return 'Daily bonus claimed: +$amount TippCoins!';
  }

  @override
  String get daily_bonus_body_not_configured => 'Daily bonus is unavailable (not configured).';

  @override
  String get daily_bonus_body_rate_limited => 'Too many claim attempts. Please try again shortly.';

  @override
  String get daily_bonus_body_offline => 'You appear to be offline. Try again.';

  @override
  String get daily_bonus_cta_retry => 'Retry';

  @override
  String get chat_title => 'Chat';

  @override
  String get chat_message_hint => 'Type a message...';

  @override
  String get chat_send => 'Send';

  @override
  String get chat_empty_state => 'No messages yet';

  @override
  String get chat_error_empty => 'Cannot send an empty message.';

  @override
  String get chat_error_too_long => 'Message is too long (max 2000 characters).';

  @override
  String get chat_error_generic => 'Failed to send message. Please try again.';

  @override
  String get friends_title => 'Friends';

  @override
  String get friends_search_placeholder => 'Search by nickname...';

  @override
  String get friends_search_clear => 'Clear search';

  @override
  String get friends_search_no_results => 'No profiles found';

  @override
  String get friends_section_friends => 'Friends';

  @override
  String get friends_empty_state => 'No friends yet. Search for profiles to add friends.';

  @override
  String get friends_requests_title => 'Incoming Requests';

  @override
  String get friends_requests_empty => 'No incoming requests';

  @override
  String get friends_request_subtitle => 'wants to be friends';

  @override
  String get friends_send_request => 'Send friend request';

  @override
  String get friends_accept => 'Accept';

  @override
  String get friends_decline => 'Decline';

  @override
  String get friends_open_chat => 'Open chat';

  @override
  String get friends_remove => 'Remove friend';

  @override
  String get friends_remove_confirm_title => 'Remove friend?';

  @override
  String friends_remove_confirm_message(Object nickname) {
    return 'Are you sure you want to remove $nickname from your friends?';
  }

  @override
  String get friends_remove_confirm_yes => 'Remove';

  @override
  String get friends_remove_confirm_no => 'Cancel';

  @override
  String get friends_request_sent => 'Friend request sent';

  @override
  String get friends_accept_success => 'Friend request accepted';

  @override
  String get friends_decline_success => 'Friend request declined';

  @override
  String get friends_remove_success => 'Friend removed';

  @override
  String get friends_remove_error => 'Failed to remove friend';

  @override
  String get friends_request_error => 'Failed to process request';

  @override
  String get friends_status_friend => 'Friend';

  @override
  String get friends_status_request_sent => 'Request sent';

  @override
  String get friends_status_request_received => 'Request received';

  @override
  String get friends_error_self => 'You cannot add yourself as a friend.';

  @override
  String get friends_error_already_friends => 'You are already friends.';

  @override
  String get friends_error_request_exists => 'You already sent a request to this user.';

  @override
  String get friends_error_incoming_exists => 'This user has already sent you a request.';

  @override
  String get friends_error_request_missing => 'Request not found.';

  @override
  String get friends_error_not_pending => 'This request is no longer pending.';

  @override
  String get friends_error_not_found => 'Friendship not found.';

  @override
  String get friends_error_generic => 'Something went wrong. Please try again.';

  @override
  String get unknown_error_try_again => 'An error occurred. Please try again.';

  @override
  String get events_screen_refresh => 'Retry';
}
