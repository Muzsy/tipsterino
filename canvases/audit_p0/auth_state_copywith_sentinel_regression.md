# Audit P0-4: auth state copyWith sentinel regression fix

## 🎯 Funkcio
Celfeladat: ket auth state modellben (`SignupWizardState`, `VerifyEmailPendingState`) sentinel-alapu `copyWith` javitas, hogy a hiba mezok determinisztikusan nullazhatok legyenek.

Miert P0:
- jelenlegi `field ?? this.field` pattern miatt a korabbi hibaallapot ragadhat, ami hibas UX-et es fals allapotot okoz.

Nem cel:
- auth flow funkcionalis bovites
- teljes provider refaktor
- UI redesign

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart` (sentinel minta referencia)
- `app/test/widget/auth_signup_wizard_step3_test.dart`
- `app/test/widget/auth_verify_pending_resend_test.dart`

Tervezett kimenetek:
- sentinel `Object _undefined` copyWith pattern bevezetese a ket auth state-be
- regresszios unit tesztek a nullazasi esetre
- widget tesztek finomitasa, hogy ne maradjon stale error

DoD:
- [ ] `SignupWizardState.copyWith` kepes `submitError` mezot nullazni
- [ ] `VerifyEmailPendingState.copyWith` kepes `errorMessage` mezot nullazni
- [ ] uj unit tesztek reprodukaljak es vedik a hibajavitast
- [ ] megl evo widget flow-k zolden futnak (`auth_signup_wizard_step3_test`, `auth_verify_pending_resend_test`)

Kockazat/rollback:
- copyWith API valtozasnal implicit hivasok viselkedese valtozhat; regresszio eseten sentinel pattern pontositasa szukseges, nem visszaallitas.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/flutter.sh test test/unit/signup_wizard_provider_test.dart`
- `./scripts/flutter.sh test test/unit/verify_email_pending_provider_test.dart`
- `./scripts/flutter.sh test test/widget/auth_signup_wizard_step3_test.dart`
- `./scripts/flutter.sh test test/widget/auth_verify_pending_resend_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/auth_state_copywith_sentinel_regression.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/testing_guidelines.md`
- `docs/core_logic/registration_flow.md`
