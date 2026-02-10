# Audit P0-1: public_profiles privacy hardening

## 🎯 Funkcio
Celfeladat: a `public.public_profiles` publikus hozzaferesi szerzodesenek termekdontes-alapu rogzitese es DB hardening.

Konfliktusjegyzet:
- A jelenlegi repo allapot (`supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`, `docs/data_model/profiles_table_doc.md`) publikus olvashatosagot ir le (`anon` + `authenticated`).
- Az audit terv P0-1 szakasza privacy kockazatot jelez, ezert explicit dontes + enforceolt szerzodes szukseges.
- A task a tervet koveti: publikus vagy nem publikus iranyt formalisan rogzit, majd DB oldalon kikyszeriti.

Valasztott irany:
- `public.public_profiles` publikus olvashatosag megtartasa (`anon` + `authenticated`) a jelenlegi termek- es docs-contract szerint.
- Hardening kovetelmeny: a view mezokeszlete szigoran `id`, `nickname`, `avatar_key`, es nincs kliens oldali write jog.

Nem cel:
- `profiles` schema redesign
- avatar asset/preset ujratervezes
- regisztracios wizard UI atalakitasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `docs/data_model/profiles_table_doc.md`
- `documents/tmp/auditok/2026_02_10/audit_hibajavitasi_terv_tipsterino.md`

Tervezett kimenetek:
- uj migracio: `supabase/migrations/20260215000000_public_profiles_privacy_hardening.sql`
- DB check frissites: `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- privacy policy doksi szinkron: `docs/data_model/profiles_table_doc.md`

DoD:
- [ ] termekdontes rogzitve van: `public_profiles` publikus vagy nem publikus
- [ ] a migracio a dontott contractot enforceolja (`GRANT/REVOKE` + view mezokeszlet hardening)
- [ ] a DB check explicit validalja a vegso jogosultsagi allapotot
- [ ] a doksi pontosan ugyanazt a privacy contractot irja le, mint a migracio
- [ ] verify gate futas dokumentalva a reportban

Kockazat/rollback:
- Publikusrol zart modellre valtasnal vendeg/anon feluletek torhetnek; rollback csak uj korrekcios migracioval.
- Publikus modell fenntartasanal a mezokeszlet minimalizalasat SQL checkkel kotelezo vedeni.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/public_profiles_privacy_hardening.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/architect/service_dependencies.md`
- `docs/core_logic/registration_flow.md`
- `docs/data_model/profiles_table_doc.md`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
