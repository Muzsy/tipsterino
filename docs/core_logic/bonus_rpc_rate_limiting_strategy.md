# Bonus RPC rate limiting strategy

## Context
A bonus RPC-k (`grant_signup_bonus_if_eligible`, `grant_daily_bonus_if_eligible`) jelenleg idempotens grant logikaval dolgoznak, de erdemi hivasfrekvencia-limit nelkul.

Celpont:
- burst/spam hivasok DB-terhelesenek csokkentese,
- parhuzamos hivasok determinisztikus kezelese,
- minimalis invazivitas a jelenlegi Supabase RPC architekturaban.

## Option summary
1. Edge Function gateway limiter
- Elony: kulso rate-limit middleware egyszeruen illesztheto.
- Hatrany: plusz szolgaltatasi reteg, route/security atalakitas.

2. DB helper table + limiter function + advisory lock
- Elony: gyors bevezetes, jelenlegi RPC-k mellett marad.
- Hatrany: limiter allapot DB-ben tarolt, cleanup policy kesobb kellhet.

3. Kliens oldali debounce only
- Elony: legegyszerubb.
- Hatrany: nem ved szerver oldalon, tamadas ellen gyenge.

## Selected MVP
A P0 MVP a 2. opcio:
- `public.rpc_rate_limit_state` tabla user+rpc alapu allapothoz.
- `public.consume_bonus_rpc_token(...)` helper function rovid idoablakos tokenfogyasztassal.
- `pg_try_advisory_xact_lock` a parhuzamos futasok serializalasara.

Alap parameterek (MVP):
- window: 10 masodperc
- max attempts: 5 / user / RPC / window

## Behavior contract
Ha a limiter tilt:
- signup RPC valasz: `{"granted":false,"amount":0,"reason":"rate_limited"}`
- daily RPC valasz: `{"granted":false,"amount":0,"reason":"rate_limited","next_eligible_at":...}`

Megjegyzes:
- A kliens jelenleg az ismeretlen reason kodot fallbackkent kezeli; ezt P1-ben erdemes explicit UI reason mappinggel kovetni.

## Security and privilege notes
- A limiter tablahoz nincs kliens oldali grant.
- A limiter helper `SECURITY DEFINER`, search_path hardeninggel.
- A ket bonus RPC tovabbra is csak `authenticated` role-ra executable.

## Retention cleanup contract (P1)
- Cleanup helper: `public.cleanup_bonus_rpc_rate_limit_state(interval, integer)`
- Alap parameterek:
  - retention: `7 days`
  - batch size: `10000`
- A helper `SECURITY DEFINER`, search_path hardeninget hasznal, es
  `last_attempt_at` alapjan torli a stale sorokat.
- Privilege policy:
  - `anon`/`authenticated` execute nincs
  - scheduler/admin futtatja (cron vagy kulso job)
- Monitoring/check:
  - SQL contract check: `supabase/sql_checks/bonus_system_rpc_rate_limit_retention_checks.sql`

Manual futtatas (operational fallback):
- `select public.cleanup_bonus_rpc_rate_limit_state(interval '7 days', 10000);`

## Residual risks
- Egy legitim user gyors kattintasnal `rate_limited` valaszt kaphat.
- Ha a retention tul szigorura van allitva, a hibaelemzeshez hasznos limiter
  adatok korabban torlodhetnek.
- Tovabbi hardeningkent kesobb Edge Function perimeter limiter bevezetese javasolt.

## Follow-up candidates
- UI reason mapping bovites (`rate_limited` kulon kezeles).
- Limiter metrics/logging a terheles monitorozasara.
- Window/attempt parameterek feature flag alapu finomhangolasa.
