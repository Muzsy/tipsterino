## Mit találtunk?
- A canvas szerint a `grant_signup_bonus_if_eligible()` kizárólag akkor engedélyezheti a bónuszt, ha a profil teljes — a nickname és az avatar mezők nem lehetnek üresek, különben `profile_incomplete` reason kell visszatérjen.
- A meglévő behavior checks igazolták, hogy egy nem teljes profil esetén a trigger nem szállít grantot, így a bónusz logika alkalmas a profile check bevezetésére.

## Mit módosítottunk?
- Létrehoztuk a `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql` migrációt, amely újradefiniálja a `grant_signup_bonus_if_eligible()` függvényt: auth.uid() után lekérdezi a `public.profiles` sort, ellenőrzi a `nickname` és `avatar_key` mezők nem null/nem üres állapotát, és `profile_incomplete` reason mellett tér vissza side-effect nélkül, ha bármelyik hiányzik.
- Frissítettük a behavior checket (`supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`): felvettünk egy `profile_incomplete` tesztesetet (avatar reset), a valid grantnál pedig biztosítjuk, hogy a profil teljes legyen, és az idempotencia/visszatérés megegyezik a korábbi viselkedéssel.
- A reportban szereplő `psql` parancsok között a migráció és a behavior check is lefutott (mindkettő PASS).

## Módosított/létrehozott fájlok
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_rpc_signup_bonus_profile_complete_gate.md`
- `codex/reports/bonus_system/bonus_system_rpc_signup_bonus_profile_complete_gate.md`

## Tesztek
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql` – PASS (függvény frissítése).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` – PASS (`profile_incomplete` logika + idempotencia).

## Következő javasolt lépések
1. Kötelezően futtasd a migráció és behavior check parancsokat CI-ben is, hogy minden build alatt érvényes legyen a profile complete gate.
2. Ha a profilhoz további mezők (pl. phone, bio) válnak kötelezővé, bővítsd a gate-et és az SQL checket ennek megfelelően.
