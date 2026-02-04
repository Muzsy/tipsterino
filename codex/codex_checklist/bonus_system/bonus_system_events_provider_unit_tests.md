# Bonus system Events provider unit tests checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_provider_unit_tests.md` részletezi a `UserEventsNotifier` loadInitial/refresh/loadMore/markRead és hibaág viselkedését.
- [x] A tesztek `ProviderContainer` + override megoldással indulnak, fake `UserEventsRepository`-t használva a valódi SupabaseClient helyett.

## P2 – Implementációs blokkok
- [x] Elkészült az `app/test/unit/user_events_provider_test.dart` fájl, benne not_configured, loadInitial, refresh, loadMore, markRead, valamint hibakezelő ágak.
- [x] A fake repo logolja a `fetchPage` offseteket és `markRead` hívásokat, továbbá támogatja a hibaszimulációkat (`throwOnFetch`, `throwOnMarkRead`).
- [x] A markRead-idempotens teszt ellenőrzi, hogy az ismételt hívás nem rendel újabb `markRead` hívást.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test`).
