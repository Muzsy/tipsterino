# Supabase konfiguráció és futtatás

## 1. Compile-time környezeti adatok
- Az `app/lib/main.dart` `String.fromEnvironment('SUPABASE_URL')` és `String.fromEnvironment('SUPABASE_ANON_KEY')` értékekkel dolgozik; a Supabase csak akkor inicializálódik, ha mindkettő nem üres `--dart-define` érték.
- Az `app/.env.example` sablonként mutatja a két érték formátumát; dotenv nélkül is offline módban indul az app, mert a guard kezeli a konfigurálatlan állapotot.

## 2. Fejlesztői futtatás
- Gyors offline futtatás (nincs konfiguráció):
  - `./scripts/flutter.sh run`
- Konfigurált környezet:
  - `./scripts/flutter.sh run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...`
- Teszteknél is ugyanígy használj define-okat, ha szükséges:
  - `./scripts/flutter.sh test --dart-define=...`
  - `./scripts/flutter.sh test integration_test/app_test.dart -d <deviceId> --dart-define=...`

## 3. Ellenőrzési tippek
- A `app/lib/src/screens/auth/login_screen.dart` és `register_screen.dart` letiltja a submit gombot, és a `loc.offlineDescription` kifejezetten a `--dart-define` használatra utal.
- Az `app/integration_test/app_test.dart` konfigurációtól függően offline notice-t vagy login/home UI-t ellenőriz.
- A widget tesztek (`app/test/widget`) override-olják a `supabaseConfigProvider` értékét, így nem kell valós Supabase.

## 4. Hivatkozások
- Legfrissebb architektúra és környezet: `docs/architect/app_architecture.md`.
- Codex canvas/checklist/report artefaktok a `canvases/` és `codex/` mappákban.
