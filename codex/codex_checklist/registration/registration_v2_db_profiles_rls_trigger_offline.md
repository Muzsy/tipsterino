# Registration v2 DB profiles RLS trigger (offline) – Checklist

## DoD
- [x] Canvas, goal YAML, checklist és report elkészült.
- [x] `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` létrejött a táblákkal, view-val, RLS-sel, RPC-val és triggerrel.
- [x] `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` létrejött az ellenőrző lekérdezésekkel.
- [x] `./scripts/check.sh` lefutott (Flutter lint/test) – a migrációhoz kapcsolódó CLI parancsok egy későbbi taskban.

## Feladat-specifikus pontok
- [x] A SQL migráció lefedi a nickname regex CHECK-et, unique indexet, RLS policy-kat, view/grantot, RPC-t és trigger functiont.
- [x] A checks SQL minden kötelező lekérdezést tartalmaz.
- [x] A reportban jelölve, hogy a DB apply és checks külön task (#04B).
