# Audit P1-5: migration rollback strategy playbook

## 🎯 Funkcio
Celfeladat: dokumentalt rollback playbook bevezetese a Supabase migracios incident helyzetekhez.

Nem cel:
- automatikus down migration framework bevezetese
- production schema azonnali modositas

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `docs/setup/supabase_setup.md`
- `docs/qa/db_checks.md`
- `scripts/supabase.sh`
- `scripts/check_db.sh`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`

Tervezett kimenetek:
- uj rollback playbook: `docs/qa/migration_rollback_strategy.md`
- setup doksi hivatkozas frissites: `docs/setup/supabase_setup.md`
- db checks hivatkozas frissites: `docs/qa/db_checks.md`

DoD:
- [ ] letezik lepesrol-lepesre rollback eljaras local/stage/prod szintre bontva
- [ ] tartalmazza a kotelezo utolagos verifikaciot (db reset/check_db/verify)
- [ ] tartalmaz migration incident dontesi fat (rollback vs forward-fix)
- [ ] setup es QA doksik hivatkoznak a playbookra

Kockazat/rollback:
- rossz rollback script adatvesztest okozhat; a playbooknak explicit backup/approval gate-et kell rogzitenie.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/verify.sh --report codex/reports/audit_p1/migration_rollback_strategy_playbook.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/setup/supabase_setup.md`
- `docs/qa/db_checks.md`
- `scripts/supabase.sh`
