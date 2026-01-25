# 🎯 Funkció

A `legacy` mintát követve az auth/registration kapcsán a meglévő `app/lib/src` forrásokat költöztetjük át a feature-first struktúrába, hogy a további fejlesztések (auth wizard, wizard state, supabase integráció) a szabványos `app/src/features/...` + `app/src/app/router` + `app/src/core` + `app/src/shared` helyeken folytatódjanak.

**Cél:** minimal-módosítással áthelyezni a jelenlegi `app.dart`, router, auth/login/register képernyők, provider-ek és theme fájlokat az új helyükre, miközben az imports útvonalak frissülnek; a futó alkalmazás viselkedését nem változtatjuk.

### Nem cél
- új auth flow vagy wizard implementálása
- route-ok, screen logika vagy lokalizációs ARB fájlok módosítása
- Supabase CLI/migrációk
- `legacy/` alatti kód módosítása

---

# 🧠 Fejlesztési részletek

### Talált releváns fájlok
- `app/lib/main.dart` – indítópont, a supabase konfigurációt és a `TipsterinoApp`-ot használja.
- `app/lib/src/app.dart` – MaterialApp.router definíció, importálja az `app_router.dart`-ot és `app_theme.dart`-ot.
- `app/lib/src/router/app_router.dart` – go_router konfiguráció, `AppShell`, auth/login/register screenek és a feature route-ok.
- `app/lib/src/screens/app_shell.dart` – shell visual és bottom nav, a routerból kerül megjelenítésre.
- `app/lib/src/screens/auth/login_screen.dart` és `register_screen.dart` – jelenlegi auth képernyők, `auth_provider.dart` és `supabase_provider.dart` használatával.
- `app/lib/src/providers/auth_provider.dart`, `supabase_provider.dart` – a GoRouter auth refresh logikáját biztosítják; ezek új helyükön (features/core) lesznek elérhetőek.
- `app/lib/src/theme/app_theme.dart` – alkalmazás témáját definiálja.
- `app/lib/src/screens/settings_screen.dart` – importjai frissítendők az új provider-theme helyek miatt.
- `app/test/widget/app_smoke_test.dart` – a `TipsterinoApp`-ot indítja és a supabase override-ot használja; frissíteni kell az import útvonalakat.

### Pipálható feladatlista
- [ ] Létrehozott célmappastruktúrák: `app/src/app/router`, `app/src/core/clients`, `app/src/shared/theme`, `app/src/features/auth/presentation/{screens,state}`
- [ ] Áthelyezett fájlok (app.dart, router, shell, theme, providers, login/register) a megfelelő feature-first helyre (git mv)
- [ ] Frissített import útvonalak: `main.dart`, `app.dart`, `router`, `screens`, `settings_screen.dart`, `app_smoke_test.dart`, valamint a statikus `package:` importok a `supabase`/`auth` provider-ekre
- [ ] Ellenőrizve, hogy a régi mappákban nem maradtak duplikált fájlok a fenti forrásokból
- [ ] `dart format` + `./scripts/check.sh` lefutott a változtatások után

### Kockázatok + rollback terv
- **Kockázat:** a `git mv` után törik az importok (pl. a router még a régi helyekre mutat). **Rollback:** visszaállítjuk a fájlokat és importokat (`git checkout -- <path>`) és újra ellenőrizzük a relatív útvonalakat.
- **Kockázat:** futás közben a `TipsterinoApp` nem találja a Theme/AppRouter fájlokat. **Rollback:** a canvas/codex artefaktokkal együtt visszaállítjuk a `main.dart` illetve `app.dart` importokat, majd újra futtatjuk `dart format`/`flutter analyze`.

---

# 🧪 Tesztállapot

- Teszt terv:
  1) `cd app && dart format .` (a kódmozgatás után)
  2) `./scripts/check.sh` (pub get, analyze, test)
  3) Ellenőrizzük, hogy a `app_smoke_test.dart` a megváltozott útvonalakról importál.

---

# 🌍 Lokalizáció

- Ez a task nem érinti az ARB fájlokat; a meglévő lokalizációs kulcsok változatlanok.
- Az auth/login/register screenek továbbra is a `AppLocalizations`-t használják.

---

# 📎 Kapcsolódások

- `docs/architect/project_structure.md` – feature-first struktúra iránymutatása
- `documents/authentication/auth_implementation_plan.md` – auth gráf forrás, hogy a jelenlegi login/register képernyők az új struktúrában is megtartják a működést
- `legacy/lib/router.dart`, `legacy/lib/providers/auth_provider.dart` – csak referencia a routing/auth szervezéshez
- `app/test/widget/app_smoke_test.dart` – teszt importok frissítése
