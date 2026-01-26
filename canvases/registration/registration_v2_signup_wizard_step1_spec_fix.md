# 🎯 Funkció

A SignUp wizard Step 1 megvalósítása igazodjon a projekt dokumentációjához:
- a jelszó mező **alapértelmezetten látható (plaintext)** legyen (obscureText=false),
- a 4 jelszó szabály közül a 4. szabály **“legalább 1 speciális karakter”** legyen (nem “szám”),
- a szabálylista továbbra is dinamikusan “eltűnő” legyen (csak a nem teljesülők látszanak),
- a „Tovább” CTA csak akkor aktiválódjon, ha email valid + minden jelszó szabály teljesül,
- mindez l10n-kulcsokkal és friss widget teszttel lefedve.

### Nem cél
- Step 2 (nickname + avatar) implementálása.
- Step 3 (consent + submit) implementálása.
- Supabase signUp hívás.

# 🧠 Fejlesztési részletek

### Releváns fájlok
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
  - jelszó TextField: default **nem maszkos**, opcionális szem ikon engedett (de default: látható)
  - szabálylista: a “number” szabály helyett “special char”
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
  - jelszó szabályok: `hasMinLength`, `hasLowercase`, `hasUppercase`, `hasSpecialChar`
  - `step1Valid` ezekből számolódjon
- `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb`
  - `auth_password_rule_number` helyett új kulcs: `auth_password_rule_special`
  - a régi kulcsot távolítsd el, és frissítsd a hivatkozásokat
- `app/test/widget/auth_signup_wizard_step1_test.dart`
  - frissüljön a teszt, és olyan jelszót használjon, ami teljesíti az új szabályt (pl. `Abcd!efg`)
- `documents/registration/registration_flow_V2-md`
  - legyen szinkronban: Step 1 jelszó **plaintext**, és a 4. szabály **special char** (ne number)

### Jelszó “special char” definíció
- Fogadd el “speciális karakternek” a nem-alfanumerikus karaktert, **de a whitespace ne számítson bele**.
  - Javasolt regex: `RegExp(r'[^\w\s]')` vagy ekvivalens (Dartban: nem betű/szám/underscore, és nem whitespace).

### Pipálható teendők
- [ ] Step 1: jelszó mező default plaintext (obscureText=false), opcionális toggle megengedett.
- [ ] Step 1: “number” szabály lecserélve “special char”-ra (state + UI).
- [ ] L10n: `auth_password_rule_special` kulcs HU/EN, régi kulcs eltávolítva, gen-l10n lefut.
- [ ] Widget teszt frissítve az új szabályra.
- [ ] `documents/registration/registration_flow_V2-md` szinkronba hozva.
- [ ] `./scripts/check.sh` zöld.

# 🧪 Tesztállapot
- `./scripts/flutter.sh gen-l10n`
- `./scripts/check.sh`

# 🌍 Lokalizáció
- Új kulcs: `auth_password_rule_special` (EN+HU)
- Régi kulcs: `auth_password_rule_number` eltávolítása + hivatkozások átvezetése

# 📎 Kapcsolódások
- `docs/core_logic/registration_flow.md`
- `documents/authentication/auth_implementation_plan.md`
- `documents/registration/registration_flow_V2-md`
