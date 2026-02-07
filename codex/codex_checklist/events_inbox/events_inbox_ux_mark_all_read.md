# Events Inbox UX mark all read checklist

## P1 – Preflight
- [x] A canvas rögzítette, hogy a mark all read csak a jelenlegi `state.filteredItems`-re vonatkozik és read_at-only contracton fut.
- [x] Ellenőriztük a `UserEventsNotifier.markRead` implementációját, és a UI AppBar action-ját, mire építettünk.

## P2 – Implementation
- [x] A state most tartalmaz `isMarkingAllRead` mezőt, a notifier `markAllRead()`-ja optimistán read_at-ot állít, hívja `_repository.markRead`, és rollback-eli a sikertelen ID-kat.
- [x] Az AppBar actions-ba bekerült az új `done_all` gomb, amit az `eventsMarkAllReadTooltip` jelöl, csak akkor aktív, ha van unread az aktuális lista, nincs offline/marking állapot.
- [x] Az EN/HU ARB-ok és `AppLocalizations` osztályok tartalmazzák a `eventsMarkAllReadTooltip`, `eventsMarkAllReadSuccess` és `eventsMarkAllReadPartial` kulcsokat.
- [x] Új widget teszt (`events_inbox_mark_all_read_test.dart`) ellenőrzi a credits/all filter sorozatot és a snackbar megjelenést.

## P3 – QA gate
- [x] `./scripts/check.sh`
