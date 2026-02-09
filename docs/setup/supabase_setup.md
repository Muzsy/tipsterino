# Supabase local setup

Ez a guide a helyi Supabase stack futtatását és a DB contract check lépéseit rögzíti.

## 1) Előfeltételek
- Docker fut.
- Supabase CLI elérhető a PATH-ban.
- `psql` kliens telepítve.

## 2) Local stack indítás + migrációk
1. Stack indítás:
   - `./scripts/supabase.sh start`
2. Local DB reset (migrációk alkalmazása seed nélkül):
   - `./scripts/supabase.sh db reset --local --no-seed`

## 3) DB contract check
- Futtatás:
  - `./scripts/check_db.sh`
- A script a `supabase/sql_checks/*.sql` ellenőrzéseket futtatja.

## 4) `app/.env` kitöltése local Supabase-hoz
- A local API port a `supabase/config.toml` alapján: `api.port = 54321`.
- A pontos local API URL és anon key lekérdezhető:
  - `./scripts/supabase.sh status`
- Ezek az értékek `app/.env` fájlba kerülnek (gitignored), nem commitolhatók.

## 5) Auth redirect/site_url osszhang (kotelezo)
- A local auth alap URL a `supabase/config.toml` szerint:
  - `[auth].site_url = "http://127.0.0.1:3000"`
  - `[auth].additional_redirect_urls = ["https://127.0.0.1:3000"]`
- Az app callback route jelenleg:
  - `app/lib/src/app/router/app_router.dart` -> `path: '/auth/callback'`
- Ha email/deeplink callbacket hasznalsz, a redirect URL-ben a route legyen konzisztens az app route-tal (pelda: `/auth/callback`).
- Reszletes auth config es define workflow: `docs/setup/supabase_configuration.md`

## 6) Rövid troubleshooting
- Docker nincs elindítva: indítsd el, majd ismételd a `./scripts/supabase.sh start` parancsot.
- Supabase CLI nem érhető el: telepítsd, majd ellenőrizd `./scripts/supabase.sh --version`.
- `psql` hiányzik: telepítsd a PostgreSQL klienst.
- Port ütközés (pl. 54321/54322): állítsd le az ütköző folyamatot, majd indítsd újra a stack-et.

## 7) Migration rollback hivatkozas
- Incident esetben a canonical rollback runbook:
  - `docs/qa/migration_rollback_strategy.md`
- Local helyreallitas utan kotelezo minimum:
  - `./scripts/check_db.sh`
  - `./scripts/verify.sh --report codex/reports/<area>/<task>.md`
