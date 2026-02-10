**FAIL** - Scaffold only; implementacio es verifikacio nem futott ebben a korben.

## 1) Meta
- **Task slug:** user_event_code_schema_client_consistency
- **Kapcsolodo canvas:** canvases/audit_p1/user_event_code_schema_client_consistency.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_user_event_code_schema_client_consistency.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (scaffold)
- **Fokusz terulet:** State + UI + Docs

## 2) Scope
### 2.1 Cel
- `user_events.code` nullable schema es kliens parse konzisztencia.
- inbox fallback viselkedes hardening null/ures code esetre.
- regresszios tesztlefedes bovitese.

### 2.2 Nem-cel (explicit)
- teljes user_events model redesign.
- events inbox UX redesign.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/user_event_code_schema_client_consistency.md`
- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/test/unit/user_event_model_test.dart`
- `app/test/widget/events_inbox_data_flow_test.dart`
- `docs/data_model/user_events_table_doc.md`
- `codex/codex_checklist/audit_p1/user_event_code_schema_client_consistency.md`
- `codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

### 3.2 Miert valtoztak?
- P1 nullable code konzisztencia task formalizalasa.
- Implementacios es verifikacios outputok konkretizalasa.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart`

### 4.3 Eredmeny roviden
- Ebben a korben scaffold keszult, verifikacio nem futott.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| a `UserEvent.fromMap` nem dob exceptiont null `code` miatt | FAIL | n/a | Implementacio meg nem tortent. | unit test |
| az inbox cim/body fallback logika kezeli a null/ures `code` erteket | FAIL | n/a | Implementacio meg nem tortent. | widget test |
| unit + widget teszt levedi a null `code` esetet | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/flutter.sh test ...` |
| data model doksi explicit rogziti a nullable `code` kliens oldali kezeleset | FAIL | n/a | Implementacio meg nem tortent. | docs review |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a scaffold korben.

<!-- AUTO_VERIFY_START -->
Scaffold allapot: verify futas meg nem tortent.
<!-- AUTO_VERIFY_END -->
