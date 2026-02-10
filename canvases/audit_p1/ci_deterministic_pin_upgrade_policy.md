# Audit P1-4: CI deterministic pin + upgrade policy

## 🎯 Funkcio
Celfeladat: teljes CI determinisztika megerositese (workflow pin matrix + upgrade policy), hogy a gate ne drifteljen es rollback egyszeru maradjon.

Nem cel:
- uj CI pipeline tipus bevezetese
- toolchain major upgrade ebben a taskban

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `docs/setup/dev_setup.md`
- `scripts/check.sh`
- `scripts/verify.sh`

Tervezett kimenetek:
- workflow pin frissites/egysegesites: `.github/workflows/ci.yml`, `.github/workflows/ci_db.yml`
- policy doksi frissites: `docs/qa/db_checks.md`, `docs/setup/dev_setup.md`
- (ha szukseges) root setup hivatkozas frissites: `README.md`

DoD:
- [ ] minden workflow action/toolchain pin explicit es dokumentalt
- [ ] nincs lebego `latest`/major-only pin kritikus toolchain komponenseknel
- [ ] docs tartalmazza az upgrade policyt es kotelezo local gate parancsokat (`check.sh`, `check_db.sh`, `verify.sh`)
- [ ] reportban szerepel pin matrix before/after es a verifikacios parancslista

Kockazat/rollback:
- tul szigoruan pinelt verzioknal security fix keshet; rollback policyben dedikalt pin-upgrade PR folyamat kell.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/db_checks.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
