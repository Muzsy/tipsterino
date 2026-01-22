## Mit találtunk?
- A canvasok, checklist-ek, reports és dokumentációk között több helyen rossz útvonalak (`lib/`, `test/`, `integration_test/`) voltak használva, ami félrevezette a fejlesztőket a `app/` gyökér alatt.
- A Supabase konfigurációs leírás `.env`-t és `flutter_dotenv`-t említett, holott a monorepo azt igényli, hogy csak `--dart-define`-ből olvassuk be a `SUPABASE_URL`/`SUPABASE_ANON_KEY` értékeket.
- A widget és integration tesztek futtatása is `app/` gyökér alatt történik, így minden hivatkozásnak egységes `app/test`/`app/integration_test` útvonalra kellett mutatnia.

## Mit módosítottunk?
- Elkészült a `canvases/tipsterino_paths_and_dotenv_cleanup.md` és a hozzá tartozó `codex/goals/canvases/fill_canvas_tipsterino_paths_and_dotenv_cleanup.yaml`, amely részletesen leírja a globális path-auditot és a dotenv-kivezetést.
- `canvases/tipsterino_foundation_bootstrap.md`, `canvases/tipsterino_stability_run.md`, a hozzájuk tartozó checklist- és report-fájlok, valamint a `codex/goals/canvases` YAML-ok `app/` útvonalakra, `cd app` parancsokra és `app/test`/`app/integration_test` hivatkozásokra lettek frissítve.
- `documents/app_architecture.md` és `documents/supabase_configuration.md` újrafogalmazták a `--dart-define` workflow-t, egyértelművé téve, hogy az `app/.env.example` csak példa és a futtatás kizárólag defines-szintű konfigurációra támaszkodik.
- `app/lib/main.dart` csak a `String.fromEnvironment` értékeket olvassa, offline módban disabled gombokkal és offline notice-szal reagál; `app/pubspec.yaml`/`app/pubspec.lock` törölték a `flutter_dotenv` dependency-t.
- Új checklist (`codex/codex_checklist/tipsterino_paths_and_dotenv_cleanup.md`) készült, és a korábbi checklist-ek / report-ok is az új path/dotenv logikát dokumentálják.

## Tesztek
- `cd app && dart format .` – PASS
- `cd app && flutter analyze` – PASS
- `cd app && flutter test` – PASS (widget + l10n smoke)
- `cd app && flutter test integration_test/app_test.dart -d GAB7N18604000884` – PASS (offline notice + konfigurált login/home ellenőrzés)

## Manuális smoke
- Fizikai `cd app && flutter run` futtatást nem végeztünk, mert az integration teszt lefedése és az offline guard tesztelése már igazolja a startup folyamatot.

## Ismert korlátok / TODO
- A Supabase backend továbbra sem éles, ezért a login/register logika csak mock környezetben próbálható ki.
- További integration tesztek kellenek a logout/nav guard teszteléséhez és a Supabase session életciklusának lefedéséhez.

## Következő javasolt lépések
1. Dokumentálni a `docs/screens/` alá a következő szolgáltatásokat, hogy a future canvas-ok ott tárolják az acceptance kritériumokat a `codex/reports`-hoz kapcsolódva.
2. Bővíteni az integration teszteket (logout, nav guard, session refresh) a `app/integration_test` alatt.
3. A `SUPABASE_URL`/`SUPABASE_ANON_KEY` titkok kezelését automatizálni (`--dart-define` + titkosított secrets manager).
