# Registration v2 DB profiles RLS trigger (apply) – Report

## Futtatott parancsok
- `./scripts/supabase.sh --version`
- `set -a; source .env.local; set +a; ./scripts/supabase.sh projects list`
- `set -a; source .env.local; set +a; ./scripts/supabase.sh link --project-ref "$SUPABASE_PROJECT_REF"`
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push`
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `./scripts/check.sh` (felső jogosultsággal ismételve, miután alapból permission hiba történt)

## Eredmény
- **Preflight:** CLI verzió és `projects list` működik, `.env.local` és `app/.env` kulcsai jelen vannak, valamint a migrációs és checks fájlok a helyükön vannak.
- **Supabase link:** lefutott (`Finished supabase link.`).
- **db push:** HIBA: `syntax error at or near "not"` a `CREATE POLICY IF NOT EXISTS` utasításnál; a távoli PostgreSQL nem ismeri a `IF NOT EXISTS` kiterjesztést a policy-kre, így a migráció nem alkalmazódott.
- **SQL checks:** a psql lefutott, az első két lekérdezés `f` értéket ad (`profiles_table_exists`, `public_profiles_view_exists`), de a következő sor hibára fut: a `public.check_nickname_available(unknown)` függvény nem létezik, mert a migráció nem futott le.
- **./scripts/check.sh:** alapból permission hiba volt (`engine.stamp` írása), de emelt (`require_escalated`) futtatással az analyze és widget tesztcsomag sikeresen lefutott.

## Módosított / létrehozott fájlok
1. `canvases/registration/registration_v2_db_profiles_rls_trigger_apply.md`
2. `codex/goals/canvases/registration/fill_canvas_registration_v2_db_profiles_rls_trigger_apply.yaml`
3. `codex/codex_checklist/registration/registration_v2_db_profiles_rls_trigger_apply.md`
4. `codex/reports/registration/registration_v2_db_profiles_rls_trigger_apply.md`

## Megjegyzések
- A `db push` és a checks futtatása csak akkor megy tovább, ha a migrációs SQL-t egy `CREATE POLICY` kompatibilis formára hozza valaki, illetve ha a hozzátartozó függvény létrejön, ezért a következő lépésben a migrációs SQL-t kell felülvizsgálni és kiküszöbölni a `IF NOT EXISTS` használatot.
