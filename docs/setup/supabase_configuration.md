# Supabase konfiguráció és futtatás

## 1. Compile-time környezeti adatok
- Az `app/lib/main.dart` `String.fromEnvironment('SUPABASE_URL')` és `String.fromEnvironment('SUPABASE_ANON_KEY')` értékekkel dolgozik; a Supabase csak akkor inicializálódik, ha mindkettő nem üres `--dart-define` érték.
- Az `app/.env.example` sablonként mutatja a két érték formátumát; dotenv nélkül is offline módban indul az app, mert a guard kezeli a konfigurálatlan állapotot.

## 2. SDK kovetelmeny (source of truth)
- Flutter/Dart minimum forras:
  - `app/pubspec.yaml` -> `environment.sdk: ^3.10.4`
- Javasolt lokalis ellenorzes:
  - `./scripts/flutter.sh --version`
- Ha a helyi Dart verzio ettol elter, a setup instabil lehet (analyze/test eltérések).

## 3. Fejlesztői futtatás
- Gyors offline futtatás (nincs konfiguráció):
  - `./scripts/flutter.sh run`
- Konfigurált környezet:
  - `./scripts/flutter.sh run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...`
- Teszteknél is ugyanígy használj define-okat, ha szükséges:
  - `./scripts/flutter.sh test --dart-define=...`
  - `./scripts/flutter.sh test integration_test/app_test.dart -d <deviceId> --dart-define=...`

## 4. Redirect es site_url osszefugges
- A local Supabase auth alap URL:
  - `supabase/config.toml` -> `[auth].site_url = "http://127.0.0.1:3000"`
- Engedelyezett auth redirect URL-ek:
  - `supabase/config.toml` -> `[auth].additional_redirect_urls = ["https://127.0.0.1:3000"]`
- Az app callback route:
  - `app/lib/src/app/router/app_router.dart` -> `path: '/auth/callback'`
- Kovetelmeny: a callback path legyen konzisztens az auth redirect URL-lel (site_url + callback route).

## 5. Ellenőrzési tippek
- Az auth screenek (`app/lib/src/features/auth/presentation/screens/login_screen.dart`, `app/lib/src/features/auth/presentation/screens/register_screen.dart`) letiltjak a submit gombot, es a `loc.offlineDescription` a `--dart-define` workflowra utal.
- Az `app/integration_test/app_test.dart` konfigurációtól függően offline notice-t vagy login/home UI-t ellenőriz.
- A widget tesztek (`app/test/widget`) override-olják a `supabaseConfigProvider` értékét, így nem kell valós Supabase.

## 6. Hivatkozások
- Legfrissebb architektúra és környezet: `docs/architect/app_architecture.md`.
- Codex canvas/checklist/report artefaktok a `canvases/` és `codex/` mappákban.
- Local stack setup guide: `docs/setup/supabase_setup.md`.
