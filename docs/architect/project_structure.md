# 🎯 Tipsterino – kötelező feature-first mappaszerkezet (Codex-szabvány)

> **Cél:** a Tipsterino kódbázis minden új/átalakított része **feature-first** szerint szerveződik. A Codex **kizárólag** ezt a struktúrát használhatja (új fájlokat nem tehet régi/„gyűjtő” mappákba).

**Javasolt mentési hely a repo-ban:** `docs/architect/project_structure.md`  
*(A `docs/README.md` már előkészítette az `architect/` témát; hozzuk létre ezt az almappát, és ide mentjük a szabványt.)*

---

## 🎯 Funkció

- Egységes, skálázható **feature-first** könyvtárszerkezet rögzítése.
- A képernyők (screens) **feature-ök alá** kerülnek, nem központi `screens/` gyűjtőbe.
- A feature-ökön belül opcionális, de ajánlott a **presentation / domain / data** rétegezés.
- A cél: gyors fejlesztés + későbbi bővíthetőség, minimális „szétfolyás” és import-káosz.

---

## 🧠 Fejlesztési részletek

### 1) Repo szintű (top-level) elvárt struktúra

A feltöltött zip alapján jelenleg ez látszik a repo gyökérben:

- `app/` – **a Flutter alkalmazás** (ez a tényleges futtatható projekt)
- `canvases/` – Codex vásznak (sprint/task alap)
- `codex/` – Codex célok / checklist / reportok
- `docs/` – dokumentációs „témák” (strukturált doksi gyűjtő)
- `documents/` – deprecated/archív dokumentumok és átirányító stubok
- `scripts/` – segédscript-ek

**Szabály:** új top-level könyvtárat csak indokolt esetben (pl. `tools/`, `legacy/`) hozunk létre. A Codex ne találjon ki új gyökérmappákat.

---

### 2) Flutter app (app/lib) elvárt struktúra

A jelenlegi állapotban az app:
- `lib/main.dart`
- `lib/l10n/`
- `lib/src/`

**Ezt megtartjuk**: a publikus belépési pont marad `main.dart`, a belső kód pedig `lib/src/` alatt.

#### 2.1) `lib/src/` végleges célstruktúra (feature-first)

```
lib/
  main.dart
  l10n/
    app_hu.arb
    app_en.arb
    ...
  src/
    app/
      app.dart                # TipsterinoApp (MaterialApp.router)
      di/                     # dependency injection / wiring
      router/                 # go_router config, route registry
      startup/                # app init / bootstrap (opcionális)

    core/
      clients/                # supabase client wrapper, http, storage
      config/                 # env, flags, build variants
      errors/                 # error model, Result/Either
      logging/                # logger, breadcrumbs (opcionális)
      utils/                  # csak indokolt, ne legyen szeméttelep

    shared/
      theme/                  # design tokens, AppTheme
      widgets/                # többször használt UI komponensek
      extensions/             # buildcontext/texttheme ext (ha kell)

    features/
      <feature_name>/
        <feature_name>.dart   # „public API” barrel (export) – ajánlott

        presentation/
          screens/            # screen/page widgetek
          widgets/            # csak ehhez a feature-hez tartozó widgetek
          state/              # riverpod providers/controllers/notifiers

        domain/
          entities/
          repositories/       # abstract interfészek
          usecases/           # opcionális (ha tényleg hasznos)

        data/
          datasources/        # Supabase query-k, remote/local data
          dtos/               # json/dto mapping
          repositories/       # domain repo implementációk
```

**Feature név:** `snake_case` (pl. `auth`, `tips`, `tickets`, `rewards`, `leaderboard`, `settings`).

---

### 3) KÖTELEZŐ szabályok (Codex és emberi fejlesztés)

#### 3.1) „Nincs központi szeméttelep”
- **TILOS** új fájlokat tenni ide: `lib/src/screens/`, `lib/src/providers/`, `lib/src/router/` (régi stílusú gyűjtők).
- Új képernyő **mindig**: `lib/src/features/<feature>/presentation/screens/`.
- Új feature-specifikus state/provider **mindig**: `lib/src/features/<feature>/presentation/state/`.

