## Mit találtunk?
- A maga nemében a canvas a `grant_signup_bonus_if_eligible()` viselkedését várja a különböző auth állapotokban, és azt, hogy a reward/user_stats/user_events oldali mellékhatások pontosan egyetlen grantnál jelenjenek meg.
- Emberi hibalehetőség volt a verified mezők kezelésében, ezért a checks scriptnek tudnia kell, hogy melyik mező frissíthető (email_confirmed_at vs confirmed_at) és mikor kell tranzakciót/leállást használni.

## Mit módosítottunk?
- Megírtuk a `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` fájlt, ami `BEGIN; ... ROLLBACK;` blokkban futtatja a not_authenticated/not_verified/granted/idempotens lépéseket, `set_config('request.jwt.claim.sub', ...)`-szal és determinisztikusan beállított reward_definitions rekorddal.
- A script biztosítja, hogy a not_verified ág nem hoz létre reward_grants/user_stats/user_events rekordot, míg a granted ág egy grantot és egy user_eventet hoz létre, majd az idempotens újrahívás nem növeli a számlálókat.
- Az `auth.users` insert-be `raw_user_meta_data` (nickname+avatar) és a megfelelő verified mezők finomhangolása került, a `confirmed_at` csak akkor frissül, ha már nem generált oszlop.

## Módosított/létrehozott fájlok
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_behavior_checks.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_behavior_checks.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS (BEGIN/ROLLBACK, no side effects).

## Következő javasolt lépések
1. Ha a `reward_definitions` táblában több code-ot vezetünk be, érdemes lehet a scriptet több grant esetére is futtatni.
2. Távoli CI környezetben automatizálni a psql parancsot, hogy a viselkedési teszt mindig lefusson a migrációk után.
