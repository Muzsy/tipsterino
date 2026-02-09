# Audit P0-6: bonus RPC rate limiting strategy

## 🎯 Funkcio
Celfeladat: dontes + minimalis, implementalhato vedelmi terv a bonus RPC hivaspam csokkentesere.

Valasztott MVP irany:
- DB oldali rovid idoablakos limiter (`consume_bonus_rpc_token`) user+RPC alapon.
- DB oldali concurrency guard (`pg_try_advisory_xact_lock`) a dupla/parhuzamos trigger visszafogasara.
- A signup es daily bonus RPC ezt kozosen hasznalja.

Nem cel:
- teljes observability platform bevezetese
- minden endpoint rate-limitje egy taskban
- kliens oldali UX finomhangolas az uj `rate_limited` reasonra

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `docs/core_logic/bonus_system.md`
- `docs/architect/service_dependencies.md`

Tervezett kimenetek:
- ADR/dontesi doksi: `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- elso implementacios migracio: `supabase/migrations/20260213000000_bonus_system_rpc_rate_limit_guard.sql`
- ellenorzes: `supabase/sql_checks/bonus_system_rpc_rate_limit_checks.sql`

DoD:
- [ ] van dokumentalt opcio-osszehasonlitas (DB lock vs Edge Function vs mas)
- [ ] kivalsztott MVP vedelem implementalva legalabb daily/signup bonusra
- [ ] SQL check igazolja a vedelmi alapot
- [ ] report tartalmazza a trade-offokat es residual risket
- [ ] verify gate futas dokumentalt

Kockazat/rollback:
- Tulszigoru limit legit kerest blokkolhat; fallback szabaly kell a doksiban.
- Ha limiter regressziot okoz, rollback: uj korrekcios migracioval a helper hivas kikapcsolasa az RPC-kben.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/bonus_rpc_rate_limiting_strategy.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql`
- `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- `docs/core_logic/bonus_system.md`
- `docs/architect/service_dependencies.md`
