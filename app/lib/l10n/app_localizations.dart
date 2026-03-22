import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tipsterino'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your Tipsterino profile.'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new Tipsterino account.'**
  String get registerSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordRepeatLabel;

  /// No description provided for @enterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterPasswordError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match'**
  String get passwordMismatchError;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @dontHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccountPrompt;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'Supabase not configured'**
  String get offlineNotice;

  /// No description provided for @offlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Define SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define to enable authentication.'**
  String get offlineDescription;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authGenericError;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your inbox for confirmation.'**
  String get registerSuccess;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutLabel;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_coming_next.
  ///
  /// In en, this message translates to:
  /// **'Coming next'**
  String get common_coming_next;

  /// No description provided for @auth_signup_step_account.
  ///
  /// In en, this message translates to:
  /// **'Step 1 – Account'**
  String get auth_signup_step_account;

  /// No description provided for @auth_signup_step_profile.
  ///
  /// In en, this message translates to:
  /// **'Step 2 – Profile'**
  String get auth_signup_step_profile;

  /// No description provided for @auth_signup_step_consent.
  ///
  /// In en, this message translates to:
  /// **'Step 3 – Consent'**
  String get auth_signup_step_consent;

  /// No description provided for @auth_password_rule_min_length.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get auth_password_rule_min_length;

  /// No description provided for @auth_password_rule_uppercase.
  ///
  /// In en, this message translates to:
  /// **'Contains an uppercase letter'**
  String get auth_password_rule_uppercase;

  /// No description provided for @auth_password_rule_lowercase.
  ///
  /// In en, this message translates to:
  /// **'Contains a lowercase letter'**
  String get auth_password_rule_lowercase;

  /// No description provided for @auth_password_rule_special.
  ///
  /// In en, this message translates to:
  /// **'Contains a special character'**
  String get auth_password_rule_special;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @auth_nickname_label.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get auth_nickname_label;

  /// No description provided for @auth_nickname_help.
  ///
  /// In en, this message translates to:
  /// **'3-20 characters, lowercase letters, numbers, dot, or underscore.'**
  String get auth_nickname_help;

  /// No description provided for @auth_nickname_too_short.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters.'**
  String get auth_nickname_too_short;

  /// No description provided for @auth_nickname_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking availability...'**
  String get auth_nickname_checking;

  /// No description provided for @auth_nickname_available.
  ///
  /// In en, this message translates to:
  /// **'Nickname available'**
  String get auth_nickname_available;

  /// No description provided for @auth_nickname_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Nickname already taken'**
  String get auth_nickname_unavailable;

  /// No description provided for @auth_nickname_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify nickname'**
  String get auth_nickname_error;

  /// No description provided for @auth_avatar_label.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get auth_avatar_label;

  /// No description provided for @auth_avatar_change.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get auth_avatar_change;

  /// No description provided for @auth_avatar_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar'**
  String get auth_avatar_sheet_title;

  /// No description provided for @auth_consent_title.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get auth_consent_title;

  /// No description provided for @auth_consent_terms_label.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service'**
  String get auth_consent_terms_label;

  /// No description provided for @auth_consent_privacy_label.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Data Processing Policy'**
  String get auth_consent_privacy_label;

  /// No description provided for @auth_signup_submit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_signup_submit;

  /// No description provided for @auth_signup_submit_loading.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get auth_signup_submit_loading;

  /// No description provided for @auth_signup_submit_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to create account'**
  String get auth_signup_submit_error;

  /// No description provided for @auth_verify_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get auth_verify_pending_title;

  /// No description provided for @auth_verify_pending_body.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Please confirm to continue.'**
  String auth_verify_pending_body(Object email);

  /// No description provided for @auth_verify_pending_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get auth_verify_pending_back_to_login;

  /// No description provided for @auth_verify_pending_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification'**
  String get auth_verify_pending_resend;

  /// No description provided for @auth_verify_pending_resend_sent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get auth_verify_pending_resend_sent;

  /// No description provided for @auth_verify_pending_resend_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds}s'**
  String auth_verify_pending_resend_cooldown(Object seconds);

  /// No description provided for @auth_callback_title.
  ///
  /// In en, this message translates to:
  /// **'Authentication callback'**
  String get auth_callback_title;

  /// No description provided for @auth_callback_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing authentication callback...'**
  String get auth_callback_processing;

  /// No description provided for @auth_callback_success.
  ///
  /// In en, this message translates to:
  /// **'Authentication succeeded!'**
  String get auth_callback_success;

  /// No description provided for @auth_callback_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get auth_callback_continue;

  /// No description provided for @auth_callback_expired.
  ///
  /// In en, this message translates to:
  /// **'The link is invalid or has expired.'**
  String get auth_callback_expired;

  /// No description provided for @auth_callback_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete authentication. Please try logging in again.'**
  String get auth_callback_error_generic;

  /// No description provided for @auth_callback_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification'**
  String get auth_callback_resend;

  /// No description provided for @auth_callback_error.
  ///
  /// In en, this message translates to:
  /// **'Callback failed: {error}'**
  String auth_callback_error(Object error);

  /// No description provided for @auth_callback_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get auth_callback_back_to_login;

  /// No description provided for @betsTab.
  ///
  /// In en, this message translates to:
  /// **'Bets'**
  String get betsTab;

  /// No description provided for @forumTab.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forumTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @guestInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest access info'**
  String get guestInfoTitle;

  /// No description provided for @guestInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a peek at Tipsterino while you decide to log in or register.'**
  String get guestInfoBody;

  /// No description provided for @guestInfoLoginCta.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get guestInfoLoginCta;

  /// No description provided for @guestInfoRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get guestInfoRegisterCta;

  /// No description provided for @homeGuestLoginCta.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get homeGuestLoginCta;

  /// No description provided for @homeGuestRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get homeGuestRegisterCta;

  /// No description provided for @homeAuthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'User stats coming soon.'**
  String get homeAuthPlaceholder;

  /// No description provided for @eventsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsInboxTitle;

  /// No description provided for @eventsInboxEntry.
  ///
  /// In en, this message translates to:
  /// **'Events inbox'**
  String get eventsInboxEntry;

  /// No description provided for @eventsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get eventsEmptyTitle;

  /// No description provided for @eventsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'We will show your events here as soon as they arrive.'**
  String get eventsEmptyBody;

  /// No description provided for @eventsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get eventsFilterAll;

  /// No description provided for @eventsFilterCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get eventsFilterCredits;

  /// No description provided for @eventsFilterChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get eventsFilterChallenges;

  /// No description provided for @eventsFilterSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get eventsFilterSocial;

  /// No description provided for @eventsFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get eventsFilterSystem;

  /// No description provided for @eventsMarkAllReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get eventsMarkAllReadTooltip;

  /// No description provided for @eventsMarkAllReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'All marked as read'**
  String get eventsMarkAllReadSuccess;

  /// No description provided for @eventsMarkAllReadPartial.
  ///
  /// In en, this message translates to:
  /// **'Marked {succeeded}, failed {failed}'**
  String eventsMarkAllReadPartial(Object failed, Object succeeded);

  /// No description provided for @eventSignupBonusTitle.
  ///
  /// In en, this message translates to:
  /// **'Signup bonus'**
  String get eventSignupBonusTitle;

  /// No description provided for @eventSignupBonusBody.
  ///
  /// In en, this message translates to:
  /// **'You earned {amount} TippCoins as a signup bonus.'**
  String eventSignupBonusBody(Object amount);

  /// No description provided for @event_daily_bonus_title.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus'**
  String get event_daily_bonus_title;

  /// No description provided for @event_daily_bonus_body.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus credited: +{amount} TippCoins.'**
  String event_daily_bonus_body(Object amount);

  /// No description provided for @daily_bonus_title.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus'**
  String get daily_bonus_title;

  /// No description provided for @daily_bonus_body_available.
  ///
  /// In en, this message translates to:
  /// **'Claim your daily TippCoins.'**
  String get daily_bonus_body_available;

  /// No description provided for @daily_bonus_body_claimed.
  ///
  /// In en, this message translates to:
  /// **'Already claimed today. Come back tomorrow.'**
  String get daily_bonus_body_claimed;

  /// No description provided for @daily_bonus_body_disabled.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus is not active.'**
  String get daily_bonus_body_disabled;

  /// No description provided for @daily_bonus_body_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Verify your email to claim the daily bonus.'**
  String get daily_bonus_body_not_verified;

  /// No description provided for @daily_bonus_body_profile_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to claim the daily bonus.'**
  String get daily_bonus_body_profile_incomplete;

  /// No description provided for @daily_bonus_cta_claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get daily_bonus_cta_claim;

  /// No description provided for @daily_bonus_cta_claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get daily_bonus_cta_claimed;

  /// No description provided for @daily_bonus_snackbar_granted.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus claimed: +{amount} TippCoins!'**
  String daily_bonus_snackbar_granted(Object amount);

  /// No description provided for @daily_bonus_body_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus is unavailable (not configured).'**
  String get daily_bonus_body_not_configured;

  /// No description provided for @daily_bonus_body_rate_limited.
  ///
  /// In en, this message translates to:
  /// **'Too many claim attempts. Please try again shortly.'**
  String get daily_bonus_body_rate_limited;

  /// No description provided for @daily_bonus_body_offline.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. Try again.'**
  String get daily_bonus_body_offline;

  /// No description provided for @daily_bonus_cta_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get daily_bonus_cta_retry;

  /// No description provided for @chat_title.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_title;

  /// No description provided for @chat_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_message_hint;

  /// No description provided for @chat_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chat_send;

  /// No description provided for @chat_empty_state.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_empty_state;

  /// No description provided for @chat_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Cannot send an empty message.'**
  String get chat_error_empty;

  /// No description provided for @chat_error_too_long.
  ///
  /// In en, this message translates to:
  /// **'Message is too long (max 2000 characters).'**
  String get chat_error_too_long;

  /// No description provided for @chat_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get chat_error_generic;

  /// No description provided for @friends_title.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends_title;

  /// No description provided for @friends_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by nickname...'**
  String get friends_search_placeholder;

  /// No description provided for @friends_search_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get friends_search_clear;

  /// No description provided for @friends_search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No profiles found'**
  String get friends_search_no_results;

  /// No description provided for @friends_section_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends_section_friends;

  /// No description provided for @friends_empty_state.
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Search for profiles to add friends.'**
  String get friends_empty_state;

  /// No description provided for @friends_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get friends_requests_title;

  /// No description provided for @friends_requests_empty.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get friends_requests_empty;

  /// No description provided for @friends_request_subtitle.
  ///
  /// In en, this message translates to:
  /// **'wants to be friends'**
  String get friends_request_subtitle;

  /// No description provided for @friends_send_request.
  ///
  /// In en, this message translates to:
  /// **'Send friend request'**
  String get friends_send_request;

  /// No description provided for @friends_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friends_accept;

  /// No description provided for @friends_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friends_decline;

  /// No description provided for @friends_open_chat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get friends_open_chat;

  /// No description provided for @friends_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get friends_remove;

  /// No description provided for @friends_remove_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Remove friend?'**
  String get friends_remove_confirm_title;

  /// No description provided for @friends_remove_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {nickname} from your friends?'**
  String friends_remove_confirm_message(Object nickname);

  /// No description provided for @friends_remove_confirm_yes.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get friends_remove_confirm_yes;

  /// No description provided for @friends_remove_confirm_no.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get friends_remove_confirm_no;

  /// No description provided for @friends_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friends_request_sent;

  /// No description provided for @friends_accept_success.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friends_accept_success;

  /// No description provided for @friends_decline_success.
  ///
  /// In en, this message translates to:
  /// **'Friend request declined'**
  String get friends_decline_success;

  /// No description provided for @friends_remove_success.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friends_remove_success;

  /// No description provided for @friends_remove_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove friend'**
  String get friends_remove_error;

  /// No description provided for @friends_request_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to process request'**
  String get friends_request_error;

  /// No description provided for @friends_status_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friends_status_friend;

  /// No description provided for @friends_status_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get friends_status_request_sent;

  /// No description provided for @friends_status_request_received.
  ///
  /// In en, this message translates to:
  /// **'Request received'**
  String get friends_status_request_received;

  /// No description provided for @friends_error_self.
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself as a friend.'**
  String get friends_error_self;

  /// No description provided for @friends_error_already_friends.
  ///
  /// In en, this message translates to:
  /// **'You are already friends.'**
  String get friends_error_already_friends;

  /// No description provided for @friends_error_request_exists.
  ///
  /// In en, this message translates to:
  /// **'You already sent a request to this user.'**
  String get friends_error_request_exists;

  /// No description provided for @friends_error_incoming_exists.
  ///
  /// In en, this message translates to:
  /// **'This user has already sent you a request.'**
  String get friends_error_incoming_exists;

  /// No description provided for @friends_error_request_missing.
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get friends_error_request_missing;

  /// No description provided for @friends_error_not_pending.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer pending.'**
  String get friends_error_not_pending;

  /// No description provided for @friends_error_not_found.
  ///
  /// In en, this message translates to:
  /// **'Friendship not found.'**
  String get friends_error_not_found;

  /// No description provided for @friends_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get friends_error_generic;

  /// No description provided for @unknown_error_try_again.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get unknown_error_try_again;

  /// No description provided for @events_screen_refresh.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get events_screen_refresh;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hu': return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
