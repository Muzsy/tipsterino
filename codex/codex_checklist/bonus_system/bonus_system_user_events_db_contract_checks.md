# Bonus system user_events DB contract checks checklist

## P1 – Canvas + terv
- [x] A canvas definiálja az oszlop/típus, RLS, privilege és index követelményeket a `public.user_events` táblára.
- [x] A SQL check `BEGIN; … ROLLBACK;` alatt fut, így nem hagy nyomot az adatbázisban.

## P2 – Implementációs blokkok
- [x] `supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` validálja az oszlopok/típusok meglétét és a `public.user_events` RLS bekapcsoltságát.
- [x] A script `has_table_privilege`/`has_column_privilege` hívásokkal biztosítja a SELECT/INSERT/DELETE tiltásokat és a `read_at` UPDATE jogot (más oszlopokra nincs UPDATE).
- [x] Az index sanity ellenőrzés legalább egy `user_id` + `created_at` indexet megtalál, különben EXCEPTION.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` lefutott.
