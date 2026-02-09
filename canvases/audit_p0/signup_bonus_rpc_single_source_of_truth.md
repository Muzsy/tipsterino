# Audit P0-3: signup bonus RPC single source of truth

## 🎯 Funkcio
Celfeladat: megszuntetni a `grant_signup_bonus_if_eligible()` migracios duplikaciot, hogy egyetlen kanonikus definicio maradjon.

Nem cel:
- signup bonus uzleti szabaly ujratervezese
- UI valtoztatas

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`

Tervezett kimenetek:
- migracios rendezes a fenti 3 fajlban
- SQL check erosites: `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- docs frissites: `docs/core_logic/bonus_system.md`

DoD:
- [ ] a report dokumentalja, melyik migracio marad a vegso RPC forras
- [ ] SQL check ellenorzi, hogy a vegso viselkedes stabil
- [ ] DB ellenorzes zold reset utan
- [ ] verify gate futas es report evidence kitoltve

Kockazat/rollback:
- Migracios sorrend hiba eseten reset + check_db FAIL; csak uj korrekcios migracioval javithato.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/signup_bonus_rpc_single_source_of_truth.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/migrations/20260208000000_bonus_system_reward_grants_grant_day_and_indexes.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
