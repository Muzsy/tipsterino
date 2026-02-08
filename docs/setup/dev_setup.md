# Dev setup (fresh machine)

Ez a guide egy friss gépes fejlesztői indulást ír le wrapper-alapú parancsokkal.

## 1) Minimum ellenőrzés friss klónozás után
1. Ellenőrizd a Flutter telepítést:
   - `./scripts/flutter.sh doctor`
2. Futtasd a repo standard gate-et:
   - `./scripts/check.sh`

## 2) App futtatás
### 2.1 Offline mód (Supabase kulcsok nélkül)
- Az app futtatható `SUPABASE_URL` / `SUPABASE_ANON_KEY` nélkül is.
- Futtatás:
  - `./scripts/flutter.sh run`

### 2.2 Supabase-szal
- A Supabase értékek compile-time `--dart-define` paramétereken érkeznek.
- A define-okat a wrapper (`scripts/flutter.sh`) adja át a gitignored `app/.env` alapján.
- Futtatás:
  - `./scripts/flutter.sh run`

## 3) Tesztelés
- Gyors helyi gate:
  - `./scripts/check.sh`
- Flutter teszt wrapperrel:
  - `./scripts/flutter.sh test`

## 4) Task zárás (kötelező Codex gate)
- `./scripts/verify.sh --report codex/reports/<area>/<task_slug>.md`

## 5) Secrets és gitignore szabály
- `app/.env` és `.env.local` nem kerülhet gitbe.
- Ne commitolj Supabase kulcsot vagy bármilyen secretet.
