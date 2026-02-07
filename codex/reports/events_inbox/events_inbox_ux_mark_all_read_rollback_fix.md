## Mit találtunk?
- A `markAllRead()` rollback nem működött, mert a `UserEvent.copyWith` nem engedte explicit null-ra állítani a `readAt`-ot, így a sikertelen elemek maradtak `read` állapotban.
- A `markAllRead`-ban sikertelen ID-kat listában kezeltük, és az `isMarkingAllRead` értékét nem garantált volt visszaállítani, ha hibába futottunk.

## Mit módosítottunk?
- A `UserEvent.copyWith` sentinel mintával külön kezeli azt, ha a hívó explicit `null`-t ad át, így `event.copyWith(readAt: null)` már ténylegesen olvasatlanná teszi az elemet.
- A `markAllRead` most Set-ekkel követi az ID-kat, try/finally-ben garantálja az `isMarkingAllRead = false` visszaállítást, és a sikertelen ID-k explicit null-átkapcsolást kapnak, hogy maradjon unread.
- Hozzáadtunk egy widget tesztet (`events_inbox_mark_all_read_partial_failure_test.dart`), amely egy hibát dobó `markRead`-bel szimulálja a rollbacket, ellenőrzi a `eventsMarkAllReadPartial` snackbar üzenetet és azt, hogy a hibás event továbbra is tapintható, olvasatlan marad.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/test/widget/events_inbox_mark_all_read_partial_failure_test.dart`
- `codex/codex_checklist/events_inbox/events_inbox_ux_mark_all_read_rollback_fix.md`
- `codex/reports/events_inbox/events_inbox_ux_mark_all_read_rollback_fix.md`

## Tesztek
- `./scripts/check.sh` – PASS

## Következő javasolt lépések
1. Ha a backend oldalon is támogatjuk a partial failure jelzést, győződjünk meg arról, hogy a kliensnél az optimista read_at rollback és a snackbar szövegek továbbra is összehangoltan reagálnak.
