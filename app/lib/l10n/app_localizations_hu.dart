// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Tipsterino';

  @override
  String get loginTitle => 'Bejelentkezés';

  @override
  String get loginSubtitle => 'Lépj be a Tipsterino fiókodba.';

  @override
  String get registerTitle => 'Regisztráció';

  @override
  String get registerSubtitle => 'Hozz létre egy Tipsterino fiókot.';

  @override
  String get emailLabel => 'Email cím';

  @override
  String get passwordLabel => 'Jelszó';

  @override
  String get passwordRepeatLabel => 'Jelszó megerősítése';

  @override
  String get enterPasswordError => 'Add meg a jelszót';

  @override
  String get invalidEmailError => 'Érvényes email címet adj meg';

  @override
  String get passwordMismatchError => 'A jelszavak nem egyeznek';

  @override
  String get logInButton => 'Bejelentkezés';

  @override
  String get registerButton => 'Regisztráció';

  @override
  String get dontHaveAccountPrompt => 'Nincs még fiókod? Regisztrálj';

  @override
  String get alreadyHaveAccount => 'Már van fiókod? Jelentkezz be';

  @override
  String get offlineNotice => 'A Supabase nincs konfigurálva';

  @override
  String get offlineDescription => 'Állítsd be a SUPABASE_URL és SUPABASE_ANON_KEY define-okat `--dart-define` segítségével az autentikációhoz.';

  @override
  String get authGenericError => 'Hitelesítési hiba';

  @override
  String get registerSuccess => 'Fiókod elkészült! Ellenőrizd az emailed.';

  @override
  String get homeTab => 'Kezdőlap';

  @override
  String get ticketsTab => 'Szelvények';

  @override
  String get leaderboardTab => 'Ranglista';

  @override
  String get settingsTab => 'Beállítások';

  @override
  String get logoutLabel => 'Kijelentkezés';

  @override
  String get common_next => 'Tovább';

  @override
  String get common_back => 'Vissza';

  @override
  String get common_coming_next => 'Hamarosan elérhető';

  @override
  String get auth_signup_step_account => '1. lépés – Fiók';

  @override
  String get auth_signup_step_profile => '2. lépés – Profil';

  @override
  String get auth_signup_step_consent => '3. lépés – Jóváhagyás';

  @override
  String get auth_password_rule_min_length => 'Legalább 8 karakter';

  @override
  String get auth_password_rule_uppercase => 'Legalább 1 nagybetű';

  @override
  String get auth_password_rule_lowercase => 'Legalább 1 kisbetű';

  @override
  String get auth_password_rule_number => 'Legalább 1 szám';
}
