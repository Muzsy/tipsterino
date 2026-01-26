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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
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

  /// No description provided for @ticketsTab.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get ticketsTab;

  /// No description provided for @leaderboardTab.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTab;

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
