# Tipsterino app architektúra

## 1. Gyökér stack és provider
- `app/lib/main.dart`: `String.fromEnvironment` alapján olvassa be a `SUPABASE_URL`/`SUPABASE_ANON_KEY` define-okat, a mintát `app/.env.example`-ben tartjuk; csak akkor inicializálja a SupabaseClient-et, ha mindkét érték nem üres, különben offline módra vált.
- `app/lib/src/providers/supabase_provider.dart`: `SupabaseConfiguration` definiálja az `isConfigured` és `client` értékeket, a `ProviderScope`-ban felülírjuk ezt a main-ből, így a Riverpod-státuszok mindig tudják, hogy offline vagy auth state-et mutassanak.
- `app/lib/src/app.dart`: `MaterialApp.router`, `AppTheme.lightTheme`, `AppLocalizations` delegálók és supported locales.

## 2. Routing, redirect és shell
- `app/lib/src/router/app_router.dart`: `GoRouter` `redirect` logika (offline -> `/auth/login`, authenticated -> `/home`), `ShellRoute` + `AppShell` 4 függő kártyás tabbal.
- `app/lib/src/screens/app_shell.dart`: `BottomNavigationBar`-t renderel `GoRouter` navigációval, safe area, valamint child tartalom.
- `app/lib/src/screens/auth/*`: login + register `ConsumerStatefulWidget`, offline gomb tiltás, `AuthFailure` hibakezelés, `GoRouter` redirect és `AuthRefreshNotifier`.

## 3. Lokalizáció és stringek
- `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb`: HU/EN stringek (tabok, login/register, offline notice, offline description a dart-define használatról, gombok, hibaüzenetek).
- `app/lib/l10n/app_localizations.dart`: generált kódrészletek a lokalizációhoz, figyeli a `loc.offlineNotice`/`loc.offlineDescription` stb.

## 4. Környezeti változók és Supabase konfiguráció
- `documents/supabase_configuration.md`: új dokumentum mutatja az `--dart-define` workflow-t, offline UI elvárásokat, integration teszt futtatását, és a `flutter run/test` parancsokat, amikor nincs konfiguráció.
- `app/.env.example`: `SUPABASE_URL`/`SUPABASE_ANON_KEY` define-példák; a `.gitignore` elrejti az opcionális `app/.env` fájlt, ha valaki mégis lokálisan definiál környezeti változókat.
- `app/lib/main.dart`: `String.fromEnvironment` és `SupabaseConfiguration` guard biztosítja, hogy dotenv nélkül is stabilan fusson az app, offline állapot, ha nincs konfiguráció.
- Az `integrációs teszt` az aktuális konfig szerint offline üzenetet vagy login/home képernyőt vár (a gombok offline módban letiltottak), így a teszt nem törik az offlineNotice megléte miatt.

## 5. Tesztek és futtatható parancsok
- Widget + l10n tesztek: `test/widget/app_smoke_test.dart`, `test/widget/l10n_test.dart` (a `supabaseConfigProvider` override-olva, nem kell Supabase).
- Integration teszt: `integration_test/app_test.dart` a fizikai eszközön (lásd `flutter devices`), offline/config állapotot vizsgál.
- Futtatott parancsok: `dart format .`, `flutter analyze`, `flutter test`, `flutter test integration_test/app_test.dart -d <deviceId>`.
