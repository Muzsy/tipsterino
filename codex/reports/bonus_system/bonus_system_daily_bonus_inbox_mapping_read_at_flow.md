## Mit találtunk?
- Az `EventsInboxScreen` már létezik és a `ListView` items alapján rendereli a `UserEvent` listát, a `markRead` logika pedig csak a `read_at` mezőt frissíti (a provider és a repository is csak azt az oszlopot írja).
- A jelenlegi event mapper csak a signup bonus esetét képezi le, így a daily bonus események a `type:code` stringjeik formájában jelentek meg, ami nem volt lokalizált.

## Mit módosítottunk?
- Az `_mapTitle` és `_mapBody` helper most szétválasztja a `tippcoin_credit` `signup_bonus` és `daily_bonus` eseteket; daily bonusra a `event_daily_bonus_title`/`event_daily_bonus_body(amount)` lokalizált szöveget használja.
- Felvettük az új kulcsokat az EN és HU ARB fájlokba, majd a generált `AppLocalizations`/`AppLocalizationsEn`/`AppLocalizationsHu` osztályokban implementáltuk a getter/metódusokat.
- Tesztet adtunk az Inboxhoz (`events_inbox_daily_bonus_test.dart`), ami daily bonus eventtel inicializálja a screen-t, ellenőrzi a localized copy-t, majd a tap után regisztrálja a `markRead` hívást és azt, hogy a tile read állapotba kerül.

## Módosított/létrehozott fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `app/test/widget/events_inbox_daily_bonus_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_inbox_mapping_read_at_flow.md`
- `codex/reports/bonus_system/bonus_system_daily_bonus_inbox_mapping_read_at_flow.md`

## Tesztek
- `./scripts/check.sh` – PASS (analyze + widget/ unit suite, including the new inbox test)

## Következő javasolt lépések
1. Ha további event típusokat is meg kell jeleníteni, érdemes lehet a mapper-t kivehető, data-driven komponenssé alakítani (például map/dictionary alapján).
2. Ha a read_at update hibára fut, monitorozzuk a `UserEventsNotifier.errorMessage` mezőt vagy mutassunk SnackBar-t a UI-n, hogy a felhasználó tudja, mi történt.
