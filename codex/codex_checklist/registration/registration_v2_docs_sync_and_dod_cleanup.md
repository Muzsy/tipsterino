# Registration v2 docs sync + DoD cleanup – Checklist

## DoD
- [x] Canvas, goal YAML, checklist és report elkészültek a feladathoz.
- [x] `docs/data_model/profiles_table_doc.md` tükrözi a tényleges `^[a-z0-9_.]{3,20}$` regex-et, a lowercase unique indexet és a `check_nickname_available` RPC security definer/grant részleteit.
- [x] `canvases/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md` és a hozzá tartozó checklist pontosan írják le a drop+create policy-cserét, a DoD pipálását és a fix/reapply jelentést.
- [x] `./scripts/check.sh` lefutott és az eredmény a reportban dokumentált (analyze + widget tesztcsomag).

## Feladat-specifikus pontok
- [x] A reportban szerepel minden parancs (futtatott doc/CI lépések + `./scripts/check.sh`).
- [x] A doc szinkron és a DoD cleanup kapcsán megfogalmazott részek egyértelműek és rövidek.
