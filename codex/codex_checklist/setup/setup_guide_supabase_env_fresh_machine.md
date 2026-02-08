# Setup guide Supabase env fresh machine checklist

## P0 – Canvas + cél
- [x] Létrejött / frissült a canvas: `canvases/setup/setup_guide_supabase_env_fresh_machine.md`.

## P1 – Setup guide dokumentumok
- [x] Létrejött: `docs/setup/dev_setup.md` wrapper-parancsokkal (`./scripts/flutter.sh`, `./scripts/check.sh`, `./scripts/verify.sh`).
- [x] Létrejött: `docs/setup/supabase_setup.md` CI-vel konzisztens local Supabase lépésekkel (`start`, `db reset --local --no-seed`, `./scripts/check_db.sh`).
- [x] A guide rögzíti, hogy `app/.env` és `.env.local` gitignored, kulcs nem commitolható.

## P2 – Belépési pontok + deprecate
- [x] `README.md` és `docs/README.md` linkeli az új setup guide-okat.
- [x] `documents/supabase_configuration.md` elején deprecate/átirányítás szerepel a `docs/setup/*` fájlokra és wrapper használatra.

## P3 – Repo gate + report
- [x] Elkészült: `codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`.
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`.
- [x] Létrejött verify log: `codex/reports/setup/setup_guide_supabase_env_fresh_machine.verify.log`.
