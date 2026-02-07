## Mit találtunk?
- Az Events Inbox jelenleg kézi frissítéseken és `markAllRead`-on alapszik, de a felhasználó számára nem látszik gyorsan, ha új esemény érkezik.
- A `EventsInboxScreen` init-fázisa és a notifier guardjai már megadják a biztonsági sávot ahhoz, hogy egy óvatos pollingot bevezethessünk (nem indítjuk, ha offline vagy már folyamatban van frissítés).

## Mit módosítottunk?
- Az `EventsInboxScreen` most `WidgetsBindingObserver`-ral és egy 45 másodperces `Timer.periodic`-szal fut; a timer csak akkor aktív, ha a screen látható és az app `resumed`, és minden tick előtt ellenőrizzük a `isNotConfigured`, `isLoading`, `isLoadingMore`, `isMarkingAllRead` flagokat, különben meghívjuk a notifier `refresh()`-ét.
- A `dispose()` törli a timer-t és eltávolítja az observert, így nem marad aktív lecsapás, amikor elhagyjuk a route-ot.
- Hozzáadtunk egy widget tesztet (`events_inbox_polling_refresh_test.dart`), amely a polling alapértelmezett időzítésével szimulálja az initial + refresh fetcheket, majd a /home-ra történő navigáció után már nem növeli tovább a fetch számlálót.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/test/widget/events_inbox_polling_refresh_test.dart`
- `canvases/events_inbox/events_inbox_ux_polling_refresh.md`
- `codex/codex_checklist/events_inbox/events_inbox_ux_polling_refresh.md`
- `codex/reports/events_inbox/events_inbox_ux_polling_refresh.md`

## Tesztek
- `./scripts/check.sh` – PASS

## Következő javasolt lépések
1. Ha a backend tud új eseményekről push értesítést küldeni, érdemes megvizsgálni a Supabase Realtime beépítését (a polling visszavonása mellett).
