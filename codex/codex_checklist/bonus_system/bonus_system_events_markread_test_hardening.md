# Bonus system Events markRead test hardening checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_markread_test_hardening.md` leírja, hogy a fake repo dedupolása miatt az idempotencia teszt nem volt megbízható.
- [x] Az új terv call-countot vezet be, így a notifier dupla hívását biztosan érzékeljük.

## P2 – Implementációs blokkok
- [x] Az `app/test/widget/events_inbox_data_flow_test.dart` fake repo eltávolította a dedupot és vezeti a `markReadCallCount`-ot, a teszt ellenőrzi a callCount/length kombinációt.
- [x] Az `app/test/unit/user_events_provider_test.dart` fake repo ugyanezt megkapta, és a markRead idempotencia teszt most callCount-ot vizsgál, nem csak a lista elemeit.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test`).
