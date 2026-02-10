# Audit P1-1: rpc_rate_limit_state retention cleanup

## 🎯 Funkcio
Celfeladat: `public.rpc_rate_limit_state` tabla retention/cleanup folyamat bevezetese, hogy a limiter allapottabla ne noljon korlatlanul.

Nem cel:
- bonus RPC uzleti szabalyok atirasa
- limiter window (`10s`) es attempt (`5`) parameterek modositasanak bevezetese

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `supabase/migrations/20260213000000_bonus_system_rpc_rate_limit_guard.sql`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_checks.sql`
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `docs/qa/db_checks.md`
- `scripts/check_db.sh`

Tervezett kimenetek:
- uj migracio: `supabase/migrations/20260217000000_rpc_rate_limit_state_retention_cleanup.sql`
- uj SQL check: `supabase/sql_checks/bonus_system_rpc_rate_limit_retention_checks.sql`
- strategy doksi frissites: `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- DB check guide frissites: `docs/qa/db_checks.md`

Implementacios irany:
- cleanup fuggveny neve: `public.cleanup_bonus_rpc_rate_limit_state(interval, integer)`
- SECURITY DEFINER + search_path hardening (`pg_catalog, public, auth`)
- retention alap: `7 days`, batch cleanup tamogatassal
- contract check: function jelenlet, privilege guard (anon/auth execute tiltott), basic smoke invocation

DoD:
- [ ] letezik SECURITY DEFINER cleanup fuggveny a `public.rpc_rate_limit_state` regi sorainak torlesere
- [ ] a cleanup futtatasi modja dokumentalt (cron vagy kulso scheduler), fallback manual parancsokkal
- [ ] SQL check validalja a cleanup fuggveny jelenletet es alap retention szerzodest
- [ ] reportban kulon evidence van a `check_db` futasrol es a retention rationale-rol

Kockazat/rollback:
- tul agressziv retention torolheti a hibaanalizishez hasznos limiter adatokat; rollbackhez uj migracioval visszaallithato retention ablak kell.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check_db.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/rpc_rate_limit_state_retention_cleanup.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/core_logic/bonus_rpc_rate_limiting_strategy.md`
- `docs/qa/db_checks.md`
- `supabase/sql_checks/bonus_system_rpc_rate_limit_checks.sql`
