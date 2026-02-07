# Events Inbox – Polling route visibility guard checklist

## P1 – Preflight
- [x] Rögzítettük, hogy a polling Timer az `initState`-ből `_startPollingTimer`-en keresztül indul, és `_pollRefresh()` hívódik 45 mp-enként, a guardok (`isNotConfigured`, `isLoading`, `isLoadingMore`, `isMarkingAllRead`) alatt.
- [x] Megbeszéltük, hogy ebben a taskban csak a refresh hívást guardoljuk a route láthatóságával (TickerMode + ModalRoute), nem számolunk a timer start/stop kezelésével.

## P2 – Implementation
- [x] Bevezettük az `_isRouteVisibleForPolling` helper metódust, amely ellenőrzi, hogy a `TickerMode` enged-e ticket és hogy az aktuális `ModalRoute.isCurrent`.
- [x] Az `_pollRefresh()` elején visszatérünk, ha a fenti guard nem teljesül, mielőtt a provider guardokat leellenőrizzük, így dialog alatt nem frissítünk.
- [x] Új widget teszt (`events_inbox_polling_route_visibility_guard_test.dart`) szimulál initial fetch + polling, megnyit egy dialogot, ellenőrzi, hogy a fetch count nem nő a dialog alatt, és bezárás után ismét növekszik.

## P3 – QA gate
- [x] `./scripts/check.sh`
