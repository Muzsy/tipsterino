# Bonus system DB schema + RLS checklist

## P1 – Canvas + preflight
- [x] A `canvases/bonus_system/bonus_system_db_schema_rls.md` részletesen felsorolja az érintett supabase fájlokat, a scripteket (`scripts/supabase.sh`, `psql ... -f supabase/sql_checks/...`) és a preflight ellenőrzést (Supabase MCP/psql, `.env.local` betöltése).
- [x] A Supabase MCP olvasó jellegű resource query tartalmazza a táblák meglétének ellenőrzését (ha az OAuth handshake blokkolja, az eredmény a riportban szerepel).

## P2 – Sémák + RLS
- [x] `supabase/seed.sql` placeholder készen áll.
- [x] `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql` létrehozva a tablákkal, RLS-sel, policy-kkel, triggerrel és bootstrap `signup_bonus` rekorddal.
- [x] `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` ellenőrzi a táblák, RLS, policy-k, indexek és a `signup_bonus` rekord meglétét.

## P3 – QA gate
- [x] `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` futott.
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` futott (a checks fájl a pg_policies oszlopneveit is helyesen használja).
- [x] `./scripts/check.sh` lefutott a repo minden tesztjével.
