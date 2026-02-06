## Mit találtunk?
- Az `EventsInboxScreen` nem rendelkezett filter UI-val, a listát mindig a teljes `state.items` listából építette, illetve a provider sem tárolt semmilyen státusz-filtert.

## Mit módosítottunk?
- Bevezettük az `EventsFilter` enumot, és a `UserEventsState` kapott egy filter mezőt plusz `filteredItems` gettert; a notifier `setFilter` metódusa védi a filter megtartását.
- Az Inbox tetején egy `SegmentedButton` alapú filter sort jelenítünk meg, a gombok feliratait a `eventsFilter*` lokalizációs kulcsokon keresztül mutatjuk, a lista pedig a szűrt elemekből épül.
- Az EN/HU ARB fájlok, valamint a generált `AppLocalizations` osztályok bekerült a filter szövegekkel; a widget teszt ellenőrzi a default/all és credits szűréseket egy fake repositoryval.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/domain/events_filter.dart`
- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `app/test/widget/events_inbox_filter_test.dart`
- `codex/codex_checklist/events_inbox/events_inbox_ux_filter_bar.md`
- `codex/reports/events_inbox/events_inbox_ux_filter_bar.md`

## Tesztek
- `./scripts/check.sh` – PASS (analyze + widget/unit suite)

## Következő javasolt lépések
1. Ha később további szűrők jönnek (pl. social vagy challenges), bővítsd az `EventsFilter.matches` logikát és a gombokat is.
2. Ha bevezetjük a filter szerver-oldali verzióját, győződj meg róla, hogy a filteredItems getter a cache-elt listára épít, vagy kövesse az új query paramétereket.
