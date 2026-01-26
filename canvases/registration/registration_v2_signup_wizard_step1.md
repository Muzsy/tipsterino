# 🎯 Funkció

A SignUp wizard három lépéses keretrendszerének első lépését kell megvalósítani: az email+jelszó inputot valós idejű szabálylistával, a Tovább gomb engedélyezését a validáció függvényében és offline státuszra reagáló állapotkezelést. A két következő lépés (Profil + Consent) csak placeholder UI-t kap (cím + "coming next"), hogy a navigáció már működjön, de a tényleges tartalom későbbi task.

### Nem cél
- Supabase signUp hívása.
- Nickname availability RPC, avatar és consent logika implementálása.
- Új route-ok vagy Supabase kliens logika bevezetése.

# 🧠 Fejlesztési részletek

### Talált releváns fájlok
- `app/lib/src/app/router/app_router.dart` – a `/auth/register` route meg kell kapja az új wizard képernyőt.
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart` – a Step 1 UI és Step 2/3 placeholder komponensei.
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart` – a wizard state (lépésszámláló, email, jelszó, step1 validáció) Riverpod providerrel.
- `app/lib/l10n/app_en.arb` + `app/lib/l10n/app_hu.arb` – új kulcsok (common_next/back/coming_next, auth_signup_step_*, auth_password_rule_*) + goncolt fordítások.
- `app/lib/l10n/app_localizations*.dart` – generált API, amely új kulcsokat tesz elérhetővé a screennek.
- `app/test/widget/auth_signup_wizard_step1_test.dart` – widget teszt a Step 1 validációhoz.
- `documents/registration/registration_flow_V2-md` + `docs/core_logic/registration_flow.md` – a wizard 3 lépéses flow és email/jelszó leírását biztosítják.

### Pipálható teendők
- [ ] Wizard route: `/auth/register` új `SignUpWizardScreen` builderrel és állapotvezérelt stepekkel.
- [ ] Step 1 UI: email validáció, jelszó szabályok (4 darab), offline notice, Next gomb engedélyezés / tilítás.
- [ ] Placeholder Step 2/3 megjelenítés (cím + coming next + ikon).
- [ ] Riverpod wizard state provider (stepIndex/email/password/step1Valid) és használata a képernyőn.
- [ ] Lokalizáció és l10n generálás: új kulcsok mindkét ARB-ben, `./scripts/flutter.sh gen-l10n` futtatása.
- [ ] Widget teszt Step 1re (Tovább gomb inaktív → aktív, szabálylista eltűnik).

### Kockázatok + rollback
- **Kockázat:** A `common_next`/`common_back` kulcs hiányában a UI gomb szövege hiányos lenne. **Rollback:** töröld a hozzáadott ARB bejegyzéseket és generáld újra az l10n fájlokat.
- **Kockázat:** A route még mindig a régi register screenre mutat, így a wizard nem jelenik meg. **Rollback:** visszaáll az `app_router.dart` és újra futtasd a teszteket.

# 🧪 Tesztállapot
- `./scripts/flutter.sh gen-l10n`
- `./scripts/check.sh`

# 🌍 Lokalizáció
- Új kulcsok: `common_next`, `common_back`, `common_coming_next`, `auth_signup_step_account`, `auth_signup_step_profile`, `auth_signup_step_consent`, `auth_password_rule_min_length`, `auth_password_rule_uppercase`, `auth_password_rule_lowercase`, `auth_password_rule_number`.
- Mindkét ARB-ba bekerülnek, majd a generált `app_localizations` fájlok frissülnek.

# 📎 Kapcsolódások
- `documents/registration/registration_flow_V2-md`
- `docs/core_logic/registration_flow.md`
- `docs/codex/overview.md`
- `docs/qa/testing_guidelines.md`
