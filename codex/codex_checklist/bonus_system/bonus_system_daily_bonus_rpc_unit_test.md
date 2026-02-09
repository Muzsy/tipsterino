# Bonus system daily bonus RPC unit test checklist

## P0 - Canvas + cel
- [x] Letrejott / frissult a canvas: `canvases/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`.

## P1 - daily_bonus_rpc seam refaktor
- [x] `dailyBonusRpcRawCallerProvider` bevezetve a `daily_bonus_rpc.dart` fajlban.
- [x] A `dailyBonusRpcCallerProvider` a raw caller providerbol dolgozik.
- [x] Viselkedes valtozatlan: `null` raw valasz `DailyBonusReason.notConfigured` eredmenyre fut.

## P2 - Celozott unit teszt
- [x] Letrejott: `app/test/unit/daily_bonus_rpc_provider_test.dart`.
- [x] Lefedett esetek: granted + amount + next_eligible_at parse.
- [x] Lefedett esetek: already_claimed_today, disabled, null -> notConfigured.

## P3 - Dokumentacio
- [x] `docs/core_logic/daily_bonus.md` kiegeszitve a konkret unit teszt file path-javal.

## P4 - Codex artefaktok
- [x] Letrejott: `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`.
- [x] Letrejott: `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`.

## P5 - Repo gate + report
- [x] Repo gate lefutott: `./scripts/verify.sh --report codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`.
- [x] Letrejott verify log: `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log`.
