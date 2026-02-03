# Bonus system email verified checklist

## P1 – Canvas alignment
- [x] A `canvases/bonus_system/bonus_system_docs_email_verified.md` bemutatja a funkciót, a nem célokat és a releváns fájlokat, illetve explicit leírja az email-verifikáció utáni triggerpontot.

## P2 – Data model szinkron
- [x] A `docs/data_model/reward_definitions_table_doc.md`, `reward_grants_table_doc.md`, `user_stats_table_doc.md` és `user_events_table_doc.md` leírják az email verifikáció + első authenticated session alapú signup bónusz triggerpontot, valós útvonalat adnak meg az elején, valamint kereszthivatkozást tartalmaznak a `docs/core_logic/bonus_system.md` single source of truth-ra.

## P3 – QA gate
- [x] `./scripts/check.sh` lefuttatva (eredményt a riport részletezi).
