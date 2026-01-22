## Mit találtunk?
- A `canvases/`, `documents/` és `codex/` anyagok a valós `app/` struktúrához képest még mindig régi `test/`/`integration_test/` hivatkozásokat és `.env` fallback-dokumentációt tartalmaztak, így a fejlesztők nem tudtak biztosan eligazodni a jelenlegi projektgyökérben.
- A Supabase inicializáció a `flutter_dotenv`-re és egy lokális `.env` fájlra támaszkodott, ami nem kompatibilis a monorepo új `app/` gyökérrel és a `--dart-define`-ban gondolkodó tesztszuítekkel.
- A dokumentációk és a lokalizáció még mindig említették a `.env` workflow-t, ami ellentmondott az új, `String.fromEnvironment` alapú megközelítésnek.

## Mit módosítottunk?
- `app/lib/main.dart`: eltávolítottuk a `flutter_dotenv` logicát, így csak `String.fromEnvironment('SUPABASE_URL')`/`('SUPABASE_ANON_KEY')` értékeket használunk, és offline állapotban disabled gombok + offline notice jelenik meg.
- `app/pubspec.yaml`/`app/pubspec.lock`: kivetkőztük a `flutter_dotenv` dependency-t, a lockfájl újra generálódott a mostani függőségekkel.
- `documents/app_architecture.md` és `documents/supabase_configuration.md`: igényesen leírják a `--dart-define` workflow-t, a `cd app && ...` parancsokat és hogy a `app/.env.example` csak sablon, nem futtatási szükséglet.
- `canvases/tipsterino_foundation_bootstrap.md` és `canvases/tipsterino_stability_run.md`: minden path most `app/...`, a Supabase info kizárólag `--dart-define`-re hivatkozik.
- `codex/goals/canvases` és `codex/codex_checklist`: a YAML-ok és checklisták is frissültek, hogy `app/test`/`app/integration_test` útvonalakat, `cd app`-os parancsokat és a `flutter_dotenv` eltávolítását tüntessék fel.

## Tesztek
- `cd app && dart format .` – PASS
- `cd app && flutter analyze` – PASS
- `cd app && flutter test` – PASS (widget + l10n smoke)
- `cd app && flutter test integration_test/app_test.dart -d GAB7N18604000884` – PASS (fizikai Android: offline notice + konfigurált login/home viselkedés ellenőrzése)

## Manuális smoke
- Fizikai `flutter run` futtatását most nem végeztük el, mert az integration teszt lefuttatása lefedi a főbb start-up útvonalakat; az offline guard és a `--dart-define` használata miatt a teszt környezet stabil.

## Ismert korlátok / TODO
- Az auth UI placeholder képernyők (Home/Tickets/Leaderboard/Settings) továbbra is statikusak, nem használják a backend adatokat.
- Az éles Supabase backend még nincs beállítva, a Supabase eseménykezelés bővítése (session badge, logout guard) várat magára.

## Következő javasolt lépések
1. Éles Supabase backend csatlakoztatása és a titkos `SUPABASE_URL`/`SUPABASE_ANON_KEY` értékek `--dart-define` kezelésének automatizálása (GitHub Secrets, Secret Manager).
2. Tickets/Leaderboard logika + provider integráció, hogy a placeholder képernyők valódi adatokkal működjenek és a widget tesztek is erre reflektáljanak.
3. Auth UI fejlesztése (jelszó reset, error handling, Supabase session badge a Settingsben) és további integration tesztek (logout, nav guard).
