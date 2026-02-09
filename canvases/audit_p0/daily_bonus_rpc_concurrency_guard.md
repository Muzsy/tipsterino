# Audit P0-4: daily bonus RPC concurrency guard

## 🎯 Funkcio
Celfeladat: csokkenteni a dupla grant kockazatot parhuzamos daily bonus RPC hivasoknal szerveroldali lockkal es ellenorzessel.

Nem cel:
- daily bonus UI/UX atalakitasa
- reward amount policy valtoztatas

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
- `supabase/sql_checks/bonus_system_rpc_daily_bonus_checks.sql`
- `docs/core_logic/daily_bonus.md`

Tervezett kimenetek:
- migracio frissites: `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- uj/vagy bovitett SQL check: `supabase/sql_checks/bonus_system_rpc_daily_bonus_concurrency_checks.sql`
- doksi kiegeszites: `docs/core_logic/daily_bonus.md`

DoD:
- [ ] a daily bonus RPC tartalmaz user-szintu concurrency vedelmet
- [ ] check bizonyitja, hogy 2 parhuzamos triggerbol max 1 grant keletkezik
- [ ] reportban explicit rogzites van a determinisztikus masodik valaszrol
- [ ] verify gate futas dokumentalt

Kockazat/rollback:
- Lock rossz hasznalata teljesitmenyromlast okozhat; reportban merni kell a hatast.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/daily_bonus_rpc_concurrency_guard.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `supabase/sql_checks/bonus_system_rpc_daily_bonus_behavior_checks.sql`
- `docs/core_logic/daily_bonus.md`
