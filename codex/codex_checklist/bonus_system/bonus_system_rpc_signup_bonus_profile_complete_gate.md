# Bonus system RPC signup bonus profile complete gate checklist

## P1 – Canvas + terv
- [x] A `canvases/bonus_system/bonus_system_rpc_signup_bonus_profile_complete_gate.md` definiálja a profile complete gate-et (nickname+avatar megléte) és a profile_incomplete reason-t.
- [x] A migráció és a behavior checks egyaránt a profile-incomplete logikát teszteli (granted csak profil teljes állapotban).

## P2 – Implementációs blokkok
- [x] `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql` a `grant_signup_bonus_if_eligible()` függvényt úgy frissíti, hogy a verified user profilját lekérdezi, és nickname/ avatar ellenőrzésekor `profile_incomplete` okkal tér vissza mellékhatás nélkül.
- [x] `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` új tesztesettel bővült: avatar blank -> profile_incomplete és grant nem történik; granted eset előtt a profil teljesre áll, majd a korábbi feltételek fennmaradnak.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql` futott (függvény frissítése).
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql` lefutott (profile_incomplete és granted ellenőrzések).
