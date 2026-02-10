**FAIL** - report scaffold, futas es bizonyitekok meg nincsenek kitoltve.

## 1) Meta
- **Task slug:** `registration_legacy_register_path_decommission`
- **Kapcsolodo canvas:** `canvases/audit_p0/registration_legacy_register_path_decommission.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_registration_legacy_register_path_decommission.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** nincs rogzitve
- **Fokusz terulet:** auth + routing + docs

## 2) Scope
### 2.1 Cel
- Legacy `register()` auth ut kivezetese vagy explicit tiltasa.
- `/auth/register` wizard-only routing enforce.
- Regisztracios doksi szinkronizalasa.

### 2.2 Nem-cel (explicit)
- signup wizard redesign.
- DB trigger atalakitas.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/presentation/screens/register_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `app/test/widget/guest_routing_shells_test.dart`
- `docs/core_logic/registration_flow.md`
- `codex/codex_checklist/audit_p0/registration_legacy_register_path_decommission.md`
- `codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

### 3.2 Miert valtoztak?
- A futas utan toltendo: hogyan lett megakadalyozva a metadata-nelkul signup ut.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart`

### 4.3 Eredmeny roviden
- Nincs kitoltve.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `AuthNotifier.register()` nem marad legacy hivoagkent | FAIL | n/a | n/a | n/a |
| `register_screen.dart` nincs aktiv route-ban | FAIL | n/a | n/a | n/a |
| `/auth/register` wizardra mutat | FAIL | n/a | n/a | n/a |
| route regresszios teszt frissitve | FAIL | n/a | n/a | n/a |
| verify gate futas dokumentalt | FAIL | n/a | n/a | n/a |

## 8) Advisory notes (nem blokkolo)
- Nincs.

<!-- AUTO_VERIFY_START -->
<!-- AUTO_VERIFY_END -->
