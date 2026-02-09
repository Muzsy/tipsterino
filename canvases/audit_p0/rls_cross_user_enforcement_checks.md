# Audit P0-1: RLS cross-user enforcement checks

## 🎯 Funkcio
Celfeladat: DB-szinten bizonyitani, hogy authenticated user1 nem fer hozza user2 adataihoz a kritikus tablakat erinto SELECT/UPDATE muveletekben.

Erintett tablák:
- `public.profiles`
- `public.reward_grants`
- `public.user_stats`
- `public.user_events`

Nem cel:
- uj app UI logika
- bonus osszeg vagy reward pipeline valtoztatas
- production adatmozgas

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `scripts/check_db.sh`

Tervezett kimenetek:
- uj SQL check: `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql`
- docs frissites: `docs/qa/db_checks.md`
- codex artefaktok: checklist + report

DoD:
- [ ] letrejott a cross-user enforcement SQL check
- [ ] van legalabb egy explicit user1->user2 negativ eset minden kritikus tablara
- [ ] a check fut a `./scripts/check_db.sh` folyamatban
- [ ] reportban bizonyitek van a DB check futasrol es eredmenyrol
- [ ] repo verify gate futtatas szerepel a YAML utolso stepjeben

Kockazat/rollback:
- Ha valamelyik ellenorzes piros, a report FAIL statuszt kap es a policy javitas kulon follow-up taskban megy.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/rls_cross_user_enforcement_checks.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/testing_guidelines.md`
- `docs/codex/yaml_schema.md`
- `docs/codex/report_standard.md`
- `supabase/sql_checks/bonus_system_rls_cross_user_enforcement_checks.sql`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
