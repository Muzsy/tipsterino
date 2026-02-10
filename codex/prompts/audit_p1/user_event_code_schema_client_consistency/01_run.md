Olvasd el:
- AGENTS.md
- canvases/audit_p1/user_event_code_schema_client_consistency.md
- codex/goals/canvases/audit_p1/fill_canvas_user_event_code_schema_client_consistency.yaml

Majd hajtsd vegre a YAML `steps` lepeseit sorrendben.

Task output cel:
- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/test/unit/user_event_model_test.dart`
- `app/test/widget/events_inbox_data_flow_test.dart`
- `docs/data_model/user_events_table_doc.md`
- `codex/codex_checklist/audit_p1/user_event_code_schema_client_consistency.md`
- `codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

Verifikacio a vegen:
- `./scripts/flutter.sh test test/unit/user_event_model_test.dart test/widget/events_inbox_data_flow_test.dart`
- `./scripts/verify.sh --report codex/reports/audit_p1/user_event_code_schema_client_consistency.md`

Log/report elvaras:
- verify log: `codex/reports/audit_p1/user_event_code_schema_client_consistency.verify.log`
- reportban legyen explicit bizonyitek a null `code` parse + UI fallback regresszios tesztekrol.
