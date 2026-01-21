# Tipsterino app architektúra

## 1. Gyökér és provider stack
- `app/lib/main.dart`: `dotenv` betöltés + Supabase init csak, ha a `.env` létezik, majd `ProviderScope` + `TipsterinoApp` elindítása.
- `app/lib/src/app.dart`: `MaterialApp.router` + `AppTheme` + `AppLocalizations` delegálok.
- `app/lib/src/providers/supabase_provider.dart`, `auth_provider.dart`: a `SupabaseConfiguration` és a `AuthViewState` `StateNotifier`-e a bejelentkezés/regisztráció kezelésére és a `GoRouter` frissítésére.

## 2. Routing és shell
- `app/lib/src/router/app_router.dart`: `GoRouter` `ShellRoute`-dal, redirect guard-dal (offline/login/visszairányítás), `AuthRefreshNotifier`-rel a `ChangeNotifier` alapú frissítés.
- `app/lib/src/screens/app_shell.dart`: Material3 `BottomNavigationBar` 4 tabbal (`Home`, `Tickets`, `Leaderboard`, `Settings`).

## 3. Képernyők és lokalizáció
- `lib/l10n/app_{en,hu}.arb`: HU/EN fordítások az app title, tabok, auth form mezők és offline üzenetekhez.
- `app/lib/src/screens/auth/{login,register}_screen.dart`: `ConsumerStatefulWidget`, offline jelzés és hibakezelés `AuthFailure` kivétellel.
- `app/lib/src/screens/*_screen.dart`: placeholder `Scaffold`-ok a tabokhoz.

## 4. Környezeti változó kezelés
- `app/.env.example`: `SUPABASE_URL` és `SUPABASE_ANON_KEY` példák.
- `.gitignore`: `app/.env` kizárva.
- `main.dart`: `dotenv.load` `try/catch`-ban, env nélküli futás biztonságosan offline módra vált.

## 5. Tesztek és parancsok
- Widget tesztek: `test/widget/app_smoke_test.dart` + `test/widget/l10n_test.dart` (Riverpod override, `AppLocalizations` check).
- Integration teszt: `integration_test/app_test.dart` fizikai eszközön futtatva, `AppLocalizations` lokalizált stringjeit ellenőrzi.
- Futtatott parancsok: `dart format .`, `flutter analyze`, `flutter test`, `flutter test integration_test/app_test.dart -d GAB7N18604000884`.
