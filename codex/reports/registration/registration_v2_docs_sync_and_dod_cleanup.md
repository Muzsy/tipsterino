# Registration v2 docs sync + DoD cleanup – Report

## Futtatott parancsok
- `./scripts/check.sh`

## Eredmény
- A `docs/data_model/profiles_table_doc.md` mostantól a tényleges, már alkalmazott `^[a-z0-9_.]{3,20}$` regex-et, a `profiles_nickname_lower_ux` `lower(nickname)` indexet és a `check_nickname_available` RPC `SECURITY DEFINER` + grant jogosultságát rögzíti, jelezve, hogy a pont (`.`) engedélyezett és a case-insensitiv egyediség DB-szinten garantált.
- A fix/reapply canvasban pontosult a leírás: csak a `CREATE POLICY IF NOT EXISTS` használat volt tiltott, a table/index `IF NOT EXISTS` változatlanul maradt; a checklistben minden DoD pont [x]-re váltott és a reportban rögzített migráció/checks/check.sh futás összhangban van.
- `./scripts/check.sh` lefutott (analyze + widget teszt), hiba nélkül.

## Módosított / létrehozott fájlok
1. `docs/data_model/profiles_table_doc.md`
2. `canvases/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
3. `canvases/registration/registration_v2_docs_sync_and_dod_cleanup.md`
4. `codex/codex_checklist/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
5. `codex/codex_checklist/registration/registration_v2_docs_sync_and_dod_cleanup.md`
6. `codex/goals/canvases/registration/fill_canvas_registration_v2_docs_sync_and_dod_cleanup.yaml`
7. `codex/reports/registration/registration_v2_docs_sync_and_dod_cleanup.md`

## Megjegyzések
- A doc sync feladatot lezártnak tekinthetjük: a szöveg hűen tükrözi a már alkalmazott migrációt, és a fix/reapply DoD is pipálva van.
