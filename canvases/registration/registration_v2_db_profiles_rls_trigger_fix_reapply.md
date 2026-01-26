# 🎯 Funkció

A meglévő `profiles`/RLS/trigger migrációt kompatibilissé kell tenni a távoli Supabase PostgreSQL verzióval (eltávolítani az `IF NOT EXISTS`-t, fix search_path-ot és bazis jogokat beállítani), majd a `db push` és a checks SQL újrafuttatásával igazolni, hogy minden constraint, trigger és helper függvény működik.

### Nem cél
- UI vagy auth réteg módosítása.
- Rewards/user_events/user_stats táblák létrehozása.
- Új migrációk írása, ha a 20260125000000 verzió még nincs a remote listában (az `apply` során módosított SQL-t dolgozza fel).

# 🧠 Fejlesztési részletek

### Talált releváns fájlok
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` – az aktualizálandó migráció, benne a policy-k, view, trigger és RPC.
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – a trigger/rls ellenőrzésére szolgáló SQL.
- `scripts/supabase.sh` – a CLI wrapper, ezzel futtatjuk a `link`, `db push` és a `db query`/`db push` parancsokat.
- `scripts/check.sh` – repository szintű lint + teszt wrapper, a végén futtatni kell.
- `documents/authentication/auth_implementation_plan.md` és `docs/data_model/profiles_table_doc.md` – meghatározzák, hogy a profil `nickname` nem módosítható, a trigger pedig metaadatból dolgozik.
- `docs/qa/testing_guidelines.md` – a tesztelt parancsok és a `./scripts/check.sh` futtatásának szabályai.

### Pipálható teendők
- [x] Preflight: CLI verzió és `projects list`, `.env.local` kulcsai, és a `supabase_migrations.schema_migrations` tábla lekérdezése megerősítve.
- [ ] Migráció javítása: `IF NOT EXISTS` helyett drop+create, `check_nickname_available`/`create_profile_on_signup` security fixes és grant-ok.
- [ ] `./scripts/supabase.sh db push` futtatása; ha a push újra hibát ad, dokumentáld.
- [ ] `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/...` futtatása; rögzítsd a sorok kimenetét.
- [ ] `./scripts/check.sh` futtatása (perm hiba esetén emelt jogosultság is ok).

### Kockázatok + rollback
- **Kockázat:** a policy-k törlése/újraépítése rosszul van időzítve, ami leállíthatja a `db push`-t. **Rollback:** a migrációs fájl visszaállítása az előző verzióra, utána újra átdolgozva (ha a push továbbra sem megy, a következő taskban új SQL-t kell generálni).
- **Kockázat:** a `check_nickname_available` vagy trigger függvény hibás grant miatt nem hozza létre a profilokat. **Rollback:** a SQL módosítások visszatartása, letesztelve `psql` segítségével a function `SELECT`-jét a devben.

# 🧪 Tesztállapot
- `./scripts/supabase.sh db push` – a migráció alkalmazását ellenőrizzük.
- `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` – validálja a táblalét, view-t, trigger meglétét és a `check_nickname_available` függvényt.
- `./scripts/check.sh` – repository standard analyze+widget teszt.

# 🌍 Lokalizáció
- Nem érinti a UI szöveget.

# 📎 Kapcsolódások
- `documents/authentication/auth_implementation_plan.md`
- `docs/core_logic/registration_flow.md`
- `docs/data_model/profiles_table_doc.md`
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql`
- `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql`
- `scripts/supabase.sh`
- `scripts/check.sh`
