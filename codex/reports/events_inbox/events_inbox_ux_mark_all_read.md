## Mit találtunk?
- A `mark all read` funkció hiányzott, így az AppBar nem engedte egyben olvasottnak jelölni az aktuális, filterezett listát, és a provider sem tartotta számon ezt a műveletet.

## Mit módosítottunk?
- Bővítettük a `UserEventsState`-et `isMarkingAllRead` mezővel, és létrehoztuk a `markAllRead()` metódust, amely csak a szűrt, olvasatlan eventeken fut, optimista read_at frissítést végez, és sikertelen markRead hívásoknál rollback-el.
- Az AppBar most ikon gombot mutat (`Icons.done_all`), ami csak akkor aktív, ha van unread az aktuális filterben, Supabase konfigurálva van és nem fut már markAllRead. A gomb snackbarokat is megjelenít (`eventsMarkAllReadSuccess`/`eventsMarkAllReadPartial`) az eredmény alapján.
- Hozzáadtuk a szóban forgó lokalizációs kulcsokat az EN/HU ARB fájlokhoz és az `AppLocalizations` generált osztályaihoz.
- Új widget teszt (`events_inbox_mark_all_read_test.dart`) ellenőrzi a credits/all filter szcenáriót és a sikeres snackbar üzenetet.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/src/features/events/domain/events_filter.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `app/test/widget/events_inbox_mark_all_read_test.dart`
- `codex/codex_checklist/events_inbox/events_inbox_ux_mark_all_read.md`
- `codex/reports/events_inbox/events_inbox_ux_mark_all_read.md`

## Tesztek
- `./scripts/check.sh` – PASS (analyze + unit/widget suite)

## Következő javasolt lépések
1. Ha bevezetjük a server-side `mark all read`-ot, legyünk biztosak benne, hogy a kliens optimista logikája követi a szerver eredményét (rollback + snackbar).
2. Gondold át, hogy a `eventsMarkAllReadPartial` szöveg valós helyzetekben (pl. 10 succeeded, 2 failed) is jól kommunikál-e, és szükség esetén tegyél be normál szöveges logikát.
