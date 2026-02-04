# Bonus system Events inbox UI shell checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_inbox_ui_shell.md` részletezi az `/events` route-ot, a Settings-beli belépést és a minimális inbox UX-et (offline, empty, lista, locale stringek).
- [x] A canvas megnevezi az új lokalizációs kulcsokat az EN/HU ARB fájlokban.

## P2 – Implementációs blokkok
- [x] Elkészült az `EventsInboxScreen` (`app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`), logikai állapotkezeléssel, offline/empty/list kezeléssel és a `markRead` hívással csak olvasatlan eseményekre.
- [x] A `GoRouter` shell route-ja tartalmazza a `/events` GoRoute-ot (`app/lib/src/app/router/app_router.dart`), és a settings képernyőben egy `ListTile` hivatkozik a `loc.eventsInboxEntry` címkére (`app/lib/src/screens/settings_screen.dart`).
- [x] Az `app_en.arb` és `app_hu.arb` kiegészültek az új kulcsokkal, így a `AppLocalizations` generált fájljai (`app_localizations*.dart`) is frissültek.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test`).
