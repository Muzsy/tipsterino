# FILE: canvases/setup/setup_guide_supabase_env_fresh_machine.md

# P1-2: Setup guide – Supabase + env + “fresh machine” futtatás

## 🎯 Funkció
Készítsünk **repo-n belüli, kanonikus setup guide-ot**, ami egy teljesen friss gépen is végigvezet:
- Flutter app futtatás (offline és Supabase-szal)
- env fájlok (mi hova kerül, mi van gitignore alatt)
- Supabase local stack indítás + migrációk alkalmazása + SQL contract check futtatás
- “repo gate” futtatás task záráskor (verify + report + log)

Cél: a fejlesztő **ne találgasson**, és **ne közvetlen `flutter ...` parancsokat** használjon, hanem a repo standard wrapper belépési pontjait.

Nem cél:
- Supabase sémamódosítás / migráció írás
- Production/remote DB elérés beállítása CI-ben (a CI lokális Supabase stackkel fut)
- Új build/release pipeline, store deploy

## 🧠 Fejlesztési részletek

### Forrás-igazság a repóban (amit a setup guide-nak követnie kell)
- Flutter wrapper: `scripts/flutter.sh` (Dart define injektálás `app/.env` alapján)
- Minőségkapu: `scripts/check.sh` (pub get + analyze + test)
- Verifikáció + report/log: `scripts/verify.sh` (kötelező task záráskor)
- Supabase wrapper: `scripts/supabase.sh`
- DB contract check runner: `scripts/check_db.sh`
- DB check leírás (már létezik): `docs/qa/db_checks.md`
- Secrets szabályok + wrapper-kötelezettség: `AGENTS.md`
- Gitignore: `.gitignore` (pl. `app/.env`, `.env.local` tiltva van commitra)

### Létrejövő / módosuló fájlok
- Új: `docs/setup/dev_setup.md`
- Új: `docs/setup/supabase_setup.md`
- Mód: `README.md` (link a setup guide-ra)
- Mód: `docs/README.md` (új `setup/` szekció + linkek)
- Mód (kicsi, de fontos): `documents/supabase_configuration.md` (deprecate/átirányítás az új setup guide-ra, és wrapper parancsokra)

### Setup guide tartalmi követelmények (DoD-hoz kötve)
**dev_setup.md:**
- Friss gép lépések: klónozás → Flutter telepítve → `./scripts/flutter.sh doctor` → `./scripts/check.sh`
- App futtatás:
  - Offline mód (kulcs nélkül)
  - Supabase-szal (kulcs `app/.env`-ből, wrapperen át)
- Tesztek futtatása wrapperen át (unit/widget; integration csak ha kell)
- “Task zárás” parancs: `./scripts/verify.sh --report ...`

**supabase_setup.md:**
- Local stack előfeltételek: Docker + Supabase CLI + `psql`
- Local stack indítás és DB reset parancsok (a CI-vel konzisztensen):
  - `./scripts/supabase.sh start`
  - `./scripts/supabase.sh db reset --local --no-seed`
  - `./scripts/check_db.sh`
- `app/.env` kitöltése local Supabase-hoz (a `supabase/config.toml` alapján az API port 54321)
- Rövid troubleshooting (Supabase CLI, Docker, `psql`, portok)

### Kockázatok / megjegyzések
- Kockázat: setup guide “elavul”, ha a scriptek változnak.
  - Kezelés: a guide **minden parancsot a script-ekhez köt** (és ahol lehet, hivatkozik CI workflow-kra: `.github/workflows/ci.yml`, `.github/workflows/ci_db.yml`).
- Kötelező: semmilyen kulcs/titok nem kerülhet a repo-ba (csak `app/.env.example` jellegű sablon létezhet – már van: `app/.env.example`).

### DoD (pipálható)
- [ ] `docs/setup/dev_setup.md` létrejött, és wrapper-parancsokat használ (`./scripts/flutter.sh`, `./scripts/check.sh`, `./scripts/verify.sh`).
- [ ] `docs/setup/supabase_setup.md` létrejött, és a local Supabase lépései konzisztensen a CI-vel: start + `db reset --local --no-seed` + `./scripts/check_db.sh`.
- [ ] A guide egyértelműen rögzíti: `app/.env` és `.env.local` **gitignored**, kulcs nem commitolható.
- [ ] `README.md` + `docs/README.md` hivatkozik az új setup guide-ra.
- [ ] `documents/supabase_configuration.md` elején deprecate/átirányítás szerepel az új `docs/setup/*` fájlokra (és wrapper kötelezettségre).
- [ ] Task zárás: repo gate lefut és rögzítve van:  
  `./scripts/verify.sh --report codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`

## 🧪 Tesztállapot
- Kötelező task zárás (report+log miatt):  
  `./scripts/verify.sh --report codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`
- Opcionális (setup guide validálás, ha van Docker+CLI):  
  `./scripts/supabase.sh start`  
  `./scripts/supabase.sh db reset --local --no-seed`  
  `./scripts/check_db.sh`

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `AGENTS.md` (wrapper + secrets szabályok)
- `.gitignore` (pl. `app/.env`, `.env.local`)
- `scripts/flutter.sh`, `scripts/check.sh`, `scripts/verify.sh`
- `scripts/supabase.sh`, `scripts/check_db.sh`
- `docs/qa/db_checks.md`
- `.github/workflows/ci.yml`, `.github/workflows/ci_db.yml`
- `supabase/config.toml`
- `app/.env.example`
