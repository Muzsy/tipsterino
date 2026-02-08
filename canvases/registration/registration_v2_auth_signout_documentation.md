# 🎯 Funkció

Az audit egyik tipikus félreértése, hogy “nincs logout/signOut implementáció”. A repóban van: `AuthNotifier.signOut()` Supabase `auth.signOut()` hívással, és a Settings screen használja. Ezt röviden, konkrét fájlutakkal dokumentálni kell, hogy későbbi audit / új fejlesztő ne állítson ellentmondásosat.

### Talált releváns fájlok
- `docs/core_logic/authentication_flow.md` – ide kerül a rövid “Kijelentkezés / signOut” blokk.
- `app/lib/src/features/auth/presentation/state/auth_provider.dart` – `AuthNotifier.signOut()` implementáció.
- `app/lib/src/screens/settings_screen.dart` – UI-ból hívja a `signOut()`-ot.
- `docs/codex/report_standard.md` – report szerkezet.
- `scripts/verify.sh` – kötelező repo gate + AUTO_VERIFY blokk frissítés.

### Pipálható teendők
- [ ] A `docs/core_logic/authentication_flow.md` kap egy rövid, célzott szekciót: **Kijelentkezés (signOut)**.
      - Tartalmazza, hol van az implementáció (`auth_provider.dart`), és mit csinál (Supabase `auth.signOut()` + state unauthenticated).
      - Tartalmazza, hol hívódik UI-ból (`settings_screen.dart`).
      - Rögzíti az offline viselkedést (ha Supabase nincs konfigurálva, unauthenticated állapot).
- [ ] Készüljön checklist + report a standard szerint:
      - `codex/codex_checklist/registration/registration_v2_auth_signout_documentation.md`
      - `codex/reports/registration/registration_v2_auth_signout_documentation.md`
      - AUTO_VERIFY blokk: `./scripts/verify.sh --report ...` futtatva, log mentve.
- [ ] Repo gate legyen zöld: `./scripts/verify.sh --report codex/reports/registration/registration_v2_auth_signout_documentation.md`

### Kockázatok + rollback
- **Kockázat:** doksi drift (kód változik, a szöveg elavul).  
  **Rollback:** a hozzáadott szekció visszavonása, majd újra felvétel a friss kód szerint.

# 🧪 Tesztállapot
- Kötelező: `./scripts/verify.sh --report codex/reports/registration/registration_v2_auth_signout_documentation.md`

# 🌍 Lokalizáció
- Nem érint UI szöveget / arb kulcsokat.

# 📎 Kapcsolódások
- `docs/core_logic/authentication_flow.md`
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/screens/settings_screen.dart`
- `docs/codex/report_standard.md`
- `scripts/verify.sh`
