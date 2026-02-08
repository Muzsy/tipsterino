# Events Inbox screen

## Cél és scope
A dokumentum összefoglalja az Events Inbox képernyő UX finomításait, a filter sávtól a mark-all-read és polling guard logikáig. A `user_events` tábla (típus és `read_at` szerződés) hátterét a `docs/data_model/user_events_table_doc.md` tárolja, itt az app-oldali komponensek viselkedését írjuk le.

## UI elemek
- **Filter bar:** `SegmentedButton` jeleníti meg az `EventsFilter`-et (All / Credits / Social / Challenges / System) az `AppLocalizations` kulcsaira támaszkodva; a kiválasztott szegmens szűri a listát a megfelelő logika szerint.
- **Mark all read gomb:** `AppBar`-ban lévő `IconButton` (tooltip: `eventsMarkAllReadTooltip`), csak akkor aktív, ha van az aktuális filter alatti olvasatlan elem, és nem fut a `markAllRead` művelet (`isMarkingAllRead`).
- **Empty state + load-more:** ha a `state.items` teljesen üres, akkor az `eventsEmptyTitle` + `eventsEmptyBody` jelennek meg a képernyőn; ha viszont csak a kiválasztott filter miatt nincs elem (pl. social/challenges/system), akkor csak az `eventsEmptyBody` látszik a listában. Görgetésnél, ha `extentAfter < 300` és a `userEventsProvider` nincs blokkolva (`isLoading`, `isLoadingMore`, `isMarkingAllRead`, `!hasMore`), akkor indul `loadMore`.

## Filter logika
A `EventsFilter` enum (`all`, `credits`, `social`, `challenges`, `system`) a `matches` kiterjesztéssel dönt az események láthatóságáról. Egyelőre csak a `credits` ág (`type == 'tippcoin_credit'`) ad vissza `true`, a `social`, `challenges` és `system` filterek explicit `false` visszatéréssel 0 elemet szolgáltatnak (előre létrehozott, még nem bekötött szűrők). Az `all` minden eseményt enged.

## Mark all read
A gomb csak az éppen aktív filterrel szűrt, olvasatlan eseményekre hat. A `UserEventsNotifier.markAllRead()` optimista módon beállítja minden célelem `readAt` mezőjét, majd sorban hívja a `UserEventsRepository.markRead()` metódust. Ha bármelyik API hívás sikertelen, az érintett eseményből visszaállítjuk az `readAt`-ot (partial rollback); végül a `isMarkingAllRead` flag false-ra vált. A felhasználó sikeres/hibás összegzését snack bar mutatja (`eventsMarkAllReadSuccess` / `eventsMarkAllReadPartial`).

## Polling + route visibility guard
A `Timer.periodic(Duration(seconds: 45))` (`_pollingTimer`) a `userEventsProvider.refresh()`-t hívja, de csak ha:
1. Az app életciklusa `resumed` (a guard a `WidgetsBindingObserver`-ben figyeli).
2. `_isRouteVisibleForPolling()` is igaz: `TickerMode.of(context)` engedélyezi a tickeket, és a `ModalRoute.of(context)` vagy null, vagy `isCurrent`.
Az `_pollRefresh()` ezt a guardot és a `userEventsProvider` state machine jelzőit (`isNotConfigured`, `isLoading`, `isLoadingMore`, `isMarkingAllRead`) ellenőrzi, ergo modal dialog alatt nem indít új fetch-et. A throttle logikát a `_stopPollingTimer()`/`_startPollingTimer()` a `didChangeAppLifecycleState`-ben tartja karban.

## Állapotgép
A `UserEventsState` mezői felelnek a képernyő viselkedéséért:
- `isNotConfigured` – nincs Supabase kliens, üzenetek nem kérhetők.
- `isLoading` – initial load folyamatban (`loadInitial`).
- `isLoadingMore` – pagination (scroll) közben. Scroll csak akkor indít `loadMore()`-t, ha egyik a fenti bool értékek sem true és még van további adat (`hasMore`).
- `isMarkingAllRead` – a bulk művelet (optimista + rollback). Ez letiltja a frissítést/gombot/poll refresh-t.
- `hasMore` – pagination flag; `loadMore` csak akkor fut, ha van még adat.
Az állapotokról a kódban `loadInitial()`, `loadMore()` és `markAllRead()` gondoskodik, visszaállítva a `errorMessage`-t is a hibakezelésben.

## Tesztek
- `app/test/widget/events_inbox_filter_test.dart`: a filter sáv működését nézi (`SegmentedButton` használata, `eventsFilterCredits` kiválasztása, `AppLocalizations.eventSignupBonusTitle`) úgy, hogy a social típusú eventek elrejthetők.
- `app/test/widget/events_inbox_polling_route_visibility_guard_test.dart`: a polling timer fetch számlálója növekszik a látható `/events` route-on, viszont egy modal dialog (`AlertDialog`) alatt megáll, majd visszaáll a láthatóság után.
- `app/test/widget/events_inbox_daily_bonus_test.dart`: `daily_bonus` eseményeknél megjelenik a lokalizált cím+szöveg, a `ListTile` `onTap`-ja mark read-ot hív, és után már nem aktív.
- `app/test/widget/events_inbox_mark_all_read_test.dart`: a mark-all-read gomb az aktuális filter szűrésére korlátozódik, és a siker/hibás visszajelzéseket snack bar mutatja.
- `app/test/widget/events_inbox_mark_all_read_partial_failure_test.dart`: sikertelen API hívás esetén csak a hibás eventek állnak vissza olvasatlannak.
- `app/test/widget/events_inbox_mark_all_read_refresh_lock_test.dart`: mark-all-read közben a frissítés/buttonok zárolódnak, hogy ne fusson párhuzamos aksi.
- `app/test/widget/events_inbox_polling_refresh_test.dart`: poll refresh működik, amíg /events látható, és megáll, ha elnavigálunk.
- `app/test/widget/events_inbox_route_test.dart`: `/events` betöltéskor offline állapot és lista megjelenik.
- `app/test/widget/events_inbox_data_flow_test.dart`: initial load és refresh indicator teszt a signup bonus-szal.

## Lokalizációs kulcsok
- `eventsFilterAll`, `eventsFilterCredits`, `eventsFilterSocial`, `eventsFilterChallenges`, `eventsFilterSystem` (filter bar szövegek).
- `eventsMarkAllReadTooltip`, `eventsMarkAllReadSuccess`, `eventsMarkAllReadPartial` (mark-all-read gomb, success/partial snack bar).
- `eventsEmptyTitle`, `eventsEmptyBody` (üres lista kommunikációja).
- `eventSignupBonusTitle`, `eventDailyBonusTitle`, `eventDailyBonusBody` (tesztekben is ellenőrzött szövegek).

## Definition of Done (DoD)
- [x] UI elemek részletesen dokumentáltak (filter bar, mark all read, empty state, load-more viselkedés).
- [x] Filter logika és `EventsFilter` legfontosabb mappingjai le vannak írva.
- [x] Mark all read (optimista, rollback, snack bar) és a `isMarkingAllRead` guardok leírva.
- [x] Polling + lifecycle + route visibility guardok, state machine és Supabase kontextus dokumentálva.
- [x] Kapcsolódó widget tesztek felsorolva, `./scripts/verify.sh --report …` szerepel a tesztállományban.
- [x] Lokalizációs kulcsok felsorolva.
