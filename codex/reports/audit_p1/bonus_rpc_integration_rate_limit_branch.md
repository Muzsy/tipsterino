**FAIL** - Scaffold only; implementacio es verifikacio nem futott ebben a korben.

## 1) Meta
- **Task slug:** bonus_rpc_integration_rate_limit_branch
- **Kapcsolodo canvas:** canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_bonus_rpc_integration_rate_limit_branch.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (scaffold)
- **Fokusz terulet:** Integration + CI

## 2) Scope
### 2.1 Cel
- bonus RPC integration suite bovitese `rate_limited` branch ellenorzessel.
- izolalt CI futtatasi minta bevezetese a flakiness csokkentesere.
- QA guideline frissites.

### 2.2 Nem-cel (explicit)
- limiter SQL parameterek modositas.
- signup email-flow attervezese.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/bonus_rpc_integration_rate_limit_branch.md`
- `app/integration_test/bonus_rpc_integration_test.dart`
- `.github/workflows/ci_db.yml`
- `docs/qa/testing_guidelines.md`
- `codex/codex_checklist/audit_p1/bonus_rpc_integration_rate_limit_branch.md`
- `codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

### 3.2 Miert valtoztak?
- P1 rate-limit integration branch scope formalizalasa.
- outputok es verifikacios lepesek konkretizalasa a CI gate-hez.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/bonus_rpc_integration_rate_limit_branch.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/check_db.sh`
- `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...`

### 4.3 Eredmeny roviden
- Ebben a korben scaffold keszult, verifikacio nem futott.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| integration teszt explicit ellenorzi legalabb egy bonus RPC `rate_limited` reason agatat | FAIL | n/a | Implementacio meg nem tortent. | integration test |
| a rate-limit scenariot izolalt futasi modban kezeli a CI | FAIL | n/a | Implementacio meg nem tortent. | CI workflow run |
| teszt determinisztikus: nem signup email kuldesi limitre tamaszkodik | FAIL | n/a | Implementacio meg nem tortent. | integration test |
| reportban kulon evidence van a rate-limit branch futasrol | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a scaffold korben.

<!-- AUTO_VERIFY_START -->
Scaffold allapot: verify futas meg nem tortent.
<!-- AUTO_VERIFY_END -->
