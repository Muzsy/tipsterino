# 🎯 Funkció

A `registration_v2` migrációját a Supabase távoli környezetében kell alkalmazni, majd a kapcsolódó SQL ellenőrzéseket futtatni annak igazolására, hogy a `profiles` tábla, a trigger és a RLS
támogatás ténylegesen létrejöttek. A feladat célja, hogy a CLI-alapú műveletsor dokumentáltan lefusson egy Supabase projektre.

### Nem cél
- A migráció SQL fájljának módosítása (ha hibás, a futtatás megszakad és a jelentés írja le az okot).
- Rewards/user_events/user_stats táblák létrehozása.
- Flutter app kód vagy lokalizáció érintése.

# 🧠 Fejlesztési részletek

### Talált releváns fájlok
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` – a táblát, view-t, policy-kat, RPC-t és triggert definiáló migráció.
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – a táblák, view és trigger ellenőrzéséhez előkészített lekérdezések.
- `supabase/config.toml` – a Supabase CLI konfigurációja a repositoryban (önmagában nem módosul).
- `scripts/supabase.sh` – a CLI wrapper, itt futtatjuk a link/db push/db query parancsokat.
- `documents/authentication/auth_implementation_plan.md` – a triggeres regisztrációs flow háttere.
- `docs/qa/testing_guidelines.md` – `./scripts/check.sh` futtatásának és a tesztengedményeknek a szabályai.
- `AGENTS.md` – a Codex által kötelezően betartandó repo-szabályok.

### Pipálható teendők
- [x] Preflight: Supabase CLI elérhetőség és `.env.local`/`app/.env` kulcsnevek ellenőrizve (`--version`, `projects list`, kulcslista).
- [x] Distributed link parancs futtatása (`./scripts/supabase.sh link --project-ref "$SUPABASE_PROJECT_REF"`).
- [ ] `./scripts/supabase.sh db push` – jelenleg syntax error miatt elbukik (`CREATE POLICY IF NOT EXISTS` nem támogatott a remote verzióban).
- [ ] `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – a `check_nickname_available` függvény hiányzik, ezért a lekérdezés hibára fut.
- [x] `./scripts/check.sh` (elevált futtatással) – analyze és widget tesztek zöldek.

### Kockázatok + rollback
- **Kockázat:** A `db push` futtatása `CREATE POLICY IF NOT EXISTS` miatt syntax hibát dob (a remote Postgres nem támogatja ezt). **Rollback:** a migrációs SQL-t a következő promptban frissíteni kell a kompatibilis `CREATE POLICY` formára, majd újra megkísérelni a push-t.
- **Kockázat:** A checks SQL abból a függvényből olvas, amit a migráció hoz létre. Mivel a push nem futott, a `check_nickname_available` hiányzik, így a lekérdezés hibát dob. **Rollback:** a futtatás ismétléséhez előbb a migrációt kell sikeresen alkalmazni, majd újra kell futtatni a SQL checket.

# 🧪 Tesztállapot
- `./scripts/supabase.sh db push` – **FAIL**: `syntax error at or near "not"` (a `CREATE POLICY IF NOT EXISTS` nem értelmezett a remote verzióban).
- `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – **FAIL**: a `public.check_nickname_available` függvény nem létezik, ezért a lekérdezés megáll.
- `./scripts/check.sh` – **PASS** (eleinte permission hiba, majd elevated futtatással sikeresen lefutott az analyze+widget teszt csomag).

# 🌍 Lokalizáció
- Nem érinti a lokalizációt.

# 📎 Kapcsolódások
- `documents/authentication/auth_implementation_plan.md`
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `supabase/config.toml`
- `scripts/supabase.sh`
- `docs/qa/testing_guidelines.md`
- `AGENTS.md`
