# Registration v2 DB profiles RLS trigger (fix/reapply) – Report

## Futtatott parancsok
- `./scripts/supabase.sh --version`
- `set -a; source .env.local; set +a; ./scripts/supabase.sh projects list`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -c "select version from supabase_migrations.schema_migrations where version = '20260125000000';"`
- `set -a; source .env.local; set +a; ./scripts/supabase.sh link --project-ref "$SUPABASE_PROJECT_REF"`
- `set -a; source .env.local; set +a; printf 'y\n' | ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `./scripts/check.sh`

## Eredmény
- **Preflight:** a CLI verzió (`2.65.5`) és a `projects list` sikeresen lefutott, majd a `supabase_migrations.schema_migrations` táblában nincs `20260125000000` bejegyzés, tehát még nem alkalmazódott a migráció.
- **Supabase link:** `Finished supabase link.` – a projekt referencia újra beállítva.
- **db push:** siker, a távoli `profiles` migráció alkalmazódott; a `drop policy`/`create policy` blokknál a CLI két `NOTICE`-t dobott, mert a policy-k még nem léteztek, de ez nem hibát jelentett.
- **SQL checks:** az `accounts` ellenőrzések mind `true` állapotban futottak le (`profiles_table_exists = true`, `public_profiles_view_exists = true`, `nickname_available = true`, `trigger_exists = true`, `rls_enabled = true`).
- **./scripts/check.sh:** az analyze + widget tesztek hibamentesen lefutottak; nem volt permission hiba.

## Módosított / létrehozott fájlok
1. `canvases/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
2. `codex/goals/canvases/registration/fill_canvas_registration_v2_db_profiles_rls_trigger_fix_reapply.yaml`
3. `codex/codex_checklist/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
4. `codex/reports/registration/registration_v2_db_profiles_rls_trigger_fix_reapply.md`
5. `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`

## Megjegyzések
- A `supabase/migrations/...` fájl most drop+create policy mintát használ, a `check_nickname_available` és `create_profile_on_signup` függvények `security definer set search_path` deklarációt kaptak, a `perform 1 from ...` sor eltűnt, és a szükséges grant-ok felkerültek a profiltáblára és az RPC-ra.
- A `db push` után az SQL check lekérdezések is igazolták, hogy a `profiles` tábla, a view, a trigger, és az RPC rendben vannak; a `check_nickname_available` pedig sikeres `true` értékkel tért vissza.
