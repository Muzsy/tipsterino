## Mit találtunk?
- Az `app/.env.example` nem jelezte, hogy a projekt nem olvassa be automatikusan az `.env` fájlt, ezért a futtatók azt hitték, hogy dotenv szükséges.
- A `canvases/tipsterino_stability_run.md` és a hozzá tartozó checklist repo hivatkozásai (`app/integration_test/app_test.dart`, `app/lib/l10n/app_localizations.dart`) nem tükrözték a valós `app/` struktúrát.
- A `canvases/tipsterino_foundation_bootstrap.md` lokalizációs listája olyan kulcsokat is felsorolt, amelyek nem szerepeltek az `app/lib/l10n/app_{en,hu}.arb` fájlokban.
- A widget smoke teszt angol stringekre épült, így nem volt locale-független.

## Mit módosítottunk?
- `app/.env.example` kommentjét és megjegyzéseit aktualizáltuk, hogy egyértelmű legyen: csak sablon, a kulcsokat `--dart-define`-ról kell átadni, és nincs `.env` load.
- `canvases/tipsterino_stability_run.md` és `codex/codex_checklist/tipsterino_stability_run.md` most `app/integration_test/app_test.dart` és `app/lib/l10n/app_localizations.dart` hivatkozásokat tartalmaznak, parancslisták pedig `cd app`-al kezdődnek.
- `canvases/tipsterino_foundation_bootstrap.md` lokalizációs szakaszát a valós ARB kulcsokra írtuk át, csak az ott található kulcsok szerepelnek a felsorolásban.
- `app/test/widget/app_smoke_test.dart` most a `AppLocalizations`-ból veszi a stringeket (locale pumpolás), így nem ragad le hardcode angol szövegeknél.

## Tesztek
- `cd app && dart format .` – PASS
- `cd app && flutter analyze` – PASS
- `cd app && flutter test` – PASS (widget + l10n smoke)
- `cd app && flutter test integration_test/app_test.dart -d GAB7N18604000884` – PASS (fizikai Android, egy hosszabb futás kellett ahhoz, hogy a Gradle összeálljon)

## Manuális smoke
- A manuális `flutter run` nem került végrehajtásra; az integration teszt lefedi a startup-útvonalakat és a Supabase guard viselkedését.

## Ismert korlátok / TODO
- A Supabase backend még nem éles, ezért a login/register logika offline/fake környezethez igazított.
- További integration scenáriók (logout, nav guard) bővítésre várnak.
