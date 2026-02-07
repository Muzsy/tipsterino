# Events Inbox – Mark all read refresh lock checklist

## P1 – Preflight
- [x] Rögzítettük, hogy a refresh ikon és a pull-to-refresh akció nem figyel a `isMarkingAllRead` állapotra, így a bulk művelet alatt a felhasználó még indíthat listafrissítést.
- [x] Ellenőriztük, hogy a `UserEventsState.isMarkingAllRead` valóban true lesz a bulk művelet közben, tehát erre lehet építeni a guardot.

## P2 – Implementation
- [x] Az AppBar refresh gombja csak akkor kap `onPressed`-et, ha nincs offline/markAllRead állapot, így inaktív marad a bulk akció alatt.
- [x] A `RefreshIndicator.onRefresh` guardot kapott: ha `state.isMarkingAllRead` true, akkor azonnal visszatér, különben meghívja a notifier.refresh-et.
- [x] A `ListView` physics-e `NeverScrollableScrollPhysics`, amíg `markAllRead` fut, így a pull-gesture sem mozdul.
- [x] Új widget teszt (`events_inbox_mark_all_read_refresh_lock_test.dart`) ellenőrzi, hogy a markAllRead közben a refresh ikon le van tiltva, a pull-to-refresh nem dob új fetchPage hívást, majd a bulk vége után ismét működik.

## P3 – QA gate
- [x] `./scripts/check.sh`
