# 🎯 Funkció

A regisztráció nickname szabályait és a DB migráció tényleges viselkedését dokumentáció szinten kell összehangolni: a `docs/data_model/profiles_table_doc.md`-ot a tényleges, már alkalmazott `^[a-z0-9_.]{3,20}$` regex-szel, lowercase unique index-szel és RPC jogosultságokkal kell frissíteni, továbbá a `registration_v2_db_profiles_rls_trigger_fix_reapply` artefaktokat is DoD-szinten le kell zárni (pontosság, pipálás, hibajegy). A cél, hogy a doksi és DoD egyértelműen tükrözze a futtatott migrációt.

### Talált releváns fájlok
- `docs/data_model/profiles_table_doc.md` – a nickname szabályait tartalmazza, itt kell bejegyezni a regex/unique/ RPC részleteket.
- `docs/core_logic/registration_flow.md` – a flow kimenete (nickname normálizálás, trigger kötelező profile) a háttérben meghatározó.
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` – az aktuális konfigurációs állapot, aminél a regex, policy-grant, RPC security definer beállítások relevánsak.
- `canvases/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md` – a már végrehajtott fix/reapply task canvas-a, itt pontosítani kell a `CREATE POLICY IF NOT EXISTS`-szal kapcsolatos mondatot.
- `codex/codex_checklist/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md` – a DoD, amit a report szerint ki kell pipálni.

### Pipálható teendők
- [ ] A `docs/data_model/profiles_table_doc.md` a tényleges, már alkalmazott `^[a-z0-9_.]{3,20}$` regex-et és a `profiles_nickname_lower_ux` unique indexet rögzíti, kiemelve, hogy `.` engedélyezett és a check RPC `SECURITY DEFINER`-rel fut.
- [ ] A `registration_v2_db_profiles_rls_trigger_fix_reapply.md` canvasában a szándék világos: csak a `CREATE POLICY IF NOT EXISTS` mintát oldottuk meg drop+create-ral, a tábla/index `IF NOT EXISTS`-ei változatlanok.
- [ ] A `registration_v2_db_profiles_rls_trigger_fix_reapply.md` checklistben minden DoD pont pipálva van, a report már leírta a migrációt, checks-et és `./scripts/check.sh` futást.
- [ ] A `./scripts/check.sh` futott a módosítások után, és az eredmény a reportban szerepel.

### Kockázatok + rollback
- **Kockázat:** a docfrissítés nem tükrözi a valós állapotot, ezért a következő fejlesztők rosszul értelmezhetik a nickname szabályt. **Rollback:** vissza a korábbi szövegre és újra egyeztetés.
- **Kockázat:** a DoD checklist pontjai nem pipálódnak, így a task lezáratlan marad. **Rollback:** report felülvizsgálata, a checklist frissítése és a canvas/doksi pontosítása.

# 🧪 Tesztállapot
- `./scripts/check.sh` – repository standard analyze+widget teszt.

# 🌍 Lokalizáció
- A feladat nem érinti a UI szöveget.

# 📎 Kapcsolódások
- `docs/core_logic/registration_flow.md`
- `documents/authentication/auth_implementation_plan.md`
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `canvases/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
- `codex/codex_checklist/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
