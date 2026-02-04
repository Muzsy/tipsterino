# Bonus system Events core feature checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_core_feature.md` dokumentáció leírja a `user_events` tábla szerkezetét, az új `events` feature mappáit és a Supabase-követelményeket (paginated select + `read_at` update).
- [x] A canvas tartalmazza az elvárt `UserEvent` mezőket, a `UserEventsRepository` funkcióit és a provider state/metódus követelményeit.

## P2 – Implementációs blokkok
- [x] Készült a `UserEvent` domain modell (`app/lib/src/features/events/domain/user_event.dart`) a Supabase `created_at`/`read_at` mezők feldolgozásával és az `isUnread` getterrel.
- [x] Megvalósítottuk a paginált, `created_at desc` szűrésű `UserEventsRepository.fetchPage`-t és a `markRead` `read_at` frissítését (`app/lib/src/features/events/data/user_events_repository.dart`).
- [x] A `userEventsRepositoryProvider`/`userEventsProvider` állapotkezelés offline és not_configured esetekre mellett a `loadInitial`, `refresh`, `loadMore`, `markRead` metódusokat is nyújtja (`app/lib/src/features/events/application/user_events_provider.dart`).

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (csomagfeloldás, `flutter analyze`, `flutter test`).
