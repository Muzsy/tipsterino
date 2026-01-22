# Tipsterino artifact consistency polish checklist

## C1 – .env example
- [x] `app/.env.example` egyértelmű, hogy csak template, nincs `.env` load, és `--dart-define`-t használunk.

## C2 – Artefakt útvonalak
- [x] A `canvases/tipsterino_stability_run.md` és a `codex/codex_checklist/tipsterino_stability_run.md` `app/integration_test/app_test.dart` és `app/lib/l10n/app_localizations.dart` hivatkozásokat tartalmaz, parancsoknál `cd app`.

## C3 – Lokalizáció + teszt
- [x] `canvases/tipsterino_foundation_bootstrap.md` lokalizációs lista csak az `app/lib/l10n/app_{en,hu}.arb` kulcsait sorolja.
- [x] `app/test/widget/app_smoke_test.dart` a `AppLocalizations`-t használja a string ellenőrzéshez locale pumpolással.

## C4 – Gate parancsok
- [x] `cd app && dart format .`, `cd app && flutter analyze`, `cd app && flutter test`, `cd app && flutter test integration_test/app_test.dart -d <deviceId>` lefutott.
