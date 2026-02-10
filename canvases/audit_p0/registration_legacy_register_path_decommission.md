# Audit P0-2: registration legacy register path decommission

## 🎯 Funkcio
Celfeladat: a `register()` legacy auth ut teljes kivezetese vagy explicit tiltasa, hogy csak a Registration V2 wizard maradjon elerheto.

Miert P0:
- A `create_profile_on_signup` trigger metadata-t kovetel (`nickname`, `avatar_key`), a legacy `register()` ezt nem kuldi.
- Ha a legacy ut barmikor visszakotodik, determinisztikusan torik a regisztracio.

Nem cel:
- wizard UX redesign
- auth provider teljes refaktor
- DB trigger logika atirasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/presentation/screens/register_screen.dart`
- `app/lib/src/app/router/app_router.dart`
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `docs/core_logic/registration_flow.md`

Tervezett kimenetek:
- legacy API cleanup: `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- legacy screen torles/deprecate: `app/lib/src/features/auth/presentation/screens/register_screen.dart`
- routing guard ellenorzes: `app/lib/src/app/router/app_router.dart`
- regresszios route teszt: `app/test/widget/guest_routing_shells_test.dart`
- doksi frissites: `docs/core_logic/registration_flow.md`

DoD:
- [ ] `AuthNotifier.register()` nem marad hivhato legacy utkent
- [ ] `register_screen.dart` nincs aktiv routingban (torolve vagy explicit deprecalt, unreachable)
- [ ] `/auth/register` tovabbra is a wizardra mutat
- [ ] widget teszt validalja a guest/auth routing stabilitast
- [ ] a regisztracios doksi egyertelmuen kimondja, hogy minimal register ut nincs

Kockazat/rollback:
- Ha barmely flow meg hasznalja a legacy route-ot, a cleanup utan compile/runtime hiba johet; rollback uj commitban csak tudatos visszakotessel.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/flutter.sh test test/widget/guest_routing_shells_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p0/registration_legacy_register_path_decommission.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/architect/routing_integrity.md`
- `docs/core_logic/authentication_flow.md`
- `docs/core_logic/registration_flow.md`
