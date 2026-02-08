# FILE: canvases/ci/dependabot_config.md

# P1-5: Dependabot – .github/dependabot.yml bevezetése (Flutter + GitHub Actions)

## 🎯 Funkció
Cél: bevezetni a Dependabot konfigurációt, hogy automatikusan jöjjenek PR-ek:
- **GitHub Actions** dependency frissítésekre
- **Dart/Flutter (pub)** dependency frissítésekre az `app/` könyvtárban

Nem cél:
- Dependabot automerge policy (külön döntés / branch protection hiányában nem automatizáljuk).
- CI szabályok átalakítása.
- Függőségek tényleges frissítése ebben a taskban (csak a config).

## 🧠 Fejlesztési részletek

### Repo belépési pontok / érintett komponensek
- Flutter app gyökér: `app/`
  - pub definíció: `app/pubspec.yaml`
  - lock: `app/pubspec.lock`
- GitHub Actions workflow-k: `.github/workflows/*.yml`
- A repo gate jelenleg: `.github/workflows/ci.yml` → `./scripts/check.sh` (csak a PR-ekre futó ellenőrzés)

### Dependabot policy (javasolt minimum)
Két update blokk:

1) **GitHub Actions**
- package-ecosystem: `github-actions`
- directory: `/`
- schedule: `weekly` (hétfő)
- open-pull-requests-limit: 10

2) **Pub (Dart/Flutter)**
- package-ecosystem: `pub`
- directory: `/app`
- schedule: `weekly`
- ignore:
  - major bumpok opcionálisan (ha a repo tipikusan stabilitást preferál) — ebben a taskban csak minimum setup, ignore nélkül.

Címkézés:
- labels: `dependencies`, plusz célzott: `ci` (actions), `flutter` (pub)

Commit message prefix:
- `deps:` vagy `chore(deps):` (csak ha a repo-ban van preferencia; ha nincs, hagyjuk defaulton)

### DoD (pipálható)
- [ ] Létrejön `.github/dependabot.yml`
- [ ] Tartalmazza a `github-actions` weekly update-et root directory-val (`/`)
- [ ] Tartalmazza a `pub` weekly update-et az `app/` directory-ra (`/app`)
- [ ] Beállítja a label-eket (min. `dependencies`)
- [ ] Codex checklist + report váz elkészül:
  - `codex/codex_checklist/ci/dependabot_config.md`
  - `codex/reports/ci/dependabot_config.md`
- [ ] Task zárás (verify + log):
  - `./scripts/verify.sh --report codex/reports/ci/dependabot_config.md`
  - log: `codex/reports/ci/dependabot_config.verify.log`

## 🧪 Tesztállapot
Kötelező task zárás:
- `./scripts/verify.sh --report codex/reports/ci/dependabot_config.md`

Megjegyzés: Dependabot működését a repo-ban nem lehet lokál “tesztelni”; a verify a repo standard gate-et igazolja.

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `.github/workflows/ci.yml`
- `scripts/check.sh`
- `app/pubspec.yaml`
- `AGENTS.md` (repo szabályok)
- `docs/codex/report_standard.md`
