**PASS** - daily_bonus_rpc unit teszt kesz, verify es check gate zold.

## 1) Meta
* **Task slug:** `bonus_system_daily_bonus_rpc_unit_test`
* **Kapcsolodo canvas:** `canvases/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
* **Kapcsolodo goal YAML:** `codex/goals/canvases/bonus_system/fill_canvas_bonus_system_daily_bonus_rpc_unit_test.yaml`
* **Futas datuma:** 2026-02-09
* **Branch / commit:** `main@a8f97ed`
* **Fokusz terulet:** Mixed

## 2) Scope
### 2.1 Cel
1. A `daily_bonus_rpc` wrapper tesztelhetosegenek javitasa raw caller seam-mel.
2. Celozott unit teszt a mapping es reason parse esetekre.
3. `next_eligible_at` parse ellenorzes automata tesztben.

### 2.2 Nem-cel (explicit)
1. Supabase RPC SQL vagy adatmodell modositas.
2. UI viselkedes atalakitasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
* `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
* `app/test/unit/daily_bonus_rpc_provider_test.dart`
* `docs/core_logic/daily_bonus.md`
* `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
* `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
* `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log`

### 3.2 Miert valtoztak?
* A nyers RPC caller provider override-olhato unit tesztben, Supabase kliens mock nelkul.
* A wrapper mapping regressziok CI-ben automatikusan lebuknak.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
* `./scripts/verify.sh --report codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`

### 4.2 Opcionlis, feladatfuggo parancsok
* `./scripts/check.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `daily_bonus_rpc.dart` raw caller seam bevezetve | PASS | `app/lib/src/features/rewards/data/daily_bonus_rpc.dart:7` | Uj `DailyBonusRpcRawCaller` tipus es provider hozzaadva. | Kodelenorzes |
| Uj unit teszt letrejott a wrapperre | PASS | `app/test/unit/daily_bonus_rpc_provider_test.dart:1` | Provider override alapu, halozatfuggetlen tesztek. | Unit teszt |
| daily bonus doksi tesztfajl hivatkozas kiegeszitve | PASS | `docs/core_logic/daily_bonus.md:90` | DoD listaban szerepel a konkret RPC wrapper unit teszt. | Doksi ellenorzes |
| Checklist + report letrejott | PASS | `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md:1` | A bonus_system area artefaktok letrejottek. | Doksi ellenorzes |
| Repo gate lefutott es log mentve | PASS | `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log:1` | A verify futas PASS, a log letrejott es az AUTO_VERIFY blokk frissult. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
* Uj `reason` ertek bevezetesenel erdemes bovitett mapper tesztet adni ugyanebbe a fajlba.

## 9) Follow-ups (opcionalis)
* Nincs kotelezo follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-09T18:51:00+01:00 → 2026-02-09T18:51:42+01:00 (42s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log`
- git: `main@a8f97ed`
- módosított fájlok (git status): 8

**git diff --stat**

```text
 app/lib/src/features/rewards/data/daily_bonus_rpc.dart | 16 +++++++++++-----
 docs/core_logic/daily_bonus.md                         |  1 +
 2 files changed, 12 insertions(+), 5 deletions(-)
```

**git status --porcelain (preview)**

```text
 M app/lib/src/features/rewards/data/daily_bonus_rpc.dart
 M docs/core_logic/daily_bonus.md
?? app/test/unit/daily_bonus_rpc_provider_test.dart
?? canvases/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md
?? codex/codex_checklist/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md
?? codex/goals/canvases/bonus_system/fill_canvas_bonus_system_daily_bonus_rpc_unit_test.yaml
?? codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md
?? codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log
```

<!-- AUTO_VERIFY_END -->
