## Mit találtunk?
- A refresh ikon és a `RefreshIndicator` is engedélyezve maradt, miközben a `markAllRead()` bulk művelet `isMarkingAllRead` flagje true volt.
- Ez zavart okozhatott a UX-ben, mert a felhasználó ilyenkor úgy érezhette, hogy új listafrissítés indult, pedig a backend mellett már zajlott egy másik művelet.

## Mit módosítottunk?
- Az AppBar refresh gombja `null`-ra állítja az `onPressed`-t, ha a `state.isMarkingAllRead` true, így a gomb inaktív marad a bulk feldolgozás alatt.
- A `RefreshIndicator.onRefresh` azonnal visszatér, ha `isMarkingAllRead`, különben meghívja a notifier.refresh-et; így a pull-to-refresh nem indít új `fetchPage` hívást közben.
- A `ListView` physics-e `NeverScrollableScrollPhysics`, amíg a bulk zajlik, ezért a scroll/indicator nem mozdul.
- `events_inbox_mark_all_read_refresh_lock_test.dart` teszteli, hogy a markAllRead futása közben a refresh ikon le van tiltva, a pull-to-refresh nem növeli a `fetchOffsets` listát, majd a bulk vége után újra meghívható lesz.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/test/widget/events_inbox_mark_all_read_refresh_lock_test.dart`
- `canvases/events_inbox/events_inbox_ux_mark_all_read_refresh_lock.md`
- `codex/goals/canvases/events_inbox/fill_canvas_events_inbox_ux_mark_all_read_refresh_lock.yaml`
- `codex/codex_checklist/events_inbox/events_inbox_ux_mark_all_read_refresh_lock.md`
- `codex/reports/events_inbox/events_inbox_ux_mark_all_read_refresh_lock.md`

## Tesztek
- `./scripts/check.sh` – PASS

## Következő javasolt lépések
1. Ha a backend is támogatja a bulk rollbackot, gondoskodjunk róla, hogy a refresh guardok továbbra is pontosan tükrözzék a `markAllRead` állapotát (különösen partial failure esetén).
