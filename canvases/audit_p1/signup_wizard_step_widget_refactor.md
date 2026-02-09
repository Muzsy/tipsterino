# Audit P1-2: signup wizard step widget refactor

## 🎯 Funkcio
Celfeladat: a `sign_up_wizard_screen.dart` felbontasa step-szintu widgetekre, hogy a signup flow jobban karbantarthato es regresszio-biztos legyen.

Nem cel:
- auth backend valtoztatas
- uj wizard step vagy uj UX flow

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step1.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step2.dart`
- `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step3.dart`
- `app/lib/src/features/auth/presentation/widgets/password_rules.dart`
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/test/widget/auth_signup_wizard_step1_test.dart`
- `app/test/widget/auth_signup_wizard_step2_test.dart`
- `app/test/widget/auth_signup_wizard_step3_test.dart`

Tervezett kimenetek:
- wizard screen karcsusitas: `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
- uj step widget fajlok: 
  - `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step1.dart`
  - `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step2.dart`
  - `app/lib/src/features/auth/presentation/widgets/sign_up_wizard_step3.dart`
- password rule utility: `app/lib/src/features/auth/presentation/widgets/password_rules.dart`
- widget tesztek frissitese a refaktorhoz:
  - `app/test/widget/auth_signup_wizard_step1_test.dart`
  - `app/test/widget/auth_signup_wizard_step2_test.dart`
  - `app/test/widget/auth_signup_wizard_step3_test.dart`

DoD:
- [ ] a signup wizard fo screen jelentosen kisebb, step logika kulon widgetekben van
- [ ] provider/public viselkedes valtozatlan marad
- [ ] step1/step2/step3 widget tesztek zolden futnak a refaktor utan
- [ ] report DoD-Evidence matrix tartalmazza a refaktor bizonyitekokat

Kockazat/rollback:
- refaktor kozben konnyu megtoreszteni a validacios allapotot; regresszio eseten ideiglenesen vissza kell kotni a regi kompoziciot.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/signup_wizard_step_widget_refactor.md`

## 🌍 Lokalizacio
Erintett lehet (wizard szovegek), de uj kulcs bevezetese nem cel.

## 📎 Kapcsolodasok
- `docs/architect/project_structure.md`
- `docs/qa/testing_guidelines.md`
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
