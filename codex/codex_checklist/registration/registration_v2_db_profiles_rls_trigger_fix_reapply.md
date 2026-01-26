# Registration v2 DB profiles RLS trigger (fix/reapply) – Checklist

## DoD
- [x] Preflight: CLI verzió, `projects list`, `.env.local` és `app/.env` kulcsai, valamint a remote `supabase_migrations.schema_migrations` ellenőrzése megtörtént.
- [ ] A migrációs SQL (`supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`) `CREATE POLICY IF NOT EXISTS` helyett `drop`+`create` mintára frissítve, a függvények `security definer` + `set search_path` beállítással, a `perform 1 from ...` sor eltávolítva és a `grant`-ok hozzáadva.
- [ ] `./scripts/supabase.sh db push` lefutott (vagy hibára futott, a reportban dokumentálva), és a migrációs státusz a remote DB-ben frissült.
- [ ] `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` lefutott, a `profiles` tábla, view, trigger és a `check_nickname_available` függvény státusza dokumentálva.
- [ ] `./scripts/check.sh` lefutott (emelt jogosultság, ha szükséges) és az eredmény a reportban szerepel.

## Feladat-specifikus pontok
- [ ] A reportban fel van tüntetve, hogy mely parancsok futottak és milyen kimenettel (success/FAIL) tértek vissza.
- [ ] A `db push` sikere vagy sikertelensége után a következő lépések (hook + checks) dokumentálva vannak.
- [ ] A migrációs file módosításai megfelelnek a Supabase remote PostgreSQL verziónak (nem használnak nem támogatott szintaxist).
