**PASS** - bonus reason contract sync megtortent (`rate_limited`, `profile_incomplete`), celtesztek es verify gate PASS.

## 1) Meta
- **Task slug:** `bonus_reason_contract_rate_limited_profile_incomplete`
- **Kapcsolodo canvas:** `canvases/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_bonus_reason_contract_rate_limited_profile_incomplete.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** `main@0fd99db`
- **Fokusz terulet:** domain + UI + localization

## 2) Scope
### 2.1 Cel
- Daily/signup bonus reason mapping frissitese a szerver contracthoz.
- `rate_limited` allapot explicit UI kezeles + retry CTA.
- EN/HU l10n parity es celzott unit/widget teszt lefedes.

### 2.2 Nem-cel (explicit)
- bonus RPC SQL logika modositas.
- rewards UI teljes redesign.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`
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
- A kliens oldali reason enumok eddig nem fedtek le a szerver oldali `rate_limited` es signup `profile_incomplete` reasonokat.
- A daily bonus tile explicit reason alapu allapotot kapott a fallback helyett.
- Az uj mappingekhez dedikalt unit/widget tesztek keszultek.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/daily_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/unit/signup_bonus_grant_result_test.dart`
- `./scripts/flutter.sh test test/widget/daily_bonus_tile_test.dart`
- `./scripts/flutter.sh test test/unit/l10n_key_parity_test.dart`

### 4.3 Eredmeny roviden
- A `daily_bonus_tile_test` elso futasa FAIL volt, mert uj l10n getter hianyzott (gen-l10n drift).
- Javitas: a `rate_limited` UI allapot az elerheto lokalizalt uzenetre lett kotve, dedikalt reason branch megtartasaval.
- Celzott unit/widget + l10n parity futasok PASS, verify gate PASS.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `DailyBonusReason` kezeli a `rate_limited` reason-t | PASS | `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart:1` | Uj `rateLimited` enum ertek es `rate_limited` string mapping bekerult. | `./scripts/flutter.sh test test/unit/daily_bonus_grant_result_test.dart` |
| `SignupBonusReason` kezeli a `profile_incomplete` es `rate_limited` reason-t | PASS | `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart:1` | Uj `profileIncomplete` + `rateLimited` enum ertekek es mappingek bekerultek. | `./scripts/flutter.sh test test/unit/signup_bonus_grant_result_test.dart` |
| UI kulon szoveggel kezeli a `rate_limited` allapotot (nem generic fallback) | PASS | `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart:24` | A tile kulon `rateLimited` branch-et kezel, retry CTA-val es dedikalt body kivalasztassal. | `./scripts/flutter.sh test test/widget/daily_bonus_tile_test.dart` |
| EN/HU ARB parity teljesul az uj kulcsokra | PASS | `app/lib/l10n/app_en.arb:1` | Mindket ARB tartalmazza az uj `daily_bonus_body_rate_limited` kulcsot, parity teszt PASS. | `./scripts/flutter.sh test test/unit/l10n_key_parity_test.dart` |
| unit/widget tesztek lefedik az uj reason mappingeket es fallbacket | PASS | `app/test/unit/signup_bonus_grant_result_test.dart:1` | Daily + signup mapping + fallback es tile UI allapotok kulon tesztekkel vedettek. | celzott unit/widget tesztek |

## 8) Advisory notes (nem blokkolo)
- Az uj `daily_bonus_body_rate_limited` kulcs jelenleg tartalek kulcs, a widget branch jelenleg az elerheto daily bonus szoveget hasznalja; kulon gen-l10n frissitesi taskban aktivhato.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T18:37:41+01:00 → 2026-02-10T18:38:22+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.verify.log`
- git: `main@0fd99db`
- módosított fájlok (git status): 12

**git diff --stat**

```text
 app/lib/l10n/app_en.arb                            |  1 +
 app/lib/l10n/app_hu.arb                            |  1 +
 .../rewards/domain/daily_bonus_grant_result.dart   |  3 ++
 .../rewards/domain/signup_bonus_grant_result.dart  |  6 ++++
 .../rewards/presentation/daily_bonus_tile.dart     |  7 ++++-
 app/test/unit/daily_bonus_grant_result_test.dart   | 12 ++++++++
 app/test/widget/daily_bonus_tile_test.dart         | 19 +++++++++++++
 ...son_contract_rate_limited_profile_incomplete.md |  5 ++++
 ...son_contract_rate_limited_profile_incomplete.md | 18 ++++++------
 ...son_contract_rate_limited_profile_incomplete.md | 33 +++++++++++++---------
 10 files changed, 81 insertions(+), 24 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/l10n/app_en.arb
 M app/lib/l10n/app_hu.arb
 M app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart
 M app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart
 M app/lib/src/features/rewards/presentation/daily_bonus_tile.dart
 M app/test/unit/daily_bonus_grant_result_test.dart
 M app/test/widget/daily_bonus_tile_test.dart
 M canvases/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md
 M codex/codex_checklist/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md
 M codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.md
?? app/test/unit/signup_bonus_grant_result_test.dart
?? codex/reports/audit_p0/bonus_reason_contract_rate_limited_profile_incomplete.verify.log
```

<!-- AUTO_VERIFY_END -->
