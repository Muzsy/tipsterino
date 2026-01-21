# Supabase konfiguráció és futtatás

## 1. Compile-time környezeti adatok
- A `app/lib/main.dart` `const supabaseUrl = String.fromEnvironment('SUPABASE_URL');` és `const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');` használatával olvassa be a Supabase URL-t és anon kulcsot; a mintát a `app/.env.example` adja.
- Az alkalmazás csak akkor inicializálja a `Supabase.initialize`-t, ha mindkét define nem üres; egyébként az `app/src/providers` offline state átlátható módon lép működésbe, a login/register gombok tiltottak.
- Lokális fejlesztésnél extra fallbackként egy gitignore-jelzett `app/.env` fájl is beolvasható, de a build nem igényli.

## 2. Fejlesztői futtatás
- Gyors offline futtatás: `flutter run` (nincs define), az app a login képernyőt mutatja, a `loc.offlineNotice` + `loc.offlineDescription` tájékoztat.
- Konfigurált környezethez: `flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...` – a SupabaseClient csak akkor kezd autentikációba, ha mindkét érték megvan.
- Teszteléshez ugyanígy: `flutter test --dart-define=...` és `flutter test integration_test/app_test.dart -d <deviceId> --dart-define=...`.
- Ha a define-ok hiányoznak, az integration teszt az offline UI-t ellenőrzi (offline notice, letiltott gomb). Ha megvannak, az integration teszt a login/home képernyőt várja.

## 3. Ellenőrzési tippek
- A `app/lib/src/screens/auth/login_screen.dart` és `register_screen.dart` letiltja a submit gombot, és a `loc.offlineDescription` leírja a `--dart-define` használatát.
- Az `integration_test/app_test.dart` a teljes lokalizációs csomagot használva az aktuális konfigurációtól függően az offline notice-t vagy a login/home UI-t ellenőrzi; a teszt nem base-loc-hoz ragad.
- Widget tesztek (`test/widget`) override-olják a `supabaseConfigProvider` értékét, így nem kell valós Supabase a tesztekhez.

## 4. Hivatkozások
- Legfrissebb architektúra- és tesztleírás: `documents/app_architecture.md`.
- Canvas/checklist/report: `canvases/tipsterino_foundation_bootstrap.md`, `codex/codex_checklist/tipsterino_foundation_bootstrap.md`, `codex/reports/tipsterino_foundation_bootstrap.md`, `canvases/tipsterino_stability_run.md`.
- Supabase konfigurációs lépések: `codex/goals/canvases/fill_canvas_tipsterino_stability_run.yaml`.
