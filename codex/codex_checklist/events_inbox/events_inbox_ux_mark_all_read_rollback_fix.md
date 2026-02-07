# Events Inbox – Mark all read rollback fix checklist

## P1 – Preflight
- [x] A canvas rögzítette, hogy a `markAllRead()` rollback azért hibázik, mert a `UserEvent.copyWith` nem különbözteti meg az implicit/explicit `readAt` értékek között.
- [x] Megnéztük, hogyan használja a `UserEventsNotifier.markAllRead` a `filteredItems`-et és hogyan kezeli az optimista read_at-ot.

## P2 – Implementation
- [x] A `UserEvent.copyWith` sentinel mintával kapott explicit `null` támogatást, így `event.copyWith(readAt: null)` ténylegesen olvasatlanná teszi az elemet.
- [x] A `markAllRead`-ban most Set-ekkel követjük a target ID-kat, `isMarkingAllRead`-ot try/finally-ban reseteljük, és a sikertelen ID-k végül explicit null-átkapcsolással olvasatlanná válnak.
- [x] Új widget teszt (`events_inbox_mark_all_read_partial_failure_test.dart`) szimulál egy markRead hibát, ellenőrzi a `eventsMarkAllReadPartial` snackbar üzenetet és a hibás event továbbra is olvasatlannak marad (list tile onTap nem-null).

## P3 – QA gate
- [x] `./scripts/check.sh`
