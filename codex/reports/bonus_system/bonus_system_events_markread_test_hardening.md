## Mit találtunk?
- A prior fake repo dedupolta a `markReadIds`-et, ezért a markRead idempotencia teszt _minden esetben_ zöld maradt, még akkor is, ha a notifier kétszer hívta a repo `markRead`-ját.
- Szükséges volt a call-count bevezetése, hogy a teszt valóban felfedje a dupla hívást.

## Mit módosítottunk?
- A widget teszt fake repo-ja most `markReadCallCount`-ot vezet, nem dedupol, így a `events_inbox_data_flow_test.dart` markRead tesztje már ellenőrzi a call countot és a lista hosszát (a második tap nem növeli a callCount-ot és a listában csak egy elem marad).
- A unit teszt fake repo-ja is hasonlóan viselkedik, és a `user_events_provider_test.dart` markRead tesztje szintén a callCountot ellenőrzi, nem csak a lista elemeit.

## Módosított/létrehozott fájlok
- `app/test/widget/events_inbox_data_flow_test.dart`
- `app/test/unit/user_events_provider_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_markread_test_hardening.md`
- `codex/reports/bonus_system/bonus_system_events_markread_test_hardening.md`

## Tesztek
- `./scripts/check.sh` – PASS (dependency resolution + `flutter analyze` + `flutter test`).

## Következő javasolt lépések
1. Ellenőrizzük, hogy a notifier ténylegesen nem hívja meg újra a repo `markRead`-ját, ha a state már read; ha további guardokat vezetünk be, frissítsük a call-count teszteket is.
2. Ha a `markRead`-hoz új hibakezelést adunk, győződjünk meg róla, hogy a callCount log is naplózza a hibás kéréseket.
