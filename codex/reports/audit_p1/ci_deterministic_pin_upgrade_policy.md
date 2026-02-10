**PASS** - CI workflow runner/action pinek deterministic patch szintre kerultek, es a pin-upgrade policy dokumentalt local gate kovetelmenyekkel.

## 1) Meta
- **Task slug:** ci_deterministic_pin_upgrade_policy
- **Kapcsolodo canvas:** canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_ci_deterministic_pin_upgrade_policy.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (working tree)
- **Fokusz terulet:** CI + Docs

## 2) Scope
### 2.1 Cel
- CI workflow drift csokkentese explicit runner/action pin matrixszal.
- Major-only pin eltavolitasa kritikus workflow toolchain komponensekrol.
- Upgrade policy dokumentalasa kotelezo local gate parancsokkal.

### 2.2 Nem-cel (explicit)
- Uj pipeline tipus vagy uj CI workflow bevezetese.
- Flutter/Supabase toolchain major upgrade.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `codex/codex_checklist/audit_p1/ci_deterministic_pin_upgrade_policy.md`
- `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

### 3.2 Pin matrix (before -> after)
| Workflow | Runner | Flutter action | Supabase setup action | Toolchain value |
| -------- | ------ | -------------- | --------------------- | --------------- |
| `ci.yml` before | `ubuntu-latest` | `subosito/flutter-action@v2` | n/a | `flutter-version: 3.38.7` |
| `ci.yml` after | `ubuntu-24.04` | `subosito/flutter-action@v2.21.0` | n/a | `flutter-version: 3.38.7` |
| `ci_db.yml` before | `ubuntu-latest` | `subosito/flutter-action@v2` | `supabase/setup-cli@v1` | `flutter-version: 3.38.7`, `supabase-cli: 2.65.5` |
| `ci_db.yml` after | `ubuntu-24.04` | `subosito/flutter-action@v2.21.0` | `supabase/setup-cli@v1.6.0` | `flutter-version: 3.38.7`, `supabase-cli: 2.65.5` |

### 3.3 Miert valtoztak?
- A `latest` runner drift helyett explicit LTS runner kerult be mindket workflowba.
- A major-only action tagek helyett explicit patch pin lett, igy a CI viselkedes reprodukalhato.
- A QA/dev setup doksikban formalizalva lett a pin-upgrade PR folyamat es a kotelezo local gate sorrend.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancsok
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md`

### 4.2 Eredmeny roviden
- `./scripts/check.sh` -> PASS.
- `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md` -> PASS (auto blokkban).

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| minden workflow action/toolchain pin explicit es dokumentalt | PASS | `.github/workflows/ci.yml:23`, `.github/workflows/ci.yml:26`, `.github/workflows/ci_db.yml:23`, `.github/workflows/ci_db.yml:26`, `.github/workflows/ci_db.yml:32`, `docs/qa/db_checks.md:45` | A checkout/flutter/supabase setup pinek explicit patch szintu referenciat hasznalnak, es a doksi tartalmazza a kanonikus pin matrixot. | workflow review + `./scripts/check.sh` |
| nincs lebego `latest`/major-only pin kritikus toolchain komponenseknel | PASS | `.github/workflows/ci.yml:18`, `.github/workflows/ci.yml:26`, `.github/workflows/ci_db.yml:18`, `.github/workflows/ci_db.yml:26`, `.github/workflows/ci_db.yml:32` | A runner `ubuntu-24.04` lett, action pinek major-only helyett explicit patch tagekre alltak. | workflow review + `./scripts/check.sh` |
| docs tartalmazza az upgrade policyt es kotelezo local gate parancsokat (`check.sh`, `check_db.sh`, `verify.sh`) | PASS | `docs/qa/db_checks.md:58`, `docs/setup/dev_setup.md:27`, `docs/setup/dev_setup.md:38`, `README.md:28` | QA es setup doksi explicit felsorolja a kotelezo gate parancsokat, a README pedig bekoti a policy doksit. | docs review + `./scripts/check.sh` |
| reportban szerepel pin matrix before/after es a verifikacios parancslista | PASS | `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md:27`, `codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md:46` | A report kulon tablazatban mutatja a before/after pin matrixot es kulon szekcioban a futtatott gate parancsokat. | `./scripts/verify.sh --report codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md` |

## 8) Advisory notes (nem blokkolo)
- Patch pin strategy deterministicebb, de idoszakos (pl. havi) pin bump karbantartast igenyel security fixek gyors atvetelere.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T19:32:10+01:00 → 2026-02-10T19:32:52+01:00 (42s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.verify.log`
- git: `main@9fafbfa`
- módosított fájlok (git status): 9

**git diff --stat**

```text
 .github/workflows/ci.yml                           |  4 +-
 .github/workflows/ci_db.yml                        |  6 +-
 README.md                                          |  1 +
 .../ci_deterministic_pin_upgrade_policy.md         |  5 ++
 .../ci_deterministic_pin_upgrade_policy.md         | 12 +--
 .../ci_deterministic_pin_upgrade_policy.md         | 87 ++++++++++++++++------
 docs/qa/db_checks.md                               | 14 +++-
 docs/setup/dev_setup.md                            | 10 +++
 8 files changed, 102 insertions(+), 37 deletions(-)
```

**git status --porcelain (preview)**

```text
 M .github/workflows/ci.yml
 M .github/workflows/ci_db.yml
 M README.md
 M canvases/audit_p1/ci_deterministic_pin_upgrade_policy.md
 M codex/codex_checklist/audit_p1/ci_deterministic_pin_upgrade_policy.md
 M codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.md
 M docs/qa/db_checks.md
 M docs/setup/dev_setup.md
?? codex/reports/audit_p1/ci_deterministic_pin_upgrade_policy.verify.log
```

<!-- AUTO_VERIFY_END -->
