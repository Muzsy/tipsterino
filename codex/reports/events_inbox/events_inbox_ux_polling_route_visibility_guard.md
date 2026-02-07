## Mit találtunk?
- A polling timer korábban akkor is hívta a notifier `refresh()`-ét, ha modal route (pl. dialog) került az `/events` fölé, mivel a guardok csak az offline/loading állapotokra figyeltek.
- A `TickerMode` és `ModalRoute.isCurrent` kombinációja egy egyszerű, stabil jele annak, hogy a screen valóban látható-e; ezt a guardot vezettük be.

## Mit módosítottunk?
- `_isRouteVisibleForPolling()` helper készült, ami ellenőrzi a `TickerMode` státuszt és a `ModalRoute`-ot, illetve csak akkor engedi a refresh hívást, ha a route valóban látható.
- Az `_pollRefresh()` most ezeket a guardokat használja, még mielőtt a provider állapotát olvasná; így dialog alatt a timer lefut, de nem generál új fetchet.
- Új widget teszt (`events_inbox_polling_route_visibility_guard_test.dart`) megnyitja a `/events` route-ot, megmutatja, hogy a fetch count nő a poll során, majd a dialog alatt nem, és a dialog bezárása után ismét növekszik.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/test/widget/events_inbox_polling_route_visibility_guard_test.dart`
- `canvases/events_inbox/events_inbox_ux_polling_route_visibility_guard.md`
- `codex/codex_checklist/events_inbox/events_inbox_ux_polling_route_visibility_guard.md`
- `codex/reports/events_inbox/events_inbox_ux_polling_route_visibility_guard.md`

## Tesztek
- `./scripts/check.sh` – PASS

## Következő javasolt lépések
1. Ha további overlay-ek (pl. bottom sheet) kerülnek az inbox fölé, érdemes ellenőrizni, hogy valóban isCurrent-e ezek alatt is ez a guard.
