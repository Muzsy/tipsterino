# Events Inbox – Polling route-láthatóság guard

**TASK_SLUG:** `events_inbox_ux_polling_route_visibility_guard`

## 🎯 Funkció

Az Events Inbox polling refresh (45 mp Timer.periodic) csak akkor hívhassa a
`userEventsProvider.notifier.refresh()`-t, ha a képernyő ténylegesen „látható”
(route current / foreground).

Konkrétan:
- ha egy **dialog / modal / bottom sheet** takarja a képernyőt, a polling **ne** frissítsen
- ha visszatérünk a képernyőre (a route újra current), a polling ismét frissíthessen
- a meglévő guardok (isNotConfigured / isLoading / isLoadingMore / isMarkingAllRead) maradjanak

Nem cél:
- Timer teljes leállítása route eseményekre (RouteObserver/RouteAware) – itt csak a refresh hívás guardolása
- új l10n kulcsok
- router refaktor

## 🧠 Fejlesztési részletek

### Érintett fájlok (valós repó)
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- Új teszt: `app/test/widget/events_inbox_polling_route_visibility_guard_test.dart`

### Implementáció
- Az `_pollRefresh()` elejére tegyél route-láthatóság guardot.
- Preferált guard logika (minimal, stabil):
  - `TickerMode.of(context)` legyen `true` (Navigator jellemzően letiltja a tickert nem-current route alatt)
  - és/vagy `ModalRoute.of(context)?.isCurrent == true` (ha elérhető)

Javasolt helper:
- `bool _isRouteVisibleForPolling()` ami a fenti 1–2 feltételt ellenőrzi, és csak akkor enged refresh-t.

### Current polling specifics
- A `Timer.periodic` a `_startPollingTimer`-ben indul az `initState`-ből, és `_pollRefresh()`-t hív 45 mp-enként.
- `_pollRefresh()` az `EventsInboxScreen` állapotát olvassa (`state = ref.read(userEventsProvider)`), valamint a guardok segítségével (`isNotConfigured`, `isLoading`, `isLoadingMore`, `isMarkingAllRead`) ellenőrzi, mielőtt `ref.read(userEventsProvider.notifier).refresh()`-t hívna.

### Elvárt viselkedés
- Ha a képernyő takarva van (dialog route fent van):
  - a Timer tick lefut, de `_pollRefresh()` **return**-nel kilép, nem fetch-el
- Ha a dialog bezárul:
  - a következő tick már enged refresh-t (a meglévő provider guardok figyelembevételével)

## 🧪 Tesztállapot

Kötelező widget teszt:
- nyisd meg a `/events` route-ot, ellenőrizd az initial fetch-et
- pumpolj >=45s → legyen polling refresh (fetch count nő)
- nyiss `showDialog`-gal egy modal route-ot az Events felett
- pumpolj >=45s → **ne** nőjön a fetch count (route guard működik)
- zárd be a dialogot
- pumpolj >=45s → fetch count újra nő (visszatérés után ismét frissít)

Repo gate:
- `./scripts/check.sh` PASS

## 🌍 Lokalizáció
Nincs új UI szöveg → nincs ARB módosítás.

## 📎 Kapcsolódások
- `canvases/events_inbox/events_inbox_ux_polling_refresh.md`
- `docs/qa/testing_guidelines.md`
- `docs/codex/overview.md`
- `docs/codex/yaml_schema.md`
