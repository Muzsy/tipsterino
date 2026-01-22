# Tipsterino paths + dotenv cleanup checklist

## P1 – Canvas és YAML
- [x] Elkészült a `canvases/tipsterino_paths_and_dotenv_cleanup.md` és a hozzá tartozó `codex/goals/canvases/fill_canvas_tipsterino_paths_and_dotenv_cleanup.yaml`.

## P2 – Artefakt pathok és dokumentáció
- [x] Minden canvas, checklist, report és dokumentum `app/...` útvonalra hivatkozik, a `documents/` anyagok kizárólag létező fájlokat listáznak.

## P3 – Dotenv eltávolítása
- [x] `flutter_dotenv` dependency törölve `app/pubspec.yaml`-ból, `app/lib/main.dart` csak `String.fromEnvironment`-t használ, a `documents/supabase_configuration.md` és `documents/app_architecture.md` csak `--dart-define`-t említ.

## P4 – Tesztek offline + konfigurált állapotban
- [x] Widget/l10n és integration tesztek (`app/test/widget/` + `app/integration_test/`) nem igényelnek `.env` fájlt, az offline UI gombjai disabled-ek, konfigurált állapotban login vagy home képernyő jelenik meg.

## P5 – Gate parancsok
- [x] `dart format .`, `flutter analyze`, `flutter test` és `flutter test integration_test -d <deviceId>` sikeresen lefutott `cd app && …` szintaxissal (illetve a `flutter devices` parancs is lefutott).
