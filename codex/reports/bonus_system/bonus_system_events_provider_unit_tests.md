## Mit találtunk?
- A canvas feladat `UserEventsNotifier` logikáját akarja ellenőrizni UI nélkül, ezért a tesztek ProviderContainer + fake repo overrides megközelítést alkalmazzák.
- A fake repo `UserEventsRepository`-t örökli, de a SupabaseClient csak dummy adatforrásként szerepel, így a teszt a `fetchPage`/`markRead` hívásokat a memóriabeli map alapján szimulálja.

## Mit módosítottunk?
- Létrehoztuk az `app/test/unit/user_events_provider_test.dart` fájlt, amelyben:
  1. a `not_configured` eset nem indítja el a loadInitial-t és megtartja az offline flaget,
  2. a `loadInitial` betölti a listát és helyesen állítja a hasMore/ loading állapotot,
  3. a `refresh` újratölti a 0. oldal tartalmát,
  4. a `loadMore` appendeli a következő oldalt, de guardol ha nincs több,
  5. a `markRead` egyszer hívja `markRead`-ot és nem dupláz a második tapra,
  6. a hibakezelő tesztek megmutatják, hogy fetch/loadMore/markRead exception esetén az errorMessage bekerül és az állapot megfelelően visszaáll.
- A fake repo `fetchOffsets` és `markReadIds` listákból látható a notifier által végrehajtott kérések sorrendje.

## Módosított/létrehozott fájlok
- `app/test/unit/user_events_provider_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_provider_unit_tests.md`
- `codex/reports/bonus_system/bonus_system_events_provider_unit_tests.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Ha kiderül, hogy más event típusok is bekerülnek, bővítsük a `FakeUserEventsRepository`-t, hogy a külső payload mezők is tesztelhetők legyenek.
2. Érdemes lehet `markRead`-ra külön unit/integration tesztet írni, ahol a notifier belső állapotát (pl. `errorMessage`) a hívások szekvenciája szerint ellenőrizzük.
