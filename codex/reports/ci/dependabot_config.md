**PASS** - Dependabot konfiguracio kesz, verify es check gate zold.

## 1) Meta
* **Task slug:** `dependabot_config`
* **Kapcsolodo canvas:** `canvases/ci/dependabot_config.md`
* **Kapcsolodo goal YAML:** `codex/goals/canvases/ci/fill_canvas_dependabot_config.yaml`
* **Futas datuma:** 2026-02-08
* **Branch / commit:** `main@23d356d`
* **Fokusz terulet:** CI

## 2) Scope
### 2.1 Cel
1. Dependabot bevezetese GitHub Actions es pub dependency update-ekre.
2. Heti automatikus update policy rogzitese root es app directory-re.
3. Label alapok beallitasa Dependabot PR-ekhez.

### 2.2 Nem-cel (explicit)
1. Dependabot automerge policy bevezetese.
2. Dependency frissitesek tenyleges vegrehajtasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
* `.github/dependabot.yml`
* `codex/codex_checklist/ci/dependabot_config.md`
* `codex/reports/ci/dependabot_config.md`
* `codex/reports/ci/dependabot_config.verify.log`

### 3.2 Miert valtoztak?
* A repo most kapott minimalis, mukodo Dependabot v2 konfiguraciot.
* A CI es Flutter/pub update PR-ek rendszeres, label-ezett formaban erkeznek.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
* `./scripts/verify.sh --report codex/reports/ci/dependabot_config.md`

### 4.2 Opcionlis, feladatfuggo parancsok
* `./scripts/check.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| Letrejott `.github/dependabot.yml` | PASS | `.github/dependabot.yml:1` | A Dependabot v2 konfiguracio fajl letrejott. | Doksi/konfig ellenorzes |
| `github-actions` weekly update root directory-val | PASS | `.github/dependabot.yml:3` | A blokk root (`/`) directory-ra heti schedule-lel konfiguralt. | Konfig ellenorzes |
| `pub` weekly update `/app` directory-val | PASS | `.github/dependabot.yml:12` | A pub update blokk az app gyokerre (`/app`) mutat. | Konfig ellenorzes |
| Label-ek beallitva (`dependencies`) | PASS | `.github/dependabot.yml:8` | Mindket blokk tartalmazza a `dependencies` labelt. | Konfig ellenorzes |
| Checklist + report vaz letrejott | PASS | `codex/codex_checklist/ci/dependabot_config.md:1` | A task artefaktok letrejottek a CI area alatt. | Doksi ellenorzes |
| Repo gate lefutott es log mentve | PASS | `codex/reports/ci/dependabot_config.verify.log:1` | A verify futas PASS, a log letrejott es az AUTO_VERIFY blokk frissult. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
* A Dependabot PR-ek merge policyjat erdemes branch protectionnel kulon formalizalni.

## 9) Follow-ups (opcionalis)
* Nincs kotelezo follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-09T00:34:34+01:00 → 2026-02-09T00:35:15+01:00 (41s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/ci/dependabot_config.verify.log`
- git: `main@23d356d`
- módosított fájlok (git status): 12

**git diff --stat**

```text
 docs/localization/localization_logic.md | 1 +
 1 file changed, 1 insertion(+)
```

**git status --porcelain (preview)**

```text
 M docs/localization/localization_logic.md
?? .github/dependabot.yml
?? app/test/unit/l10n_key_parity_test.dart
?? canvases/ci/dependabot_config.md
?? canvases/localization/
?? codex/codex_checklist/ci/dependabot_config.md
?? codex/codex_checklist/localization/
?? codex/goals/canvases/ci/fill_canvas_dependabot_config.yaml
?? codex/goals/canvases/localization/
?? codex/reports/ci/dependabot_config.md
?? codex/reports/ci/dependabot_config.verify.log
?? codex/reports/localization/
```

<!-- AUTO_VERIFY_END -->
