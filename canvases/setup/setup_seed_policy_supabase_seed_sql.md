# FILE: canvases/setup/setup_seed_policy_supabase_seed_sql.md

# P1-3: Seed policy – supabase/seed.sql placeholder rendbetétele

## 🎯 Funkció
Rendezzük a **Supabase seed** helyzetét úgy, hogy ne legyen félreérthető:

- a repo-ban lévő **`supabase/seed.sql` miért csak placeholder / no-op**
- mi a **hivatalos seed-policy** (CI vs lokál)
- hogyan készül **dev tesztadat** seed nélkül (helyettesítő folyamat)

Cél: ne legyen “miért van seed.sql, ha sosem fut?” típusú bizonytalanság, és a **reproducibilitás** megmaradjon.

## 🧠 Fejlesztési részletek

### Kiinduló állapot (bizonyítékok)
- `supabase/seed.sql` jelenleg placeholder / no-op:
  - fájl: `supabase/seed.sql`
- A Supabase config seedet deklarál:
  - `supabase/config.toml` → `[db.seed] enabled = true`, `sql_paths = ["./seed.sql"]`
- A repo standard DB-contract reset **seed nélkül fut**:
  - CI: `.github/workflows/ci_db.yml` → `supabase db reset --local --no-seed`
  - docs: `docs/qa/db_checks.md` → `supabase db reset --local --no-seed`

Ez együtt jelenleg azt jelenti: **config szerint van seed**, de a standard folyamatok **kifejezetten kihagyják**.

### Döntés / policy (amit rögzíteni kell)
1) **CI és DB contract check mindig seed nélkül fut**  
   - indok: determinisztikus, a checkek ne függjenek opcionális dev adatbetöltéstől  
   - forrás: `.github/workflows/ci_db.yml`, `docs/qa/db_checks.md`

2) **`supabase/seed.sql` célja nem “feature adatbetöltés”, hanem egyértelmű, ártalmatlan placeholder**  
   - seed ne írjon `auth.users`-t (brittle + félrevezető)
   - seed ne generáljon user-bound adatot (RLS miatt úgysem “hasznos” általánosan)

3) **Dev tesztadat generálás seed helyett app-flowval történik**
   - regisztráció / belépés → létrejön user
   - bónuszok / események → normál felhasználói folyamatokkal keletkeznek a rekordok
   - a DB ellenőrzés ettől független (SQL contract check)

### Konkrét kimenetek
- `supabase/seed.sql` kapjon **egyértelmű policy header-t** (miért no-op, mire nem való, hogyan fut(na)).
- Új doksi: `docs/qa/seed_policy.md`
  - seed stratégia (CI vs lokál)
  - miért nem seedelünk user adatot (`auth.users`)
  - “hogyan legyen dev adat”: app-flow + rövid lépések
- `docs/qa/db_checks.md` frissítés:
  - rövid megjegyzés és link a seed policy doksira (miért `--no-seed`)

### DoD (pipálható)
- [ ] `supabase/seed.sql` frissítve: egyértelműen rögzíti, hogy **szándékosan no-op**, és miért.
- [ ] Létrejön `docs/qa/seed_policy.md` (seed/tesztadat stratégia + hivatkozások).
- [ ] `docs/qa/db_checks.md` hivatkozik a seed policy doksira és jelzi, miért fut `--no-seed`.
- [ ] Létrejön a Codex checklist + report váz:
  - `codex/codex_checklist/setup/setup_seed_policy_supabase_seed_sql.md`
  - `codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`
- [ ] Task záráskor lefut:
  - `./scripts/verify.sh --report codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`
  - log: `codex/reports/setup/setup_seed_policy_supabase_seed_sql.verify.log`

## 🧪 Tesztállapot
Kötelező (repo gate):
- `./scripts/verify.sh --report codex/reports/setup/setup_seed_policy_supabase_seed_sql.md`

Opcionális (ha lokál Supabase fut):
- `supabase start`
- `supabase db reset --local --no-seed`
- `./scripts/check_db.sh`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `supabase/seed.sql`
- `supabase/config.toml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `scripts/check_db.sh`
- `scripts/verify.sh`
- `docs/codex/report_standard.md`
