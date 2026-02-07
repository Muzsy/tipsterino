# Events Inbox – UX finomítások docs sync checklist

## P1 – Preflight
- [x] Átnéztük a `docs/data_model/user_events_table_doc.md`-ot és a `user_events` szűrés/mark all read implementációt (`events_inbox_screen.dart`, `user_events_provider.dart`, `events_filter.dart`, `user_event.dart`), hogy a dokumentáció pontos hátteret kapjon.
- [x] Megfogalmaztuk, hogy a doc fókusza a filter bar + mark all read + polling guard + state machine + tesztek + DoD összegzése lesz (canvasban rögzítve).

## P2 – Implementation
- [x] Létrehoztuk a `docs/screens/events_inbox_screen.md` fájlt: UI elemek, filter logika, mark all read viselkedés, polling/guard, `UserEventsState` flagjei, lokalizációs kulcsok, tesztek és DoD.
- [x] Frissítettük a `docs/README.md`-et a `docs/screens/events_inbox_screen.md` hivatkozással, hogy a képernyő dokumentáció könnyen megtalálható legyen.

## P3 – QA gate
- [x] `./scripts/check.sh`
