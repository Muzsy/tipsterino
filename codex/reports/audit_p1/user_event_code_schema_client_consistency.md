**PASS** - user_events `code` nullable schema-kliens konzisztencia helyreallitva; null-safe parse + inbox fallback + regresszios unit/widget tesztek elkeszultek, verify PASS.

## 1) Meta
- **Task slug:** user_event_code_schema_client_consistency
- **Kapcsolodo canvas:** `canvases/audit_p1/user_event_code_schema_client_consistency.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p1/fill_canvas_user_event_code_schema_client_consistency.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (working tree)
- **Fokusz terulet:** State + UI + Docs

## 2) Scope
### 2.1 Cel
- `user_events.code` nullable schema es kliens parse viselkedes osszehangolasa.
- inbox fallback logika hardening null/ures `code` esetre.
- regresszios tesztlefedes bovites unit + widget szinten.

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
- A domain modell mar nem tekinti kotelezonek a `code` mezot parse szinten.
- Az inbox fallback render null-safe lett, igy nincs `:null` jellegu torott szoveg.
- A regresszios tesztek explicit vedik a null `code` parse/render szerzodest.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart`

### 4.3 Eredmeny roviden
- `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart` PASS.
- `./scripts/verify.sh --report codex/reports/audit_p1/user_event_code_schema_client_consistency.md` PASS.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| a `UserEvent.fromMap` nem dob exceptiont null `code` miatt | PASS | `app/lib/src/features/events/domain/user_event.dart:48`; `app/lib/src/features/events/domain/user_event.dart:117` | A parse `_parseCode`-on keresztul null-safe, a `code` domain mezot nullable-kent kezeli. | `./scripts/flutter.sh test test/unit/user_event_model_test.dart` |
| az inbox cim/body fallback logika kezeli a null/ures `code` erteket | PASS | `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart:404` | A fallback `code` szegmens csak nem-null es nem-ures kodnal kerul a szovegbe. | `./scripts/flutter.sh test test/widget/events_inbox_data_flow_test.dart` |
| unit + widget teszt levedi a null `code` esetet | PASS | `app/test/unit/user_event_model_test.dart:19`; `app/test/widget/events_inbox_data_flow_test.dart:110` | Uj unit teszt fedi a null/ures parse-t, widget teszt fedi a null `code` inbox render scenariot. | `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart` |
| data model doksi explicit rogziti a nullable `code` kliens oldali kezeleset | PASS | `docs/data_model/user_events_table_doc.md:67`; `docs/data_model/user_events_table_doc.md:177` | A doksi rogzitett schema nullable es kliens fallback szerzodest tartalmaz. | docs review |

## 8) Advisory notes (nem blokkolo)
- Ha kesobb `code` mezot `NOT NULL`-ra szigoritjuk, kulon migration + backfill task szukseges az adattisztitas miatt.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T19:14:28+01:00 → 2026-02-10T19:15:09+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/user_event_code_schema_client_consistency.verify.log`
- git: `main@6223194`
- módosított fájlok (git status): 8

**git diff --stat**

```text
 app/lib/src/features/events/domain/user_event.dart |  24 ++--
 .../presentation/screens/events_inbox_screen.dart  |  71 +++++++----
 app/test/widget/events_inbox_data_flow_test.dart   | 141 +++++++++++++++++----
 .../user_event_code_schema_client_consistency.md   |   5 +
 .../user_event_code_schema_client_consistency.md   |  32 ++---
 docs/data_model/user_events_table_doc.md           |   8 ++
 6 files changed, 212 insertions(+), 69 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/features/events/domain/user_event.dart
 M app/lib/src/features/events/presentation/screens/events_inbox_screen.dart
 M app/test/widget/events_inbox_data_flow_test.dart
 M canvases/audit_p1/user_event_code_schema_client_consistency.md
 M codex/reports/audit_p1/user_event_code_schema_client_consistency.md
 M docs/data_model/user_events_table_doc.md
?? app/test/unit/user_event_model_test.dart
?? codex/reports/audit_p1/user_event_code_schema_client_consistency.verify.log
```

<!-- AUTO_VERIFY_END -->
