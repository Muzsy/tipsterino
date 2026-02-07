## Mit találtunk?
- Az Events Inbox UX finomításairól (filter bar, mark all read, polling guard, state machine, tesztek) nem volt egységes, repóban tárolt dokumentum, ami bemutatja a jelenlegi viselkedést és a DoD-et.
- A kapcsolódó implementációk (`events_inbox_screen.dart`, `user_events_provider.dart`, `events_filter.dart`, `user_event.dart`) valamint a `user_events` tábla szerződése (`docs/data_model/user_events_table_doc.md`) adták meg a forrást a leírásokhoz.

## Mit módosítottunk?
- Kiegészítettük a canvas leírását, hogy pontosan megfogalmazzuk, mit dokumentálunk (filter mapping, mark-all-read viselkedés, polling guard, state machine, tesztek + DoD).
- Megírtuk a `docs/screens/events_inbox_screen.md` fájlt a kért szekciókkal (UI elemek, filter logika, mark all read optimista + rollback, polling guarded refresh, `UserEventsState` flagek, lokalizációs kulcsok, tesztek, DoD).
- Hivatkozással frissítettük a `docs/README.md`-et, hogy a képernyő dokumentáció könnyen megtalálható legyen a kapcsolódó anyagok között.

## Módosított/létrehozott fájlok
- `canvases/events_inbox/events_inbox_ux_finomitasok_docs_sync.md`
- `docs/screens/events_inbox_screen.md`
- `docs/README.md`
- `codex/codex_checklist/events_inbox/events_inbox_ux_finomitasok_docs_sync.md`
- `codex/reports/events_inbox/events_inbox_ux_finomitasok_docs_sync.md`

## Tesztek
- `./scripts/check.sh` – PASS (pub elavult csomagfigyelmeztetéssel, de futás sikeres és minden teszt zöld)

## Következő javasolt lépések
1. Bővítsük a dokumentációt, amikor a social/challenges/system filterek is valós eseményeket fognak kezelni, illetve tegyük hozzá az új teszteket, ha új viselkedések jelennek meg.
