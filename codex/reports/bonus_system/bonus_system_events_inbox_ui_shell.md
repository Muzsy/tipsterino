## Mit találtunk?
- A canvas rögzíti, hogy az `/events` route-ot a ShellRoute alá kell tenni, a Settings felületre pedig router alapú ListTile kell az inbox eléréséhez, így az események csak bejelentkezett, konfigurált Supabase állapotban jelenhetnek meg.
- A UI-nak minimalista komponenseket kell mutatnia offline/empty/nézethez, egyszerű timestampet és kis dot jelzést, valamint a `markRead` hívást csak olvasatlan eseményre.

## Mit módosítottunk?
- Megírtuk az `EventsInboxScreen`-t (`app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`), amely a provider állapotára építve offline/empty/loading/error nézeteket mutat, listával és tap esetén `markRead` hívással.
- Az `app_router` shell route-ja most tartalmazza a `/events` GoRoute-ot, és a settings képernyőben a `loc.eventsInboxEntry` címkét használó `ListTile` routerrel navigál az új képernyőre (`app/lib/src/app/router/app_router.dart`, `app/lib/src/screens/settings_screen.dart`).
- Kiegészítettük az `app_en.arb` és `app_hu.arb` fájlokat a szükséges `events` kulcsokkal, majd futtattuk a `flutter gen-l10n`-t, így az `app_localizations*.dart` fájlok is frissültek.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/lib/src/screens/settings_screen.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui_shell.md`
- `codex/reports/bonus_system/bonus_system_events_inbox_ui_shell.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Az `/events` inboxot bekötni a shellbottom nav UI-jához (pl. Settings-hez közel, routeren keresztül) és a zero-lista esetet további vizuális elemekkel színesíteni.
2. Widget/egységtesztet hozzáadni az `EventsInboxScreen`-hez, különösen a offline/empty/loading állapotokra és a `markRead` hívásra.
3. A `payload`-ban található extra adatok alapján bővíteni a megjelenítést (pl. felhasználó, összeg kiemelés) a UI következő iterációjában.
