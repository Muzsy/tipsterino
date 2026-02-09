# Migration rollback strategy playbook

Ez a playbook a Supabase migration incidentek kezelesere ad egyseges dontesi fat es lepesrendet.
A cel a gyors helyreallitas minimalis kockazattal, majd a determinisztikus repo gate visszazolditese.

## 1) Incident osztalyozas

Eloszor allapitsd meg, melyik kornyezet erintett:
- `local`: fejlesztoi gep, local Supabase stack.
- `stage`: pre-production/staging kornyezet.
- `prod`: eles kornyezet.

Masodik lepes: hatas merteke:
- `schema break`: migration hiba miatt sema vagy funkcio elerhetetlen.
- `data integrity risk`: hibas adat iras/torles veszelye.
- `non-blocking`: kisebb regresszio, van biztonsagos forward-fix.

## 2) Decision tree (rollback vs forward-fix)

1. Ha `prod` es `data integrity risk`, akkor rollback azonnal + incident kommunikacio.
2. Ha `prod` es nincs adatvesztesi kockazat, preferalt a gyors `forward-fix`, rollback csak ha a fix nem biztonsagos.
3. Ha `stage`, rollback akkor, ha a pipeline-t blokkolja; kulonben forward-fix.
4. Ha `local`, preferalt a tiszta ujraepites (`db reset --local --no-seed`) es uj migration.

Rovid szabaly:
- visszafordithatatlan adatmuvelet gyanunel: rollback.
- tisztan sema/constraint regresszional, ha gyorsan javithato: forward-fix.

## 3) Local rollback runbook

1. Allapot felmeres:
   - `./scripts/supabase.sh status`
2. Stack futtatasa (ha kell):
   - `./scripts/supabase.sh start`
3. Biztonsagos ujraepites migrationokkal:
   - `./scripts/supabase.sh db reset --local --no-seed`
4. SQL contract gate:
   - `./scripts/check_db.sh`
5. Repo gate reporttal:
   - `./scripts/verify.sh --report codex/reports/<area>/<task>.md`

## 4) Stage rollback runbook

1. Incident freeze: migration deploy stop.
2. Elotte kotelezo:
   - aktualis backup/snapshot ellenorzes.
   - erintett migration azonositas.
3. Vegrehajtas:
   - rollback migration vagy kontrollalt restore az uzemeltetesi policy szerint.
4. Utolagos gate:
   - stage SQL check suite futtatasa.
   - app smoke/regression futas.
   - task report frissitese bizonyitekokkal.

## 5) Prod rollback runbook

1. Incident commander kijelolese, valtozas-stop.
2. Kotelezo approval gate:
   - backup visszaallithatosag validalva.
   - rollback terv ket szem elvvel jovahagyva.
3. Vegrehajtas:
   - rollback migration vagy restore, rovid downtime ablakkal ha szukseges.
4. Post-rollback validacio:
   - kritikus SQL/RPC ellenorzesek.
   - auth + core user flow smoke.
   - monitorozas (error rate, latency) stabilizalodasig.

## 6) Kotelezo verifikacio minden rollback utan

Minimum checklist:
- `db reset`/helyreallitas sikeres (kornyezet-specifikusan).
- SQL contract check zold (`./scripts/check_db.sh` localon).
- repo gate zold (`./scripts/verify.sh --report ...`) local fejlesztoi validaciohoz.
- reportban benne van:
  - dontesi ag (rollback vagy forward-fix) indoklasa,
  - futtatott parancsok,
  - PASS/FAIL eredmenyek.

## 7) Dokumentacios kovetelmeny incident utan

- Frissitsd a relevans reportot `DoD -> Evidence Matrix` bizonyitekokkal.
- Ha a rollback uj tanulsagot adott, frissitsd:
  - `docs/setup/supabase_setup.md`
  - `docs/qa/db_checks.md`
  - ezt a playbookot.
