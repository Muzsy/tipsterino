## Mit találtunk?
- A `docs/data_model/*` dokumentumok eddig a "regisztráció lezárása" vagy `profiles` insertje után kötötték a signup bónuszt, ami nem tükrözte az email-verifikációhoz szervezett triggerpontot.
- Hiányzott a hivatkozás a `docs/core_logic/bonus_system.md` single source of truth-ra minden érintett tábladokiban.

## Mit módosítottunk?
- Transparens módon átírtuk a 4 data_model leírást úgy, hogy a signup bónusz a server-oldali post-auth init logika részeként történik, `email_verified` + első authenticated session feltételekkel, és minden dokumentum a valós fájlútvonalat, valamint a `docs/core_logic/bonus_system.md` referenciát tartalmazza.
- Rögzítettük az új triggerpontot a `docs/data_model/reward_definitions_table_doc.md` `MVP kötelező folyamat` részében és a többi dokumentum felhasználási, kapcsolódási szakaszában.
- Elkészítettük a task-hoz tartozó checklist-et (`codex/codex_checklist/bonus_system/bonus_system_docs_email_verified.md`) és ezt a riportot, így a folyamat teljesen dokumentált.

## Módosított/létrehozott fájlok
- `docs/data_model/reward_definitions_table_doc.md`
- `docs/data_model/reward_grants_table_doc.md`
- `docs/data_model/user_stats_table_doc.md`
- `docs/data_model/user_events_table_doc.md`
- `codex/codex_checklist/bonus_system/bonus_system_docs_email_verified.md`
- `codex/reports/bonus_system/bonus_system_docs_email_verified.md`

## Tesztek
- `./scripts/check.sh` – PASS

## Következő javasolt lépések
1. Ellenőrizni, hogy a `docs/core_logic/registration_flow.md` és a tényleges Supabase/Edge Function logika is az email-verifikáció utáni triggerpontot tükrözi.
2. Konzisztencia-ellenőrzés a `docs/core_logic/bonus_system.md` és az app oldali események (pl. `user_events` kódok, lokalizáció) között, hogy a UI a friss triggerpontot mutassa.
