# Bonus system Events inbox UI tests checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_inbox_ui_tests_docs.md` rögzíti az `/events` route offline/not_configured renderelését, az auth/supabase override-okat és a szükséges lokalizált stringeket.
- [x] Az előző taskban már létrejött `/events` route és settings belépési pont (shell route + ListTile) stabil alapot ad az új teszthez.

## P2 – Implementációs blokkok
- [x] `app/test/widget/events_inbox_route_test.dart` hétfőn a `TipsterinoApp` auth+supabase override-jával a `/events` route-ra navigál és ellenőrzi, hogy az `eventsInboxTitle` és `offlineNotice` megjelenik.
- [x] A test `AuthNotifier`-t `authenticated` állapottal és `autoListen: false` opcióval példányosítja, továbbá a `SupabaseConfiguration(isConfigured: false)`-t használja, ahogy a dokumentáció kérte.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test` gemkapocs).
