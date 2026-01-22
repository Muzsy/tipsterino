# Tipsterino stability run checklist

## P1 – Dokumentációs referenciaegyeztetés
- [x] Frissítettem a `canvases/`, `documents/` és `codex/reports/` fájlok hivatkozásait, hogy valódi `app/..` fájlokra mutassanak (`canvases/tipsterino_foundation_bootstrap.md`, `documents/app_architecture.md`, `codex/reports/tipsterino_foundation_bootstrap.md`, stb.).

## P2 – Docs skeleton és supabase doksi
- [x] Elkészült a `docs/README.md` OutshotCoach-struktúra leírása és a `documents/supabase_configuration.md` útmutató, amelyek kapcsolódnak az új vászonhoz.

## P3 – Stabil Supabase konfiguráció
- [x] `app/lib/main.dart` compile-time `SUPABASE_URL`/`SUPABASE_ANON_KEY` értékekkel dolgozik, nincs `.env` fallback, és az `app/lib/l10n` offline üzenetek a `--dart-define` workflow-t írják le.

## P4 – Integration teszt
- [x] Az `app/integration_test/app_test.dart` mind offline, mind konfigurált állapotot ellenőrzi (offline notice, disabled gomb, illetve login/home render), nem ragad az offline notice-hoz.

## P5 – Cleanup és lokalizáció
- [x] `flutter gen-l10n` lefutott, az ARB fájlok és a generált lokalizációs kódok (`app/lib/l10n/app_localizations*.dart`) frissültek, a `app/lib/main.dart`, `app/integration_test/app_test.dart` kódja tiszta.

## P6 – Analyze / tesztek / integration
- [x] `cd app && dart format .`, `cd app && flutter analyze`, `cd app && flutter test` és `cd app && flutter test integration_test -d <deviceId>` mind sikeresen lefutott.
