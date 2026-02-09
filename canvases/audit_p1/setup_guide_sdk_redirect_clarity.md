# Audit P1-6: setup guide sdk + redirect clarity

## 🎯 Funkcio
Celfeladat: setup dokumentacioban explicit Flutter/Dart SDK es Supabase redirect/site_url kovetelmenyek rogzitse a helyes onboardingot.

Nem cel:
- auth flow kod valtoztatasa
- uj redirect URI schema bevezetese

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/pubspec.yaml`
- `supabase/config.toml`
- `docs/setup/dev_setup.md`
- `docs/setup/supabase_setup.md`
- `docs/setup/supabase_configuration.md`
- `README.md`

Tervezett kimenetek:
- setup docs pontositas:
  - `docs/setup/dev_setup.md`
  - `docs/setup/supabase_setup.md`
  - `docs/setup/supabase_configuration.md`
- root onboarding hivatkozas frissites: `README.md`

DoD:
- [ ] dev setup tartalmazza az elvart Flutter/Dart SDK verzio informaciot
- [ ] Supabase site_url es additional_redirect_urls szerepe explicit dokumentalt
- [ ] auth callback redirect path pontos, konzisztens a jelenlegi app route-tal
- [ ] setup doksik kereszt-hivatkozasa egyertelmu

Kockazat/rollback:
- pontatlan redirect doksi onboarding auth hibat okoz; valtozas utan doksi review kotelezo.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/setup_guide_sdk_redirect_clarity.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `app/pubspec.yaml`
- `supabase/config.toml`
- `docs/core_logic/registration_flow.md`
