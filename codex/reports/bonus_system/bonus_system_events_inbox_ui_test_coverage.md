## Mit találtunk?
- A canvas feladat arra fókuszál, hogy a `/events` route kezdeti betöltése, refresh, loadMore és markRead viselkedése dokumentáltan működjön.
- A provider rétegek miatt a tesztben fake `UserEventsRepository`-t kell használni, mert így a `userEventsRepositoryProvider` hiányában is biztosítható a szolgáltatás viselkedése.

## Mit módosítottunk?
- Készítettünk egy `FakeUserEventsRepository`-t, ami a `UserEventsRepository`-t örökli, a `SupabaseClient('http://localhost', 'anon')`-t adja meg a super konstruktorának, és `fetchPage`/`markRead` hívásokra logol.
- Az `events_inbox_data_flow_test.dart` négy tesztesetet tartalmaz:
  1. Initial load: a signup bonus címek és body megjelennek, a fake repo offsetje 0.
  2. Refresh: van `RefreshIndicator`, az AppBar refresh action megtalálható (refresh / refresh_outlined ikon), majd újabb fetch 0 offsettel.
  3. Load more: 20 item után scrollozva hívódik a fetch page 20.
  4. MarkRead: a tile-ra való tap egyszer hívja meg `markRead`, és második tap után sem duplázódik.
- A widget teszt a meglévő `ProviderScope` + `TipsterinoApp` mintát követi, ezen felül override-olja az auth és repo provider-eket, valamint a supabase konfigot.

## Módosított/létrehozott fájlok
- `app/test/widget/events_inbox_data_flow_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui_test_coverage.md`
- `codex/reports/bonus_system/bonus_system_events_inbox_ui_test_coverage.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Ha szükséges, bővítsük a fake repo-t, hogy különböző típus/kód kombinációkat is kiszolgáljon (pl. `amount` null lehet). 
2. Érdemes meglévő analyzer tesztet megújítani, hogy a markRead állapotfrissítéshez UI response is legyen.
