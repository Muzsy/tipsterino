# Events Inbox UX filter bar checklist

## P1 – Preflight
- [x] A canvas rögzítette az `EventsInboxScreen` jelenlegi UI struktúráját, a `UserEventsState` mezőit és az item mapping/empty/offline állapotokat.

## P2 – Implementation
- [x] Created `EventsFilter` enum és a `matches(UserEvent)` helper, leképezve a `tippcoin_credit`-et a `credits` filterre.
- [x] `UserEventsState` most tartalmaz filter mezőt + `filteredItems` gettert, a notifier `setFilter` metódusa frissíti, load/refresh nem nullázza.
- [x] Az `EventsInboxScreen` filter sort jelenít meg `SegmentedButton`-nel, a lista a `state.filteredItems` alapján renderel, és a filter gombok l10n-kulcsokat (eventsFilter*) használják.
- [x] Új lokalizációs kulcsok (`eventsFilter*`) az EN/HU ARB fájlokban és a generált `AppLocalizations` osztályokban.
- [x] Widget teszt (`events_inbox_filter_test.dart`) ellenőrzi az alapértelmezett/credits filtereket egy fake repositoryval.

## P3 – QA gate
- [x] `./scripts/check.sh`
