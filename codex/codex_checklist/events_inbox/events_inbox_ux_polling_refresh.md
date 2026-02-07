# Events Inbox – Polling refresh checklist

## P1 – Preflight
- [x] Rögzítettük, hogy az `EventsInboxScreen` ConsumerStatefulWidget, és az `initState`-ben `Future.microtask` hívja a `loadInitial()`-t, tehát a polling a meglévő kezdőbetöltéstől függetlenül fut.
- [x] Ellenőriztük, hogy a `refresh`/`loadMore` guardok (`isNotConfigured`, `isLoading`, `isLoadingMore`, `isMarkingAllRead`, `hasMore`) már megvannak a notifierben, így a polling nem indíthat újabb betöltést, ha van folyamatban lévő.

## P2 – Implementation
- [x] Az `EventsInboxScreen` most `WidgetsBindingObserver`-ral fut, és egy 45 másodperces `Timer.periodic` fut csak akkor, ha a screen látható és az app `resumed`.
- [x] A timer minden tick előtt lekéri a provider state-jét, és kihagyja a `refresh()` hívást, ha offline/offload/isLoading/isLoadingMore/isMarkingAllRead állapot van; `dispose()`-ban a timer mindig leáll és az observer eltávolításra kerül.
- [x] Új widget teszt (`events_inbox_polling_refresh_test.dart`) biztosítja, hogy a poll egy extra `fetchPage` hívást érzékel a screen alatt, majd navigáláskor további időlépések után már nem növekszik a fetch számláló.

## P3 – QA gate
- [x] `./scripts/check.sh`
