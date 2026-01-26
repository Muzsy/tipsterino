# 🎯 Funkció

A SignUp wizard 3. lépése (Consent) legyen éles:
- Kötelező checkboxok: ÁSZF + Adatkezelés.
- Összefoglaló: email + nickname + avatar.
- Submit gomb (nem „Next”): csak akkor aktív, ha mindkét consent be van pipálva + nem offline + Step1/Step2 már valid.
- Submit hívja a Supabase `auth.signUp`-ot a DB triggerhez szükséges meta adatokkal:
  - `data: {'nickname': <nickname>, 'avatar_key': <avatarKey>}`
- Siker esetén navigáció a `VerifyEmailPendingScreen`-re (`/auth/verify-pending?email=...`).
- Hiba esetén lokalizált üzenet + marad Step 3-on.

# 🧠 Fejlesztési részletek

## Releváns fájlok
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
- `app/lib/src/features/auth/presentation/screens/verify_email_pending_screen.dart` *(új)*
- `app/lib/src/app/router/app_router.dart`
- `app/lib/src/core/clients/supabase_provider.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/test/widget/auth_signup_wizard_step3_test.dart` *(új)*

## Consent állapot és validáció
- Új state mezők:
  - `termsAccepted`, `privacyAccepted`
  - `isSubmitting`, `submitError` (string vagy enum)
- `step3Valid`: termsAccepted && privacyAccepted
- Submit közben: gomb disabled + progress indikátor

## Tesztelhetőség (kötelező)
- Vezess be egy felülírható submit providert, hogy tesztben ne kelljen valós Supabase:
  - `signupSubmitterProvider: Provider<Future<void> Function({email, password, nickname, avatarKey})>`
  - Default implementáció: `config.client!.auth.signUp(..., data: {...})`
  - Ha Supabase nincs konfigurálva: dobjon kivételt (offline/disabled marad).

## VerifyEmailPendingScreen (új)
- Route: `/auth/verify-pending`
- Query param: `email`
- UI:
  - cím + leírás (email megjelenítése)
  - gomb: „Vissza a bejelentkezéshez” → `/auth/login`
- (Resend / deep link handling) még nem része ennek a tasknak.

# 🧪 Tesztállapot
- `./scripts/flutter.sh gen-l10n`
- `cd app && dart format .`
- `./scripts/check.sh`

# 🌍 Lokalizáció
Új kulcsok HU/EN:
- `auth_consent_title`
- `auth_consent_terms_label`
- `auth_consent_privacy_label`
- `auth_signup_submit` (pl. “Create account”)
- `auth_signup_submit_loading`
- `auth_signup_submit_error`
- `auth_verify_pending_title`
- `auth_verify_pending_body`
- `auth_verify_pending_back_to_login`

# 📎 Kapcsolódások
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` (meta: nickname + avatar_key kötelező)
- `documents/registration/registration_flow_V2-md` (Step 3 leírás)
