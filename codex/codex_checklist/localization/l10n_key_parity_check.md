# L10n key parity check checklist

## P0 - Canvas + cel
- [x] Letrejott / frissult a canvas: `canvases/localization/l10n_key_parity_check.md`.

## P1 - Unit parity teszt
- [x] Letrejott: `app/test/unit/l10n_key_parity_test.dart`.
- [x] A teszt ellenorzi a key set parity-t (EN/HU).
- [x] A teszt ellenorzi az arva meta kulcsokat.
- [x] A teszt ellenorzi a placeholder parity-t.

## P2 - Dokumentacio
- [x] `docs/localization/localization_logic.md` kiegeszitve parity teszt hivatkozassal.

## P3 - Codex artefaktok
- [x] Letrejott: `codex/codex_checklist/localization/l10n_key_parity_check.md`.
- [x] Letrejott: `codex/reports/localization/l10n_key_parity_check.md`.

## P4 - Repo gate + report
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/localization/l10n_key_parity_check.md`.
- [x] Letrejott verify log: `codex/reports/localization/l10n_key_parity_check.verify.log`.
