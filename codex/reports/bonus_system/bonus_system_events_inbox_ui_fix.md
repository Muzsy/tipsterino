## Mit találtunk?
- A canvas P0–P2 pontjai a betöltés lifecycle-át, a theme szabályok betartását és a refresh/loadMore UX-et emelik ki.
- A meglévő `EventsInboxScreen` nem indította el automatikusan az első lekérést, valamint hardcode színeket használt.

## Mit módosítottunk?
- A képernyő most `ConsumerStatefulWidget`, `initState`-ben microtask segítségével a `userEventsProvider.notifier.loadInitial()` indul, így belépéskor elindul a betöltés mindig.
- A UI a `Theme.of(context).colorScheme` és `textTheme` tokeneket használja: az unread dot a `primary` színt kapja, a címsorok `titleMedium` alapúak, illetve már nincs Colors.* vagy újrafogalmazott `TextStyle`.
- AppBar actionként friss ikon lett, a listákban `RefreshIndicator` van `AlwaysScrollableScrollPhysics`-szal, a ScrollController listener threshold alapján hívja a `loadMore()`-t (`extentAfter < 300` és `state.hasMore && !isLoading*`).

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui_fix.md`
- `codex/reports/bonus_system/bonus_system_events_inbox_ui_fix.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Készíts e2e/widget tesztet, amely ellenőrzi a pull-to-refresh és `loadMore` trigger működését konfigurált Supabase állapotban.
2. Ha a `EventsInboxScreen` kap más vizuális frissítéseket (detail, icon), ellenőrizd, hogy a Theme tokenek továbbra is érvényesek maradnak.
