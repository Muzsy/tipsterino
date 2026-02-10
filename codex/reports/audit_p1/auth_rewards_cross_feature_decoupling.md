**PASS** - auth es rewards feature kozti post-auth startup coupling app/startup orchestratoron keresztul lett kivezetve, barrel importokkal es regresszios tesztekkel validalva.

## 1) Meta
- **Task slug:** auth_rewards_cross_feature_decoupling
- **Kapcsolodo canvas:** canvases/audit_p1/auth_rewards_cross_feature_decoupling.md
- **Kapcsolodo goal YAML:** codex/goals/canvases/audit_p1/fill_canvas_auth_rewards_cross_feature_decoupling.yaml
- **Futas datuma:** 2026-02-10
- **Branch / commit:** main (working tree)
- **Fokusz terulet:** Architecture + State

## 2) Scope
### 2.1 Cel
- Auth oldali post-auth startup trigger direct rewards import nelkul tortenjen.
- App-szintu startup orchestrator fogja ossze a session validaciot es a delegaciot.
- Feature public API barrel exportokon keresztul menjenek a cross-feature importok.

### 2.2 Nem-cel (explicit)
- Auth/login/signup UI folyamat valtoztatasa.
- Signup bonus RPC uzleti logikajanak atirasa.

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
- App-startup szinten szet lett valasztva az auth session figyeles es a rewards startup init delegacio.
- Barrel exportokkal megszunt a home/auth oldali deep import mintazat.
- Unit tesztek lefedik a valid session, empty user es error swallow regresszios eseteket.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
- `./scripts/verify.sh --report codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md` -> PASS

### 4.2 Opcionlis, feladatfuggo parancsok
- `./scripts/flutter.sh test test/unit/bonus_system_post_auth_init_test.dart test/unit/post_auth_startup_provider_test.dart test/widget/guest_routing_shells_test.dart` -> PASS

### 4.3 Eredmeny roviden
- Celzott startup regresszios tesztek zoldre futottak.
- Repo gate (`check.sh` a verify scripten keresztul) zold.

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| az auth feature nem importalja kozvetlenul a rewards belso startup provideret | PASS | `app/lib/src/features/auth/presentation/state/auth_provider.dart:9` | Az auth provider mar az app/startup orchestrator providert importalja, rewards belso provider import nincs. | `./scripts/check.sh` |
| a post-auth init hivas app/startup retegen keresztul tortenik | PASS | `app/lib/src/features/auth/presentation/state/auth_provider.dart:101`, `app/lib/src/app/startup/post_auth_startup_provider.dart:40` | Az AuthNotifier `postAuthStartupProvider`-t hiv, amely a runneren at delegal a rewards `postAuthInitProvider` fele. | `./scripts/flutter.sh test test/unit/post_auth_startup_provider_test.dart` |
| legalabb auth/rewards featurehez van public API barrel es a cross-feature import ezt hasznalja | PASS | `app/lib/src/features/auth/auth.dart:1`, `app/lib/src/features/rewards/rewards.dart:1`, `app/lib/src/features/home/presentation/screens/home_screen.dart:6` | Letrejott mindket feature barrel exportja, a HomeScreen mar ezekbol importal, nem belso file pathrol. | `./scripts/check.sh` |
| unit teszt bizonyitja, hogy a startup orchestrator csak ervenyes sessionnel futtat es hibat nem propagal UI crash-re | PASS | `app/test/unit/post_auth_startup_provider_test.dart:33`, `app/test/unit/post_auth_startup_provider_test.dart:90`, `app/test/unit/post_auth_startup_provider_test.dart:118` | Tesztek fedik a valid futast, empty user skipet, es azt hogy runner hiba allapotban rogzul, de nem dob tovabb. | `./scripts/flutter.sh test test/unit/bonus_system_post_auth_init_test.dart test/unit/post_auth_startup_provider_test.dart test/widget/guest_routing_shells_test.dart` |

## 8) Advisory notes (nem blokkolo)
- Nincs advisory note a task scope-on belul.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-10T19:25:15+01:00 → 2026-02-10T19:25:57+01:00 (42s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.verify.log`
- git: `main@c544d4d`
- módosított fájlok (git status): 13

**git diff --stat**

```text
 .../auth/presentation/state/auth_provider.dart     |  9 +--
 .../home/presentation/screens/home_screen.dart     | 72 +++++++++++-----------
 .../unit/bonus_system_post_auth_init_test.dart     | 66 +++++++++++++++++---
 .../auth_rewards_cross_feature_decoupling.md       |  5 ++
 .../auth_rewards_cross_feature_decoupling.md       | 14 ++---
 .../auth_rewards_cross_feature_decoupling.md       | 41 ++++++------
 docs/architect/project_structure.md                |  4 ++
 docs/core_logic/registration_flow.md               |  2 +-
 8 files changed, 135 insertions(+), 78 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/features/auth/presentation/state/auth_provider.dart
 M app/lib/src/features/home/presentation/screens/home_screen.dart
 M app/test/unit/bonus_system_post_auth_init_test.dart
 M canvases/audit_p1/auth_rewards_cross_feature_decoupling.md
 M codex/codex_checklist/audit_p1/auth_rewards_cross_feature_decoupling.md
 M codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.md
 M docs/architect/project_structure.md
 M docs/core_logic/registration_flow.md
?? app/lib/src/app/startup/
?? app/lib/src/features/auth/auth.dart
?? app/lib/src/features/rewards/rewards.dart
?? app/test/unit/post_auth_startup_provider_test.dart
?? codex/reports/audit_p1/auth_rewards_cross_feature_decoupling.verify.log
```

<!-- AUTO_VERIFY_END -->
