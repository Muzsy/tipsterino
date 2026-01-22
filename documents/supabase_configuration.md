# Supabase konfiguráció és futtatás

## 1. Compile-time környezeti adatok
- Az `app/lib/main.dart` `const supabaseUrl = String.fromEnvironment('SUPABASE_URL');` és `const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');` értékekkel dolgozik; a Supabase csak akkor inicializálódik, ha mindkettő nem üres `--dart-define` érték. Részletesen a `documents/app_architecture.md` ismerteti ezt a guard logikát.
- Az `app/.env.example` csupán sablonként mutatja, milyen formában adható meg a két érték a `--dart-define` parancsban; a futtatás akkor is offline módban indul, ha ilyen fájl nincs jelen, mert nincs dotenv logika.

## 2. Fejlesztői futtatás
- Gyors offline futtatás (nincs konfiguráció): `cd app && flutter run`. Az app a login képernyőt mutatja, a `loc.offlineNotice` + `loc.offlineDescription` tájékoztat, és az auth gombok disabled-ek.
- Konfigurált környezet: `cd app && flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...` – a SupabaseClient csak akkor kezd autentikációba, ha mindkét érték megérkezett.
- Teszten is `--dart-define`-t adunk át: `cd app && flutter test --dart-define=...` és `cd app && flutter test integration_test/app_test.dart -d <deviceId> --dart-define=...`.
- A `cd app && flutter devices` parancsnál válaszd a legelső fizikai Android eszközt, ha elérhető, és használd ugyanazt az eszközt az integration futtatáshoz.

## 3. Ellenőrzési tippek
- A `app/lib/src/screens/auth/login_screen.dart` és `register_screen.dart` letiltja a submit gombot, és a `loc.offlineDescription` kifejezetten a `--dart-define`-ra hivatkozik.
- Az `app/integration_test/app_test.dart` a teljes lokalizációs csomagot használva az aktuális konfigurációtól függően offline notice-t vagy login/home UI-t ellenőrzi; a teszt nem ragaszkodik egyetlen `offlineNotice` szöveghez.
- A widget tesztek (`app/test/widget`) override-olják a `supabaseConfigProvider` értékét, így nem kell valós Supabase a tesztekhez.

## 4. Hivatkozások
- Legfrissebb architektúra és környezet: `documents/app_architecture.md`.
- Canvas/checklist/report: `canvases/tipsterino_foundation_bootstrap.md`, `codex/codex_checklist/tipsterino_foundation_bootstrap.md`, `codex/reports/tipsterino_foundation_bootstrap.md`, `canvases/tipsterino_stability_run.md`, `codex/codex_checklist/tipsterino_stability_run.md`, `codex/reports/tipsterino_stability_run.md`.
- Supabase célok: `codex/goals/canvases/fill_canvas_tipsterino_stability_run.yaml`.
