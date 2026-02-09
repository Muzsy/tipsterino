**PASS_WITH_NOTES** - bonus RPC integration suite es CI wiring kesz, check_db es verify PASS, CI-ben deterministic auth user provisioninggel.

## 1) Meta
- **Task slug:** bonus_rpc_integration_suite_ci
- **Kapcsolodo canvas:** canvases/audit_p1/bonus_rpc_integration_suite_ci.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_suite_ci.yaml
- **Futas datuma:** 2026-02-09
- **Branch / commit:** main@234e230
- **Fokusz terulet:** Mixed

## 2) Scope
### 2.1 Cel
- Bonus RPC integration teszt suite letrehozasa valos Supabase local stack ellen.
- CI DB workflow frissitese, hogy DB checks utan bonus RPC integration is lefusson.
- QA guideline frissitese az uj integration kovetelmennyel.

### 2.2 Nem-cel (explicit)
- Bonus uzleti szabalyok modositas.
- Production Supabase infrastruktura modositasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/bonus_rpc_integration_suite_ci.md`
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `codex/codex_checklist/audit_p1/bonus_rpc_integration_suite_ci.md`
- `codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md`

### 3.2 Miert valtoztak?
- Letrejott egy dedikalt, valos RPC reason-kodokat ellenorzo integration teszt.
- A DB CI workflow deterministic sorrendben futtatja a stack resetet, SQL checkeket, CI auth user provisioninget/sign-in validaciot es az integration tesztet.
- A QA doksi explicit rögzíti a bonus RPC integration gate kovetelmenyt.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d GAB7N18604000884`

### 4.3 Eredmeny roviden
- `./scripts/check_db.sh` PASS.
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md` PASS.
- A CI workflow a local stackbol kiolvassa az API/anon/service_role kulcsokat, CI-only auth usert hoz letre, majd sign-innel validalja a credentialt integration futas elott.
- A CI integration futas BONUS_TEST_EMAIL/BONUS_TEST_PASSWORD define-okkal indul, igy nem a signup email kuldesi rate limitre tamaszkodik.
- Lokalis fizikai eszkoz futasnal, ha `app/.env` tavoli projektre mutat, kulon (azonos backendre mutato) BONUS_TEST credential szukseges.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| letezik bonus RPC integration teszt, ami lefedi a signup + daily bonus critical reason kodokat | PASS | `app/integration_test/bonus_rpc_integration_test.dart:9` | A teszt valos auth sessionnel ellenorzi a signup/daily RPC `granted`, `already_granted`, `already_claimed_today` reason-kodokat, es tamogatja a CI-ben beadott BONUS_TEST credentialt. | `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...` |
| a teszt suite CI-ben fut (Supabase local stack + app integration test) | PASS | `.github/workflows/ci_db.yml:201` | A workflow a DB reset + SQL checks utan futtatja az integration tesztet Linuxon, BONUS_TEST define-okkal. | GitHub Actions `CI - DB` |
| a futtatasi sorrend deterministic (db reset -> check_db -> integration) | PASS | `.github/workflows/ci_db.yml:49` | A workflow sorrend explicit: `db reset` -> `check_db` -> CI auth user provision + sign-in validation -> integration test. | GitHub Actions `CI - DB` |
| reportban kulon bizonyitek van az integration futasrol | PASS | `codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md:43` | A report kulon rogziti az integration futas parancsait es lokalis futasi allapotat. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- A lokalis Linux integration futashoz rendszerfuggo build eszkozok kellenek (`ld.lld`), ami fejlesztoi gepenkent elterhet; emiatt a CI workflow explicit telepit build dependency-ket.
- Fizikai eszkoz lokalis futasnal a BONUS_TEST credentialnek ugyanarra a Supabase backendre kell mutatnia, mint amit a `SUPABASE_URL`/`SUPABASE_ANON_KEY` ad.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-09T23:54:41+01:00 → 2026-02-09T23:55:21+01:00 (40s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/bonus_rpc_integration_suite_ci.verify.log`
- git: `main@234e230`
- módosított fájlok (git status): 7

**git diff --stat**

```text
 .github/workflows/ci_db.yml                        | 163 +++++++++++++++++++++
 .../audit_p1/bonus_rpc_integration_suite_ci.md     |   3 +-
 .../audit_p1/bonus_rpc_integration_suite_ci.md     |  13 +-
 .../audit_p1/bonus_rpc_integration_suite_ci.md     |  82 +++++++++--
 docs/qa/testing_guidelines.md                      |   9 ++
 5 files changed, 250 insertions(+), 20 deletions(-)
```

**git status --porcelain (preview)**

```text
 M .github/workflows/ci_db.yml
 M canvases/audit_p1/bonus_rpc_integration_suite_ci.md
 M codex/codex_checklist/audit_p1/bonus_rpc_integration_suite_ci.md
 M codex/reports/audit_p1/bonus_rpc_integration_suite_ci.md
 M docs/qa/testing_guidelines.md
?? app/integration_test/bonus_rpc_integration_test.dart
?? codex/reports/audit_p1/bonus_rpc_integration_suite_ci.verify.log
```

<!-- AUTO_VERIFY_END -->
