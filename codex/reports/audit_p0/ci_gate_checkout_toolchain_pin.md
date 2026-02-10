**PASS** - CI checkout es toolchain pineles elkeszult, verify gate PASS.

## 1) Meta
- **Task slug:** `ci_gate_checkout_toolchain_pin`
- **Kapcsolodo canvas:** `canvases/audit_p0/ci_gate_checkout_toolchain_pin.md`
- **Kapcsolodo goal YAML:** `codex/goals/canvases/audit_p0/fill_canvas_ci_gate_checkout_toolchain_pin.yaml`
- **Futas datuma:** 2026-02-10
- **Branch / commit:** `main@29e637d`
- **Fokusz terulet:** CI + docs

## 2) Scope
### 2.1 Cel
- Lebego checkout/toolchain referenciak megszuntetese determinisztikus CI gate-hez.
- Flutter es Supabase CLI verzio explicit pinelese.
- QA dokumentacio frissitese a valasztott pin listaval es upgrade policyval.

### 2.2 Nem-cel (explicit)
- pipeline redesign.
- uj release pipeline.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p0/ci_gate_checkout_toolchain_pin.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `codex/codex_checklist/audit_p0/ci_gate_checkout_toolchain_pin.md`
- `codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

### 3.2 Miert valtoztak?
- A workflow-kban `actions/checkout@v6`, `channel: stable` es `version: latest` driftelhet, emiatt a CI nem determinisztikus.
- A javitas explicit pinelt verziokra allt, a doksi pedig rogzitett pin listat es kontrollalt upgrade policyt kapott.

### 3.3 Valasztott pinelt verziok
- `actions/checkout@v4.2.2`
- `subosito/flutter-action@v2` + `flutter-version: 3.38.7`
- `supabase/setup-cli@v1` + `version: 2.65.5`

### 3.4 Upgrade policy (rovid)
- Tilos `latest` es lebego major checkout tag hasznalata CI toolchainhez.
- Verzios emeles dedikalt PR-ben, kicsi lepesekben (egy tool/egy bump), kotelezo gate futtatassal.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh --version` (valos Flutter pin forras)
- `supabase --version` (valos Supabase CLI pin forras)

### 4.3 Eredmeny roviden
- Verify gate PASS (`check.sh` analyze + teljes tesztfutas PASS).

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `ci.yml` es `ci_db.yml` nem hasznal lebego checkout taget | PASS | `.github/workflows/ci.yml:23` | Mindket workflow checkout lepes fix `actions/checkout@v4.2.2` referenciat hasznal. | `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` |
| Flutter action/csatorna explicit pinelt (nem driftelo) | PASS | `.github/workflows/ci.yml:28` | A `channel: stable` helyett explicit `flutter-version: 3.38.7` kerult beallitasra. | `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` |
| Supabase CLI verzio explicit pinelt (`latest` helyett) | PASS | `.github/workflows/ci_db.yml:34` | A `supabase/setup-cli@v1` setup mar `version: 2.65.5` erteket hasznal. | `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` |
| docs/qa oldalon dokumentalt a valasztott pin es frissitesi policy | PASS | `docs/qa/db_checks.md:32` | A doksi tartalmazza a pin listat es kulon upgrade policy szekciot drifttilalommal es gate-kovetelmennyel. | `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` |
| verify gate futas dokumentalva | PASS | `codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md:77` | Az AUTO_VERIFY blokkban a verify futas ideje, parancsa, eredmenye es log path rogzitve van. | `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md` |

## 8) Advisory notes (nem blokkolo)
- A pinelt verziok idovel elavulhatnak; havi/ketheti review javasolt dedikalt upgrade PR-ral.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T18:48:31+01:00 → 2026-02-10T18:49:12+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.verify.log`
- git: `main@29e637d`
- módosított fájlok (git status): 7

**git diff --stat**

```text
 .github/workflows/ci.yml                           |  4 +-
 .github/workflows/ci_db.yml                        |  6 +-
 .../audit_p0/ci_gate_checkout_toolchain_pin.md     |  6 ++
 .../audit_p0/ci_gate_checkout_toolchain_pin.md     | 16 ++---
 .../audit_p0/ci_gate_checkout_toolchain_pin.md     | 68 ++++++++++++++++++----
 docs/qa/db_checks.md                               | 14 ++++-
 6 files changed, 88 insertions(+), 26 deletions(-)
```

**git status --porcelain (preview)**

```text
 M .github/workflows/ci.yml
 M .github/workflows/ci_db.yml
 M canvases/audit_p0/ci_gate_checkout_toolchain_pin.md
 M codex/codex_checklist/audit_p0/ci_gate_checkout_toolchain_pin.md
 M codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md
 M docs/qa/db_checks.md
?? codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.verify.log
```

<!-- AUTO_VERIFY_END -->
