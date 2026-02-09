# Audit P1-4: user_events unread partial index

## 🎯 Funkcio
Celfeladat: `user_events` olvasatlan lista lekero teljesitmenyenek javitasa partial index bevezetesevel.

Nem cel:
- user_events API felulet valtoztatasa
- inbox UX redesign

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `app/lib/src/features/events/data/user_events_repository.dart`
- `docs/data_model/user_events_table_doc.md`

Tervezett kimenetek:
- uj migracio: `supabase/migrations/20260214000000_user_events_unread_partial_index.sql`
- sql check frissites: `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- data model doksi frissites: `docs/data_model/user_events_table_doc.md`

DoD:
- [ ] letezik partial index olvasatlan (`read_at is null`) user_events listara
- [ ] DB contract check validalja az index jelenletet
- [ ] migracio idempotens (if not exists / safe rerun)
- [ ] reportban szerepel teljesitmeny rationale

Kockazat/rollback:
- index epites write lockot okozhat nagy tablan; prod futtatashoz idozites/monitoring kell.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/user_events_unread_partial_index.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/db_checks.md`
- `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql`
- `docs/data_model/user_events_table_doc.md`
