# Bonus system RPC signup bonus negative access checks checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_rpc_signup_bonus_negative_access_checks.md` meghatározza az anon/authenticated privilege ellenőrzéseket és a ROLLBACK-jellegű scriptet.
- [x] Az SQL check `BEGIN; ... ROLLBACK;` blokkban fut, így nem hagy nyomot az adatbázisban.

## P2 – Implementációs blokkok
- [x] `supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` anon szerepkörnél ellenőrzi, hogy az RPC EXECUTE és a reward/user táblák INSERT privileges tiltottak.
- [x] Az authenticated role esetén `has_column_privilege` hívásokkal igazoljuk, hogy csak `read_at`-ra van UPDATE jog, az `amount/type/code` oszlopokra nincs.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_negative_access_checks.sql` lefutott.
