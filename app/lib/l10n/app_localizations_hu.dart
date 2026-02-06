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
  String get auth_password_rule_special => 'Legalább 1 speciális karakter';

  @override
  String get common_done => 'Kész';

  @override
  String get auth_nickname_label => 'Felhasználónév';

  @override
  String get auth_nickname_help => '3-20 karakter, kisbetű, szám, pont vagy alulvonás.';

  @override
  String get auth_nickname_too_short => 'Adj meg legalább 3 karaktert.';

  @override
  String get auth_nickname_checking => 'Foglaltság ellenőrzése...';

  @override
  String get auth_nickname_available => 'A felhasználónév szabad';

  @override
  String get auth_nickname_unavailable => 'A felhasználónév foglalt';

  @override
  String get auth_nickname_error => 'Nem sikerült ellenőrizni a felhasználónevet';

  @override
  String get auth_avatar_label => 'Avatar';

  @override
  String get auth_avatar_change => 'Változtatás';

  @override
  String get auth_avatar_sheet_title => 'Avatar választás';

  @override
  String get auth_consent_title => 'Hozzájárulás';

  @override
  String get auth_consent_terms_label => 'Elfogadom az ÁSZF-et';

  @override
  String get auth_consent_privacy_label => 'Elfogadom az Adatkezelési szabályzatot';

  @override
  String get auth_signup_submit => 'Fiók létrehozása';

  @override
  String get auth_signup_submit_loading => 'Fiók létrehozása...';

  @override
  String get auth_signup_submit_error => 'Nem sikerült a fiók létrehozása';

  @override
  String get auth_verify_pending_title => 'Ellenőrizd az emailed';

  @override
  String auth_verify_pending_body(Object email) {
    return 'Küldtünk egy megerősítő linket erre az email címre: $email. Kérjük, erősítsd meg a folytatáshoz.';
  }

  @override
  String get auth_verify_pending_back_to_login => 'Vissza a bejelentkezéshez';

  @override
  String get auth_verify_pending_resend => 'Újraküldés';

  @override
  String get auth_verify_pending_resend_sent => 'Megerősítő email elküldve';

  @override
  String auth_verify_pending_resend_cooldown(Object seconds) {
    return 'Újraküldés ${seconds}s múlva';
  }

  @override
  String get auth_callback_title => 'Hitelesítés visszahívás';

  @override
  String get auth_callback_processing => 'Hitelesítési visszahívás feldolgozása...';

  @override
  String get auth_callback_success => 'Hitelesítés sikeres';

  @override
  String get auth_callback_continue => 'Folytatás';

  @override
  String get auth_callback_expired => 'A link lejárt vagy érvénytelen.';

  @override
  String get auth_callback_error_generic => 'Nem sikerült befejezni a hitelesítést. Próbáld újra.';

  @override
  String get auth_callback_resend => 'Újraküldés';

  @override
  String auth_callback_error(Object error) {
    return 'Hiba a visszahívás során: $error';
  }

  @override
  String get auth_callback_back_to_login => 'Vissza a bejelentkezéshez';

  @override
  String get betsTab => 'Szelvények';

  @override
  String get forumTab => 'Fórum';

  @override
  String get profileTab => 'Profil';

  @override
  String get guestInfoTitle => 'Vendég információ';

  @override
  String get guestInfoBody => 'Kóstolj bele a Tipsterinóba, mielőtt bejelentkezel vagy regisztrálsz.';

  @override
  String get guestInfoLoginCta => 'Bejelentkezés';

  @override
  String get guestInfoRegisterCta => 'Regisztráció';

  @override
  String get homeGuestLoginCta => 'Bejelentkezés';

  @override
  String get homeGuestRegisterCta => 'Regisztráció';

  @override
  String get homeAuthPlaceholder => 'Felhasználói statisztikák hamarosan.';

  @override
  String get eventsInboxTitle => 'Események';

  @override
  String get eventsInboxEntry => 'Események';

  @override
  String get eventsEmptyTitle => 'Még nincs esemény';

  @override
  String get eventsEmptyBody => 'Az események itt jelennek meg, amint történik valami.';

  @override
  String get eventSignupBonusTitle => 'Regisztrációs bónusz';

  @override
  String eventSignupBonusBody(Object amount) {
    return '$amount TippCoin jóváírás a regisztrációért.';
  }

  @override
  String get eventDailyBonusTitle => 'Napi bónusz';

  @override
  String eventDailyBonusBody(Object amount) {
    return 'Napi bónusz jóváírva: +$amount TippCoin.';
  }

  @override
  String get daily_bonus_title => 'Napi bónusz';

  @override
  String get daily_bonus_body_available => 'Igényeld a napi TippCoin jutalmad.';

  @override
  String get daily_bonus_body_claimed => 'Ma már igényelted. Gyere vissza holnap.';

  @override
  String get daily_bonus_body_disabled => 'A napi bónusz jelenleg nem aktív.';

  @override
  String get daily_bonus_body_not_verified =>
      'Email megerősítése szükséges a napi bónusz igényléséhez.';

  @override
  String get daily_bonus_body_profile_incomplete =>
      'Profil kitöltése szükséges a napi bónusz igényléséhez.';

  @override
  String get daily_bonus_cta_claim => 'Igénylés';

  @override
  String get daily_bonus_cta_claimed => 'Igényelve';

  @override
  String daily_bonus_snackbar_granted(Object amount) {
    return 'Napi bónusz jóváírva: +$amount TippCoin!';
  }
}
