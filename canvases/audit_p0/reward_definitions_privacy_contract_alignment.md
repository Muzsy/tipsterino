# Audit P0-2: reward_definitions privacy contract alignment

## 🎯 Funkcio
Celfeladat: a `public.reward_definitions` tabla jogosultsagi szerzodesenek kanonikus rogzitese es automatikus ellenorzese.

Konfliktusjegyzet:
- A javitasi terv P0-2 public SELECT policy-t javasol.
- A magasabb prioritasu repo forrasok (`AGENTS.md`, `docs/core_logic/bonus_system.md`, `docs/data_model/reward_definitions_table_doc.md`) szerint kliens oldali SELECT tiltott.
- Ez a task a repo-kanonikus privacy contractot koveti.

Nem cel:
- public read policy bevezetese
- reward osszeg valtoztatas

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `docs/core_logic/bonus_system.md`
- `docs/data_model/reward_definitions_table_doc.md`
- `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- `supabase/migrations/20260212000000_bonus_system_reward_definitions_privilege_contract_fix.sql`

Tervezett kimenetek:
- SQL check erosites/frissites: `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- docs szinkron: `docs/data_model/reward_definitions_table_doc.md`
- codex checklist + report

DoD:
- [ ] a SQL check explicit ellenorzi: RLS ON, policy count = 0
- [ ] a SQL check explicit ellenorzi: anon/authenticated/public nem kap SELECT jogot
- [ ] a tabla doksi ugyanazt a contractot irja le
- [ ] report tartalmazza a konfliktusfeloldast es hivatkozott forrasokat
- [ ] verify gate step a YAML vegere kerult

Kockazat/rollback:
- Ha mar van eltaro policy grant, a task FAIL-t ad es kulon migracios javitast ker.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/reward_definitions_privacy_contract_alignment.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `AGENTS.md`
- `docs/core_logic/bonus_system.md`
- `docs/data_model/reward_definitions_table_doc.md`
- `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
