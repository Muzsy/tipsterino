# Tipsterino app architektúra

## 1. Gyökér stack és provider
- `app/lib/main.dart`: `String.fromEnvironment` alapján olvassa be a `SUPABASE_URL`/`SUPABASE_ANON_KEY` define-okat; amikor mindkét érték nem üres, inicializálja a SupabaseClient-et, egyébként offline állapotba vált a `SupabaseConfiguration`-nel. A részletes környezeti workflow a `docs/setup/supabase_configuration.md` fájlban található.
- `app/lib/src/providers/supabase_provider.dart`: a `SupabaseConfiguration` (`isConfigured` + `client`) a `ProviderScope`-on keresztül kerül a `supabaseConfigProvider`-be, így a Riverpod logika tudja, ha offline vagy auth overlay-re van szükség.
- `app/lib/src/app.dart`: `MaterialApp.router`, `AppTheme.lightTheme`, `AppLocalizations` delegálók és supported locales.

## 2. Routing, redirect és shell
- `app/lib/src/router/app_router.dart`: `GoRouter` `redirect` logika (offline → `/auth/login`, konfigurált → `/home`), `ShellRoute` + `AppShell` 4 függő tabbal.
- `app/lib/src/screens/app_shell.dart`: `BottomNavigationBar`, `SafeArea`, `GoRouter`-ral adott tab navigation.
- `app/lib/src/screens/auth/`: login + register `ConsumerStatefulWidget`, `supabaseConfigProvider`-t használva letiltja a submit gombot offline állapotban, és a lokalizált `loc.offlineNotice`/`loc.offlineDescription` szövegek kapcsolódnak hozzá.

## 3. Lokalizáció és üzenetek
- `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb`: HU/EN stringek (tabok, login/register, offline notice, offline leírás a `--dart-define` használatról, gombok, hibaüzenetek).
- `app/lib/l10n/app_localizations.dart`: generált kódrészletek, `loc.offlineNotice`, `loc.offlineDescription`, `loc.logInButton`, `loc.homeTab`, `loc.ticketsTab` stb.

## 4. Környezeti változók és Supabase
- `docs/setup/supabase_configuration.md`: részletesen bemutatja a `--dart-define` workflow-t, az offline UI elvárásait és a futtatási parancsokat.
- `app/.env.example`: csak példa a `SUPABASE_URL`/`SUPABASE_ANON_KEY` `--dart-define` értékekhez; maga a futtatás nem olvassa automatikusan, de a fájl segít sablont adni.
- `app/lib/main.dart`: `SupabaseConfiguration` guard biztosítja, hogy dotenv nélkül is stabilan fusson az app, offline állapotnál a login/regisztráció gombjai disabled-ek és egy offline notice jelenik meg.
- Az integration teszt (`app/integration_test/app_test.dart`) az aktuális konfiguráció szerint offline notice-t vagy login/home képernyőt vár, így a gombok offline módban letiltottak.

## 5. Tesztek és parancsok
- Widget + l10n tesztek: `app/test/widget/app_smoke_test.dart`, `app/test/widget/l10n_test.dart` (a `supabaseConfigProvider` override-olva, így nem kell valós Supabase).
- Integration teszt: `app/integration_test/app_test.dart`.
- Futtatott parancsok wrapperrel:
  - `./scripts/flutter.sh format .`
  - `./scripts/flutter.sh analyze`
  - `./scripts/flutter.sh test`
  - `./scripts/flutter.sh test integration_test/app_test.dart -d <deviceId>`
