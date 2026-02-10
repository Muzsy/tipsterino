# Audit P1-2: user_event code schema-client consistency

## 🎯 Funkcio
Celfeladat: a `user_events.code` nullable DB szerzodes es a Flutter kliens parse/UI viselkedesenek osszehangolasa, hogy ne legyen runtime crash null `code` ertek esetben.

Nem cel:
- `user_events` teljes tipus vagy payload redesign
- events inbox UX redesign a jelenlegi fallback szovegen tul

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/src/features/events/data/user_events_repository.dart`
- `app/test/widget/events_inbox_data_flow_test.dart`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `docs/data_model/user_events_table_doc.md`

Tervezett kimenetek:
- domain modell frissites: `app/lib/src/features/events/domain/user_event.dart`
- inbox fallback frissites: `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- uj unit teszt: `app/test/unit/user_event_model_test.dart`
- widget teszt frissites: `app/test/widget/events_inbox_data_flow_test.dart`
- adatmodell doksi frissites: `docs/data_model/user_events_table_doc.md`

DoD:
- [ ] a `UserEvent.fromMap` nem dob exceptiont null `code` miatt
- [ ] az inbox cim/body fallback logika kezeli a null/ures `code` erteket
- [ ] unit + widget teszt levedi a null `code` esetet
- [ ] data model doksi explicit rogziti a nullable `code` kliens oldali kezeleset

Kockazat/rollback:
- a nullable kezeles elfedhet adatminosegi hibakat; rollback lehetosegkent kulon DB migration taskban visszaallithato `NOT NULL` policy.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

## 🌍 Lokalizacio
Nem erintett (uj l10n kulcs nem varhato).

## 📎 Kapcsolodasok
- `docs/data_model/user_events_table_doc.md`
- `docs/screens/events_inbox_screen.md`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
