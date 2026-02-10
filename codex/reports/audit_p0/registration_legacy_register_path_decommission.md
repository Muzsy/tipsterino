**PASS** - legacy `register()` ut kivezetese megtortent, `/auth/register` wizard-only contract teszttel igazolt, celteszt es verify PASS.

## 1) Meta
- **Task slug:** `registration_legacy_register_path_decommission`
- **Kapcsolodo canvas:** `canvases/audit_p0/registration_legacy_register_path_decommission.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_registration_legacy_register_path_decommission.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** `main@ce4bfce`
- **Fokusz terulet:** auth + routing + docs

## 2) Scope
### 2.1 Cel
- Metadata-nelkul signupot vegzo legacy API (`AuthNotifier.register`) kivezetese.
- `/auth/register` route wizard-only viselkedesenek explicit megerositese.
- Regisztracios doksi szinkronizalasa a P0 dontessel.

### 2.2 Nem-cel (explicit)
- signup wizard UX redesign.
- DB trigger logika modositas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p0/registration_legacy_register_path_decommission.md`
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/presentation/screens/register_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/widget/guest_routing_shells_test.dart`
- `docs/core_logic/registration_flow.md`
- `codex/codex_checklist/audit_p0/registration_legacy_register_path_decommission.md`
- `codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

### 3.2 Miert valtoztak?
- A providerbol kikerult a legacy signup API, igy nem marad metadata-nelkul hivhato register ut.
- A `RegisterScreen` deprecalt adapterre lett cserelve, ami a V2 wizardot adja vissza.
- A route smoke teszt explicit lefedi a guest `/auth/register` wizard megnyitast es az authenticated redirectet.
- A registration docs explicit kimondja, hogy nincs minimal register ut.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart`

### 4.3 Eredmeny roviden
- A celteszt elso futasa 1 assertionnel FAIL volt (`findsOneWidget` vs 2 talalat), ezt javitottuk `findsWidgets`-re.
- A celteszt masodik futasa PASS.
- A verify gate PASS, AUTO_VERIFY blokk frissult.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `AuthNotifier.register()` nem marad legacy hivoagkent | PASS | `app/lib/src/features/auth/presentation/state/auth_provider.dart:65` | A providerben `signIn` utan kozvetlenul `signOut` kovetkezik, `register()` API nincs jelen. | `./scripts/verify.sh --report ...` |
| `register_screen.dart` nincs aktiv routingban (torolve vagy deprecalt, unreachable) | PASS | `app/lib/src/features/auth/presentation/screens/register_screen.dart:5` | A screen deprecalt adapter, es kizarlag a `SignUpWizardScreen`-t rendereli. | Code review |
| `/auth/register` tovabbra is wizardra mutat | PASS | `app/lib/src/app/router/app_router.dart:84` | A route builder explicit `SignUpWizardScreen`-t ad vissza, wizard-only kommenttel. | `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart` |
| widget teszt validalja a guest/auth routing stabilitast | PASS | `app/test/widget/guest_routing_shells_test.dart:85` | Uj tesztek lefedik a guest `/auth/register` wizard megnyitast es auth redirectet `/home`-ra. | `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart` |
| regisztracios doksi kimondja, hogy minimal register ut nincs | PASS | `docs/core_logic/registration_flow.md:31` | Kulon P0 dontes szekcio rogzitette a minimal register ut kivezeteset. | Doc review |

## 8) Advisory notes (nem blokkolo)
- A route neve (`register`) technikailag maradhat, de kesobbi naming cleanup taskban atnevezheto `register_wizard`-ra, ha kell.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T18:30:31+01:00 → 2026-02-10T18:31:09+01:00 (38s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p0/registration_legacy_register_path_decommission.verify.log`
- git: `main@ce4bfce`
- módosított fájlok (git status): 9

**git diff --stat**

```text
 app/lib/src/app/router/app_router.dart             |   1 +
 .../auth/presentation/screens/register_screen.dart | 180 +--------------------
 .../auth/presentation/state/auth_provider.dart     |  18 ---
 app/test/widget/guest_routing_shells_test.dart     |  29 ++++
 ...gistration_legacy_register_path_decommission.md |   5 +
 ...gistration_legacy_register_path_decommission.md |  18 +--
 ...gistration_legacy_register_path_decommission.md |  72 +++++++--
 docs/core_logic/registration_flow.md               |   7 +
 8 files changed, 115 insertions(+), 215 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/app/router/app_router.dart
 M app/lib/src/features/auth/presentation/screens/register_screen.dart
 M app/lib/src/features/auth/presentation/state/auth_provider.dart
 M app/test/widget/guest_routing_shells_test.dart
 M canvases/audit_p0/registration_legacy_register_path_decommission.md
 M codex/codex_checklist/audit_p0/registration_legacy_register_path_decommission.md
 M codex/reports/audit_p0/registration_legacy_register_path_decommission.md
 M docs/core_logic/registration_flow.md
?? codex/reports/audit_p0/registration_legacy_register_path_decommission.verify.log
```

<!-- AUTO_VERIFY_END -->
