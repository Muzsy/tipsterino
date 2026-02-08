# Dependabot config checklist

## P0 - Canvas + cel
- [x] Letrejott / frissult a canvas: `canvases/ci/dependabot_config.md`.

## P1 - Dependabot config
- [x] Letrejott `.github/dependabot.yml`.
- [x] Van `github-actions` weekly update root (`/`) directory-val.
- [x] Van `pub` weekly update `app` (`/app`) directory-val.
- [x] Label-ek beallitva (minimum: `dependencies`).

## P2 - Codex artefaktok
- [x] Letrejott: `codex/codex_checklist/ci/dependabot_config.md`.
- [x] Letrejott: `codex/reports/ci/dependabot_config.md`.

## P3 - Repo gate + report
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/ci/dependabot_config.md`.
- [x] Letrejott verify log: `codex/reports/ci/dependabot_config.verify.log`.
