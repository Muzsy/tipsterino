**PASS_WITH_NOTES** - a bonus RPC integration suite `rate_limited` branch lefedese es CI izolacio elkeszult, a feladat fizikai eszkoz + lokalis Supabase override futassal verifikalva.

## 1) Meta
- **Task slug:** bonus_rpc_integration_rate_limit_branch
- **Kapcsolodo canvas:** canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_rate_limit_branch.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (working tree)
- **Fokusz terulet:** Integration + CI

## 2) Scope
### 2.1 Cel
- Bonus RPC integration suite bovitese explicit `rate_limited` branch ellenorzessel.
- CI-ben izolalt core + rate-limit futasi sorrend bevezetese.
- QA guideline frissitese az uj integration elvarasokkal.

### 2.2 Nem-cel (explicit)
- Bonus limiter SQL parameter tuning.
- Signup email-flow redesign.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md`
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `codex/codex_checklist/audit_p1/bonus_rpc_integration_rate_limit_branch.md`
- `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

### 3.2 Miert valtoztak?
- Az integration teszt kulon esetben ellenorzi a `rate_limited` reason agat gyors egymas utani RPC hivasokkal.
- A CI DB workflow kulon stepben futtatja a core reason es a rate-limit branch integration futast.
- A teszt kapott `IT_SUPABASE_URL` / `IT_SUPABASE_ANON_KEY` override tamogatast, hogy fizikai eszkozrol is deterministicen lehessen lokalis Supabase-re futtatni a wrapper `.env` feluliras nelkul.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancsok
- `./scripts/check_db.sh` -> PASS
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md` -> PASS

### 4.2 Task-specifikus integration futas
- Fizikai eszkoz (Android) + local Supabase (adb reverse) PASS:
  - `adb reverse tcp:54321 tcp:54321`
  - `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d GAB7N18604000884 --dart-define=IT_SUPABASE_URL=http://127.0.0.1:54321 --dart-define=IT_SUPABASE_ANON_KEY=... --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=... --dart-define=BONUS_RATE_LIMIT_TEST_EMAIL=... --dart-define=BONUS_RATE_LIMIT_TEST_PASSWORD=...`
  - Teszt userek admin provisioningnel (`/auth/v1/admin/users`) lettek elore letrehozva `user_metadata.nickname` + `user_metadata.avatar_key` mezokkel; enelkul a projekt trigger 500 hibara futna.

### 4.3 Eredmeny roviden
- DB contract check zold.
- Fizikai eszkoz integration futasban mindket teszt eset zold:
  - `Signup and daily bonus RPC reasons stay deterministic`
  - `Bonus RPC rate_limited branch stays deterministic`
- Repo gate zold (`verify.sh`, benne `check.sh`).

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| integration teszt explicit ellenorzi legalabb egy bonus RPC `rate_limited` reason agatat | PASS | `app/integration_test/bonus_rpc_integration_test.dart:76`, `app/integration_test/bonus_rpc_integration_test.dart:89`, `app/integration_test/bonus_rpc_integration_test.dart:104` | Kulon teszt 6 gyors `grant_signup_bonus_if_eligible` hivasbol ellenorzi a `rate_limited` reason megjeleneset. | Fizikai eszkoz integration futas (4.2) |
| a rate-limit scenariot izolalt futasi modban kezeli a CI (kulon step/job vagy egyertelmu sorrend) | PASS | `.github/workflows/ci_db.yml:214`, `.github/workflows/ci_db.yml:221` | A workflow kulon stepben futtatja a core reason es a rate-limit branch futast `--plain-name` filterrel. | CI workflow review |
| teszt determinisztikus: nem signup email kuldesi limitre tamaszkodik | PASS | `.github/workflows/ci_db.yml:125`, `.github/workflows/ci_db.yml:141`, `app/integration_test/bonus_rpc_integration_test.dart:23`, `docs/qa/testing_guidelines.md:95` | CI-ben dedikalt, elore provisionalt userek vannak; lokalis/fizikai futashoz az `IT_SUPABASE_*` override explicit local stackre mutat. | Fizikai eszkoz integration futas (4.2) |
| reportban kulon evidence van a rate-limit branch futasrol | PASS | `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md:40`, `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md:52` | Kulon szekcioban szerepel a rate-limit branch futasi parancs es a PASS eredmeny. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- A Linux desktop integration futashoz a host linker/toolchain (`ld`/`ld.lld`) jelenlete tovabbra is feltetel; a fizikai Android futas ezt megkeruli.

## 9) Follow-ups
- Opcionális: `scripts/flutter.sh` kapjon kapcsolot (`NO_ENV_DART_DEFINES=1`), hogy integration futasnal ne kelljen workaround define neveket hasznalni.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T20:12:04+01:00 → 2026-02-10T20:13:13+01:00 (69s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.verify.log`
- git: `main@d56ba88`
- módosított fájlok (git status): 7

**git diff --stat**

```text
 .github/workflows/ci_db.yml                        | 123 ++++++++------
 .../bonus_rpc_integration_test.dart                | 177 ++++++++++++++++-----
 .../bonus_rpc_integration_rate_limit_branch.md     |   5 +
 .../bonus_rpc_integration_rate_limit_branch.md     |  12 +-
 .../bonus_rpc_integration_rate_limit_branch.md     |  86 +++++++---
 docs/qa/testing_guidelines.md                      |  14 +-
 6 files changed, 299 insertions(+), 118 deletions(-)
```

**git status --porcelain (preview)**

```text
 M .github/workflows/ci_db.yml
 M app/integration_test/bonus_rpc_integration_test.dart
 M canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md
 M codex/codex_checklist/audit_p1/bonus_rpc_integration_rate_limit_branch.md
 M codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md
 M docs/qa/testing_guidelines.md
?? codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.verify.log
```

<!-- AUTO_VERIFY_END -->
