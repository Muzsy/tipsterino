## Mit találtunk?
- A canvas szerinti split kéri, hogy a `/events` route offline/not_configured módban is rendereljen stabilan, ezért a teszt átveszi a Supabase konfigurációt és a hitelesítő állapotot.
- Az `EventsInboxScreen` és a settings belépési pont korábban már létrejött, így csak a widget tesztre kellett koncentrálni.

## Mit módosítottunk?
- Írtunk egy `events_inbox_route_test.dart` widget tesztet, amely `ProviderScope` override-okkal a `TipsterinoApp`-ot futtatja, majd a `GoRouter`-rel a `/events` route-ra navigál és ellenőrzi, hogy a `loc.eventsInboxTitle` és `loc.offlineNotice` feliratok megjelennek.
- A teszt az `AuthNotifier`-t `authenticated` státusszal, `autoListen: false`-szal és a `SupabaseConfiguration(isConfigured: false)` értékkel indítja, így szimulálja a not_configured offline állapotot.
- A teszt kifejezetten arra fókuszál, hogy az offline inbox state ne dobjon kivételt és a lokalizált szövegek legyenek láthatók.

## Módosított/létrehozott fájlok
- `app/test/widget/events_inbox_route_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui_tests_docs.md`
- `codex/reports/bonus_system/bonus_system_events_inbox_ui_tests_docs.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Készíts további widget teszteket a `/events` route laza állapotaival (például listás állapot, `markRead` teszt), ha a UI erre lehetőséget ad.
2. Dokumentáld a `payload`-ban érkező típus/kód kombinációk hatását a widget megjelenítésére, hogy a jövőbeli tesztek pontosan leképezhessék a valódi eventeket.
3. Ha a Supabase konfiguráció változik, bővítsd az override-okat és ellenőrizd, hogy a `Settings` screen LinkListTile-ja megmarad a kívánt állapotban.
