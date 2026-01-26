# Registration v2 DB profiles RLS trigger (apply) – Checklist

## DoD
- [x] Preflight: CLI verzió, `projects list`, `.env.local`/`app/.env` kulcsnévlista megvan, a migrációs és checks SQL fájlok léteznek.
- [x] `supabase/config.toml` jelenléte ellenőrizve, init nem szükséges.
- [x] `./scripts/supabase.sh link --project-ref "$SUPABASE_PROJECT_REF"` lefutott.
- [ ] `./scripts/supabase.sh db push` – a push megszakadt: `CREATE POLICY IF NOT EXISTS` miatt syntax error a remote DB-n.
- [ ] `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – a `public.check_nickname_available` függvény hiánya miatt sokkal hamarabb hibára fut, csak az első két lekérdezés értéke került kiértékelésre.
- [x] `./scripts/check.sh` (emelt jogosultsággal) – analyze és widget tesztek sikeresen lefutottak.

## Feladat-specifikus pontok
- [x] A jelentés tartalmazza a Supabase parancsokat és azok kimenetét (szintén a fails eseteket).
- [ ] A távoli migráció és checks futtatása csak akkor pipálható, ha a `CREATE POLICY` syntax és a függvény létrehozása is sikerül.
