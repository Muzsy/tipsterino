**FAIL** - report scaffold, futas es bizonyitekok meg nincsenek kitoltve.

## 1) Meta
- **Task slug:** `bonus_reason_contract_rate_limited_profile_incomplete`
- **Kapcsolodo canvas:** `canvases/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_bonus_reason_contract_rate_limited_profile_incomplete.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** nincs rogzitve
- **Fokusz terulet:** domain + UI + localization

## 2) Scope
### 2.1 Cel
- Bonus reason enum/mapping szinkronja a szerver contracttal.
- `rate_limited` UI/l10n allapot kezelese.
- Celzott unit/widget + l10n parity lefedes.

### 2.2 Nem-cel (explicit)
- bonus RPC SQL logika modositas.
- rewards felulet teljes attervezese.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/test/unit/daily_bonus_grant_result_test.dart`
- `app/test/unit/signup_bonus_grant_result_test.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- `codex/codex_checklist/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`
- `codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

### 3.2 Miert valtoztak?
- A futas utan toltendo: hogyan lett felszamolva az unknown-reason fallback kockazat.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/daily_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/unit/signup_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/widget/daily_bonus_tile_test.dart`
- `./scripts/flutter.sh test test/unit/l10n_key_parity_test.dart`

### 4.3 Eredmeny roviden
- Nincs kitoltve.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Daily reason kezeli a `rate_limited` erteket | FAIL | n/a | n/a | n/a |
| Signup reason kezeli `profile_incomplete` + `rate_limited` ertekeket | FAIL | n/a | n/a | n/a |
| UI kulon uzenetet ad `rate_limited` allapotra | FAIL | n/a | n/a | n/a |
| EN/HU ARB parity teljesul | FAIL | n/a | n/a | n/a |
| unit/widget/l10n tesztek lefutottak | FAIL | n/a | n/a | n/a |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
