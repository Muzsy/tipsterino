# Bonus system Events inbox UI test coverage checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_inbox_ui_test_coverage.md` célul tűzi ki az initial load, refresh, loadMore és markRead viselkedések bizonyítását a `/events` route-on.
- [x] A kötött widge-trendszer `ProviderScope`-ot + `TipsterinoApp()`-ot használ, és a fake repo a `UserEventsRepository` típusát követi.

## P2 – Implementációs blokkok
- [x] `app/test/widget/events_inbox_data_flow_test.dart` új testfájl override-olt provider-ekkel és fake repo-val ellenőrzi a működést.
- [x] Az initial load teszt biztosítja, hogy megjelenik a signup bonus tartalom, és a fake repo `fetchPage` offsetje 0.
- [x] A refresh teszt megtalálja a `RefreshIndicator`-t és az AppBar refresh actiont, majd második fetch-et vár a 0 offsetre.
- [x] A loadMore teszt scrollozással triggereli a fetchet oldalt, így a fake repo `fetchOffsets` listája tartalmazza a 20-as offsetet.
- [x] A markRead teszt az `eventsInboxTitle` tile-ra tapogat, és ellenőrzi, hogy `markRead` csak egyszer hívódik meg (idempotens).

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test`).
