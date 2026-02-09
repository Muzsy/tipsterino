# Audit P1-3: legacy screens feature-first alignment

## 🎯 Funkcio
Celfeladat: a `app/lib/src/screens/` legacy gyujto mappa megszuntetese es feature-first elrendezesre allitasa a routing integritas megtartasaval.

Nem cel:
- uj route bevezetese
- shell/navigation termek viselkedes valtoztatasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/lib/src/features/bets/presentation/screens/bets_screen.dart`
- `app/lib/src/features/forum/presentation/screens/forum_screen.dart`
- `app/lib/src/features/guest_info/presentation/screens/guest_info_screen.dart`
- `app/lib/src/features/profile/presentation/screens/profile_screen.dart`
- `app/lib/src/features/settings/presentation/screens/settings_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/widget/guest_routing_shells_test.dart`
- `docs/architect/project_structure.md`

Tervezett kimenetek:
- screen fajlok feature-first helyre mozgatva:
  - `app/lib/src/features/home/presentation/screens/home_screen.dart`
  - `app/lib/src/features/bets/presentation/screens/bets_screen.dart`
  - `app/lib/src/features/forum/presentation/screens/forum_screen.dart`
  - `app/lib/src/features/guest_info/presentation/screens/guest_info_screen.dart`
  - `app/lib/src/features/profile/presentation/screens/profile_screen.dart`
  - `app/lib/src/features/settings/presentation/screens/settings_screen.dart`
- router import frissites: `app/lib/src/app/router/app_router.dart`
- teszt importok frissitese: `app/test/widget/guest_routing_shells_test.dart`
- architektura doksi allapot frissites: `docs/architect/project_structure.md`

DoD:
- [ ] nincs hasznalt app screen fajl a `app/lib/src/screens/` gyujto alatt
- [ ] router importok feature-first pathokra mutatnak
- [ ] route smoke teszt valtozatlan viselkedessel lefut
- [ ] doksi es valos struktura konzisztens

Kockazat/rollback:
- import path torzs valtozasa build hibakat okozhat; gyors rollbackhez path move commit granularitasa kell.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/legacy_screens_feature_first_alignment.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/architect/project_structure.md`
- `docs/architect/routing_integrity.md`
- `app/lib/src/app/router/app_router.dart`
