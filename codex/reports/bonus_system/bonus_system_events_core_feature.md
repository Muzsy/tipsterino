## Mit találtunk?
- A `docs/data_model/user_events_table_doc.md` tisztázza, hogy a `user_events` tábla append-only, a kliens csak a saját rekordjait olvashatja, és csak a `read_at` mező módosítható; ez adta az alapot az `isUnread`, `amount`, `payload` stb. mezők feldolgozására.
- A Supabase konfigurációt a `supabaseConfigProvider` kezeli, így minden állapot és lekérés arra épül, hogy `isConfigured` és a `SupabaseClient` megléte döntő offline/not_configured esetben.

## Mit módosítottunk?
- Létrehoztuk az `events` feature mappáit (domain/data/application) és a `UserEvent` modellt, amely a Supabase mezőkkel dolgozik, a kötelező `fromMap` gyártóval, `copyWith`-szal és az `isUnread` getterrel.
- A `UserEventsRepository` a Supabase lekérdezést oldja meg `select('*')`, `order('created_at', ascending: false)` és `range` használatával, illetve csak a `read_at` mezőt frissíti a `markRead` metódusban.
- A Riverpod rétegben `userEventsRepositoryProvider` null-t ad offline vagy konfigurálatlan Supabase esetén, a `UserEventsNotifier` a `loadInitial`, `refresh`, `loadMore` és `markRead` metódusokkal kezeli a paginációt, hibákat és a `hasMore`/`isLoading*` flag-eket, valamint frissíti a memóriabeli listát `read_at` módosítás után.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/data/user_events_repository.dart`
- `app/lib/src/features/events/application/user_events_provider.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_core_feature.md`
- `codex/reports/bonus_system/bonus_system_events_core_feature.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`; a futás közben a CLI jelezte, hogy 17 csomaghoz van újabb kiadás, de a függőségi megkötések miatt nem frissültek automatikusan).

## Következő javasolt lépések
1. Az új provider bevonása az `/events` képernyőhöz (routing + UI) és a state vizualizálása az inboxban.
2. Egységtesztek hozzáadása a notifier állapotváltozásaihoz, különösen offline/not_configured, `loadMore` pagináció és `markRead` frissítés kapcsán.
3. A Supabase-sel szinkron `Topic`/`payload` adatok dokumentálása, hogy a UI a típus/kód kombináció alapján tudja a helyes komponenseket választani.
