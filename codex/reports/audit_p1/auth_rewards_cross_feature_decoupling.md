**FAIL** - Scaffold only; implementacio es verifikacio nem futott ebben a korben.

## 1) Meta
- **Task slug:** auth_rewards_cross_feature_decoupling
- **Kapcsolodo canvas:** canvases/audit_p1/auth_rewards_cross_feature_decoupling.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_auth_rewards_cross_feature_decoupling.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (scaffold)
- **Fokusz terulet:** Architecture + State

## 2) Scope
### 2.1 Cel
- auth↔rewards kozvetlen coupling csokkentese.
- app/startup orchestrator bevezetese post-auth init triggerelesre.
- feature public API (barrel) mintak formalizalasa.

### 2.2 Nem-cel (explicit)
- auth flow UI valtoztatas.
- bonus RPC domain szabalyok valtoztatasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
- `canvases/audit_p1/auth_rewards_cross_feature_decoupling.md`
- `app/lib/src/app/startup/post_auth_startup_provider.dart`
- `app/lib/src/features/auth/presentation/state/auth_provider.dart`
- `app/lib/src/features/auth/auth.dart`
- `app/lib/src/features/rewards/rewards.dart`
- `app/lib/src/features/home/presentation/screens/home_screen.dart`
- `app/test/unit/bonus_system_post_auth_init_test.dart`
- `app/test/unit/post_auth_startup_provider_test.dart`
- `docs/architect/project_structure.md`
- `docs/core_logic/registration_flow.md`
- `codex/codex_checklist/audit_p1/auth_rewards_cross_feature_decoupling.md`
- `codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md`

### 3.2 Miert valtoztak?
- P1 cross-feature decoupling scope konkretizalasa.
- Implementacios outputok felbontasa startup, feature API es teszt szintekre.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md`

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/bonus_system_post_auth_init_test.dart test/unit/post_auth_startup_provider_test.dart test/widget/guest_routing_shells_test.dart`

### 4.3 Eredmeny roviden
- Ebben a korben scaffold keszult, verifikacio nem futott.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| az auth feature nem importalja kozvetlenul a rewards belso startup provideret | FAIL | n/a | Implementacio meg nem tortent. | static code review |
| a post-auth init hivas app/startup retegen keresztul tortenik | FAIL | n/a | Implementacio meg nem tortent. | unit test |
| legalabb auth/rewards featurehez van public API barrel es a cross-feature import ezt hasznalja | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/check.sh` |
| unit teszt bizonyitja, hogy a startup orchestrator csak ervenyes sessionnel futtat es hibat nem propagal UI crash-re | FAIL | n/a | Implementacio meg nem tortent. | `./scripts/flutter.sh test ...` |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a scaffold korben.

<!-- AUTO_VERIFY_START -->
Scaffold allapot: verify futas meg nem tortent.
<!-- AUTO_VERIFY_END -->
