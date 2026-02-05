# Bonus system RPC signup bonus negative access checks checklist

## P1 – Canvas + terv
- [x] A canvas leírja, hogy a negatív access check „BEGIN; ... ROLLBACK;” blokkon belül fut, nincs top-level `PERFORM`, és a vizsgálat `SET LOCAL search_path TO pg_catalog, public, auth;`-ot használ.
- [x] A terv előírja, hogy ne használjuk a `SET LOCAL ROLE`/`SET ROLE`-t, hanem `has_*_privilege` hívásokkal bizonyítjuk a privilege-ket.

## P2 – Implementációs blokkok
- [x] Az SQL script `has_function_privilege('anon', 'public.grant_signup_bonus_if_eligible()', 'EXECUTE') = false` ellenőrzéssel biztosítja, hogy az anon nem tudja meghívni az RPC-t.
- [x] Az anon szerepkörnél mindhárom DML (INSERT/UPDATE/DELETE) tiltott a `reward_grants`, `user_stats` és `user_events` táblákon.
- [x] Az authenticated jogoknál csak SELECT és `read_at` UPDATE engedélyezett a `public.user_events` táblán; az INSERT, DELETE és a többi oszlop UPDATE-je tiltva van.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` lefutott (jelen környezetben az anon EXECUTE joggal rendelkezik, ezért hibát dob a check).