#### 3.2) Cross-feature import szabály
- Egy feature **nem importálhat** más feature belső fájljaira mutató „deep importot”.
- Ha kell közös használat:
  - vagy `shared/` komponens lesz belőle,
  - vagy a másik feature „public API”-ján keresztül (pl. `import '.../features/auth/auth.dart';`).

#### 3.3) Mi mehet a `shared/` alá?
- Csak olyan UI/design elem, amit **legalább 2 feature** biztosan használ.
- Ha egy komponens csak egy feature-ben kell, maradjon a feature `presentation/widgets/` alatt.

#### 3.4) Router szabály
- A GoRouter konfiguráció központja: `lib/src/app/router/`.
- Feature route-okat lehet feature-ben definiálni, de a regisztráció (összefűzés) az `app/router`-ban történik.

#### 3.5) Riverpod/Supabase „globális” elemek helye
- App-szintű (keresztmetszeti) provider mehet a `core/` alá (pl. supabase client konfiguráció, auth session stream), **de** feature-üzleti logika ne kerüljön ide.
- Feature-üzleti logika: feature `presentation/state/` + szükség esetén `domain/`.

---

### 4) Átmeneti (migrációs) szabály – a jelenlegi zip miatt

A feltöltött projektben még létezik:
- `lib/src/screens/`
- `lib/src/providers/`
- `lib/src/router/`
- `lib/src/theme/`

**Átmeneti döntés:**
- ezekben a mappákban **nem** hozunk létre új fájlt,
- fokozatosan átköltöztetjük őket az új struktúrába:

**Mapping:**
- `src/screens/<feature>/...` → `src/features/<feature>/presentation/screens/...`
- `src/providers/<feature>_provider.dart` → `src/features/<feature>/presentation/state/...` *(vagy `src/core/...`, ha tényleg cross-cutting)*
- `src/router/...` → `src/app/router/...`
- `src/theme/...` → `src/shared/theme/...`

---

### 5) Névkonvenciók

- Fájlok: `snake_case.dart`
- Képernyők: `*_screen.dart` *(vagy `*_page.dart`, de egyet válasszunk; javaslat: `*_screen.dart`)*
- Widgetek: `*_card.dart`, `*_tile.dart`, `*_section.dart`
- Riverpod:
  - vezérlő: `*_controller.dart`
  - provider definíciók: `*_providers.dart` *(ha több is van)*

---

## 🧪 Tesztállapot

Struktúra-váltás / új fájlok hozzáadása után kötelező minimum:

- `flutter analyze`
- `flutter test`
- (ha van) `flutter test integration_test`
- formázás: `dart format .`

**Elfogadási kritérium:** build és tesztek zöldek, importok nem „deep import” jellegűek más feature belsejébe.

---

## 🌍 Lokalizáció

- Lokalizáció továbbra is app-szinten: `lib/l10n/app_<lang>.arb`.
- Kulcsnév szabvány: `<feature>_<scope>_<name>`
  - pl. `auth_login_title`, `rewards_daily_bonus_claim`, `tickets_empty_state_title`
- Új képernyő nem tartalmazhat „hardcoded” szöveget (kivéve debug/placeholder, de azt is idővel ki kell vezetni).

---

## 📎 Kapcsolódások

- `docs/README.md` – a dokumentációs témák struktúrája (tartalmazza az `architect/` kategóriát)
- `docs/architect/app_architecture.md` – a jelenlegi architektúra leírás (router, auth, supabase konfig, stb.)
- `docs/setup/supabase_configuration.md` – `--dart-define` futtatási leírás
- `canvases/tipsterino_foundation_bootstrap.md` – kiinduló Codex vászon

---

### Rövid „Codex-parancs” ellenőrzőlista (kötelező)

- [ ] Új screen **csak** `features/<feature>/presentation/screens/` alá kerül.
- [ ] Új provider/controller **csak** `features/<feature>/presentation/state/` alá kerül.
- [ ] Nincs új fájl a régi `src/screens|providers|router|theme` gyűjtők alatt.
- [ ] Más feature belsejére nincs deep import (barrel/public API vagy shared).
- [ ] `flutter analyze` + `flutter test` zöld.
