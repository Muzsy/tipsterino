**PASS** - legacy `src/screens` gyujto megszunt, feature-first screen pathokkal es zold route smoke bizonyitekkal.

## 1) Meta
- **Task slug:** legacy_screens_feature_first_alignment
- **Kapcsolodo canvas:** canvases/audit_p1/legacy_screens_feature_first_alignment.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_legacy_screens_feature_first_alignment.yaml
- **Futas datuma:** 2026-02-09
- **Branch / commit:** main
- **Fokusz terulet:** App + Docs

## 2) Scope
### 2.1 Cel
- Legacy screen gyujto (`app/lib/src/screens/`) megszuntetese feature-first mappazassal.
- Router importok atallitasa uj feature-first screen pathokra.
- Architektura doksi szinkronizalasa a lezart screen migracioval.

### 2.2 Nem-cel (explicit)
- Uj route-ok vagy shell viselkedes valtoztatasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/legacy_screens_feature_first_alignment.md`
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/lib/src/features/bets/presentation/screens/bets_screen.dart`
- `app/lib/src/features/forum/presentation/screens/forum_screen.dart`
- `app/lib/src/features/guest_info/presentation/screens/guest_info_screen.dart`
- `app/lib/src/features/profile/presentation/screens/profile_screen.dart`
- `app/lib/src/features/settings/presentation/screens/settings_screen.dart`
- `app/lib/src/screens/home_screen.dart` (torolve/mozgatva)
- `app/lib/src/screens/bets_screen.dart` (torolve/mozgatva)
- `app/lib/src/screens/forum_screen.dart` (torolve/mozgatva)
- `app/lib/src/screens/guest_info_screen.dart` (torolve/mozgatva)
- `app/lib/src/screens/profile_screen.dart` (torolve/mozgatva)
- `app/lib/src/screens/settings_screen.dart` (torolve/mozgatva)
- `app/lib/src/app/router/app_router.dart`
- `docs/architect/project_structure.md`
- `codex/codex_checklist/audit_p1/legacy_screens_feature_first_alignment.md`
- `codex/reports/audit_p1/legacy_screens_feature_first_alignment.md`

### 3.2 Miert valtoztak?
- A screen fajlok feature-first helyre kerultek, a legacy gyujto mappa megszunt.
- A router mar package importtal az uj feature pathokra mutat.
- A project structure doksi rögzíti, hogy a screen migracio lezart.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/legacy_screens_feature_first_alignment.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check.sh`
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart`

### 4.3 Eredmeny roviden
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart` PASS.
- `./scripts/check.sh` PASS.
- `./scripts/verify.sh --report codex/reports/audit_p1/legacy_screens_feature_first_alignment.md` PASS.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| nincs hasznalt app screen fajl a `app/lib/src/screens/` gyujto alatt | PASS | `app/lib/src/features/home/presentation/screens/home_screen.dart:1` | A 6 screen atkerult feature-first helyre, a legacy gyujto mappa torolve. | `./scripts/check.sh` |
| router importok feature-first pathokra mutatnak | PASS | `app/lib/src/app/router/app_router.dart:11` | A router a `src/features/*/presentation/screens/*` package importokat hasznalja. | `./scripts/check.sh` |
| route smoke teszt valtozatlan viselkedessel lefut | PASS | `app/test/widget/guest_routing_shells_test.dart:23` | A guest/auth shell route smoke tesztek zolden futnak valtozatlan elvart viselkedessel. | `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart` |
| doksi es valos struktura konzisztens | PASS | `docs/architect/project_structure.md:124` | A doksi explicit jelzi, hogy a `lib/src/screens/` migracio lezart. | `./scripts/check.sh` |

## 8) Advisory notes (nem blokkolo)
- A `canvases/` es egyes regi doksik hivatkozhatnak meg legacy screen pathokra; ez dokumentacios adossag, nem build blocker.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T00:00:26+01:00 → 2026-02-10T00:01:07+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/legacy_screens_feature_first_alignment.verify.log`
- git: `main@27f3478`
- módosított fájlok (git status): 18

**git diff --stat**

```text
 app/lib/src/app/router/app_router.dart             | 12 ++--
 app/lib/src/screens/bets_screen.dart               | 20 ------
 app/lib/src/screens/forum_screen.dart              | 20 ------
 app/lib/src/screens/guest_info_screen.dart         | 37 ----------
 app/lib/src/screens/home_screen.dart               | 60 ----------------
 app/lib/src/screens/profile_screen.dart            | 20 ------
 app/lib/src/screens/settings_screen.dart           | 80 ----------------------
 .../legacy_screens_feature_first_alignment.md      | 12 ++--
 .../legacy_screens_feature_first_alignment.md      | 12 ++--
 .../legacy_screens_feature_first_alignment.md      | 52 ++++++++++----
 docs/architect/project_structure.md                |  6 +-
 11 files changed, 60 insertions(+), 271 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/app/router/app_router.dart
 D app/lib/src/screens/bets_screen.dart
 D app/lib/src/screens/forum_screen.dart
 D app/lib/src/screens/guest_info_screen.dart
 D app/lib/src/screens/home_screen.dart
 D app/lib/src/screens/profile_screen.dart
 D app/lib/src/screens/settings_screen.dart
 M canvases/audit_p1/legacy_screens_feature_first_alignment.md
 M codex/codex_checklist/audit_p1/legacy_screens_feature_first_alignment.md
 M codex/reports/audit_p1/legacy_screens_feature_first_alignment.md
 M docs/architect/project_structure.md
?? app/lib/src/features/bets/
?? app/lib/src/features/forum/
?? app/lib/src/features/guest_info/
?? app/lib/src/features/home/
?? app/lib/src/features/profile/
?? app/lib/src/features/settings/
?? codex/reports/audit_p1/legacy_screens_feature_first_alignment.verify.log
```

<!-- AUTO_VERIFY_END -->
