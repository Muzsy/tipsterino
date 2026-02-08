# P0-3: reward_definitions privacy contract checks (no client SELECT / no policies)

## 🎯 Funkció
Cél: rögzíteni és automatán ellenőrizni, hogy a `public.reward_definitions` tábla **kliens oldalról nem olvasható és nem írható**:
- `anon` és `authenticated` **nem** kaphat `SELECT/INSERT/UPDATE/DELETE` jogosultságot,
- a táblán RLS **be van kapcsolva**,
- és **nincs** rá policy (0 db).

A szerződés célja: megakadályozni, hogy későbbi migráció/PR “véletlenül” megnyissa a jutalomkatalógust.

Nem cél:
- új policy vagy public read bevezetése,
- kliens oldali táblahozzáférés,
- reward_definitions adatainak módosítása.

## 🧠 Fejlesztési részletek
### Kiinduló állapot (repo alapján)
- A `public.reward_definitions` RLS ON, nincs policy, és nincs `GRANT SELECT` kliens szerepköröknek.
  - Migráció: `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
  - Privilege fix migrációk nem adnak grantet a reward_definitions-ra: `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`, `...070...`

### Érintett / létrejövő fájlok
- Új SQL check: `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- Doksi frissítés: `docs/data_model/reward_definitions_table_doc.md`
- Artefaktok:
  - `canvases/ci/ci_reward_definitions_privacy_contract_checks.md`
  - `codex/goals/canvases/ci/fill_canvas_ci_reward_definitions_privacy_contract_checks.yaml`
  - `codex/codex_checklist/ci/ci_reward_definitions_privacy_contract_checks.md`
  - `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md`
  - `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.verify.log` (auto)
  - `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`

### DoD (pipálható)
- [ ] Létrejött: `supabase/sql_checks/bonus_system_reward_definitions_privacy_contract_checks.sql`
- [ ] A check FAIL-ol, ha `anon` vagy `authenticated` SELECT jogot kap a `reward_definitions`-re.
- [ ] A check FAIL-ol, ha policy kerül a `reward_definitions` táblára.
- [ ] A check PASS a jelenlegi elvárt állapotban.
- [ ] `docs/data_model/reward_definitions_table_doc.md` hivatkozik a konkrét sql_check fájlra.
- [ ] DB log rögzítve: `codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`
- [ ] Repo gate rögzítve: `./scripts/verify.sh --report codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md` (+ verify log)

## 🧪 Tesztállapot
Kötelező (DB contract):
- `supabase start`
- `supabase db reset --local --no-seed`
- `./scripts/check_db.sh | tee codex/reports/ci/ci_reward_definitions_privacy_contract_checks.db_checks.log`

Kötelező (repo gate):
- `./scripts/verify.sh --report codex/reports/ci/ci_reward_definitions_privacy_contract_checks.md`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `supabase/migrations/20260206000000_bonus_system_privilege_contract_fix.sql`
- `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql`
- `docs/data_model/reward_definitions_table_doc.md`
- `scripts/check_db.sh` (P0-2)
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `docs/codex/report_standard.md`, `scripts/verify.sh`
