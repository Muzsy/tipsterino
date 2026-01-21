# 🎯 Tipsterino foundation + auth skeleton

## 🎯 Funkció

A Tipsterino új `app/` gyökérprojektje Material3 alapú theminggel, Riverpod+go_router stackkel és Supabase auth ready környezettel indul.
- 4 tabos navigáció (Home / Tickets / Leaderboard / Settings) placeholder képernyőkkel.
- Auth UI: login és regisztráció Supabase-re építve, logout a Settingsből, go_router redirectekkel (offline módon is indul, ha nincs env-config).
- L10n: HU/EN lokalizáció, az app feliratai `AppLocalizations`-ból töltődnek be.
- Környezeti beállítás: `--dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>` (további fallback a lokális `app/.env`), String.fromEnvironment-ből olvassuk be, Supabase csak akkor inicializálódik, ha mindkét érték nem üres; offline mód esetén az auth UI gombjai disabled-ek és információt mutatnak.

## 🧠 Fejlesztési részletek

* `app/lib/main.dart`, `app/lib/src/app.dart`, `app/lib/src/router/app_router.dart`: ProviderScope/GoRouter gyökér, Supabase config provider, go_router redirect logika, ShellRoute bottom navigation.
* `app/lib/src/providers/auth_provider.dart`: SupabaseClient guard és auth-szolgáltatás (login/register/logout), offline state, stream a GoRouter-nek.
* `app/lib/src/screens/{auth/login_screen.dart, auth/register_screen.dart, home_screen.dart, tickets_screen.dart, leaderboard_screen.dart, settings_screen.dart}`: egyszerű placeholder UI, settings-ben logout, auth képernyők beepítik a lokalizált szövegeket és disabled state-et offline környezetben.
* `app/lib/src/theme/app_theme.dart`: Material3 `ThemeData` (`ColorScheme.fromSeed`) támogatott light mód.
* `app/lib/src/screens/app_shell.dart`: BottomNavigationBar a shellhez, a tabokat `GoRouter`-rel vezérelve.
* `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb`: lokalizált szövegek (appTitle, login/regisztráció, tab címek, logout gomb, offline üzenet, auth field label).
* `.env.example`: példa `SUPABASE_URL`/`SUPABASE_ANON_KEY` define-ok (nem kötelező, csak dokumentáció), `.gitignore`: az `app/.env` fájlt rejtjük el a repo-ban.
* `test/widget/app_smoke_test.dart`, `test/widget/l10n_test.dart`: widget smoke + l10n coverage, `integration_test/app_test.dart`: smoke integration verifying login screen render.

## 🧪 Tesztállapot

* `dart format .` / `flutter analyze` / `flutter test` → mind zöld (lásd checklist + report).
* `flutter test integration_test/app_test.dart` a fizikai eszközön: a teszt az aktuális konfiguráció alapján offline notice-t vagy login/home képernyőt ellenőrzi, és biztosítja, hogy a gombok offline módban disabled állapotúak.
* A widget + l10n tesztek nem függnek Supabase configtól (override-oljuk `supabaseConfigProvider`).

## 🌍 Lokalizáció

* Támogatott nyelvek: `hu`, `en`. Az `Lang`-választás a `MaterialApp` `supportedLocales`-ában van.
* Kulcsok: `appTitle`, `loginTitle`, `registerTitle`, `emailLabel`, `passwordLabel`, `logoutLabel`, `homeTab`, `ticketsTab`, `leaderboardTab`, `settingsTab`, `offlineNotice`, `submitButton`, `registerPrompt`, `alreadyHaveAccount`, `passwordRepeatLabel`.

## 📎 Kapcsolódások

* Dokumentáció: `documents/app_architecture.md` (architektúra + env + teszt/parancs), legacy docs minta alapján.
* Konfigurációs részletek: `documents/supabase_configuration.md` leírja a `--dart-define` munkamenetet, offline UI elvárt viselkedését és a futtatási parancsokat.
* Checklist: `codex/codex_checklist/tipsterino_foundation_bootstrap.md` pipálva a végén.
* Report: `codex/reports/tipsterino_foundation_bootstrap.md` tartalmazza a parancsok kimenetét és a hibákat/következő lépéseket.
