# Bonus system Events inbox UI fix checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_events_inbox_ui_fix.md` leírja a betöltési lifecycle-, theme- és refresh/loadMore-igényeket.
- [x] A glaze a `docs/architect/theme_rules.md` alapján tiltja a Colors.* hardcode-ot és a folytonos TextStyle-okat.

## P2 – Implementációs blokkok
- [x] `EventsInboxScreen` már `ConsumerStatefulWidget`, initState-ben microtask segítségével hívja meg az első `loadInitial()`-t, build nem indít önállóan betöltést.
- [x] A UI a Theme tokeneket használja: offline/empty címsorok `textTheme.titleMedium`, az unread pont `colorScheme.primary`, a listákon nincsenek `Colors.*` vagy `TextStyle(fontSize=...)` direkt értékek.
- [x] AppBar frissít ikon pedig `notifier.refresh`, pull-to-refresh `RefreshIndicator` és scroll listener threshold-ot figyelve hívja a `loadMore()`-t, amikor kell.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (dependency resolution + `flutter analyze` + `flutter test`).
