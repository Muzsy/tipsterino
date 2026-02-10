**FAIL** - report scaffold, futas es bizonyitekok meg nincsenek kitoltve.

## 1) Meta
- **Task slug:** `auth_state_copywith_sentinel_regression`
- **Kapcsolodo canvas:** `canvases/audit_p0/auth_state_copywith_sentinel_regression.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_auth_state_copywith_sentinel_regression.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** nincs rogzitve
- **Fokusz terulet:** state + tests

## 2) Scope
### 2.1 Cel
- copyWith nullazasi bug javitasa ket auth state-ben sentinel patternnel.
- regresszios unit/widget coverage kiegeszitese.

### 2.2 Nem-cel (explicit)
- auth flow funkcionalis bovites.
- UI atalakitas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- `app/test/unit/signup_wizard_provider_test.dart`
- `app/test/unit/verify_email_pending_provider_test.dart`
- `app/test/widget/auth_signup_wizard_step3_test.dart`
- `app/test/widget/auth_verify_pending_resend_test.dart`
- `codex/codex_checklist/audit_p0/auth_state_copywith_sentinel_regression.md`
- `codex/reports/audit_p0/auth_state_copywith_sentinel_regression.md`

### 3.2 Miert valtoztak?
- A futas utan toltendo: hogyan szunt meg a stale error ragadas.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/auth_state_copywith_sentinel_regression.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/signup_wizard_provider_test.dart`
- `./scripts/flutter.sh test test/unit/verify_email_pending_provider_test.dart`
- `./scripts/flutter.sh test test/widget/auth_signup_wizard_step3_test.dart`
- `./scripts/flutter.sh test test/widget/auth_verify_pending_resend_test.dart`

### 4.3 Eredmeny roviden
- Nincs kitoltve.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Signup wizard copyWith nullazni tudja a submitError mezot | FAIL | n/a | n/a | n/a |
| Verify pending copyWith nullazni tudja az errorMessage mezot | FAIL | n/a | n/a | n/a |
| Regresszios unit tesztek fedik a nullazasi eseteket | FAIL | n/a | n/a | n/a |
| Erintett widget tesztek zolden futnak | FAIL | n/a | n/a | n/a |
| verify gate futas dokumentalt | FAIL | n/a | n/a | n/a |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
