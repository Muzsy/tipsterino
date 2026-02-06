# Bonus system daily bonus home tile claim flow checklist

## P1 – Canvas + preflight
- [x] `canvases/bonus_system/bonus_system_daily_bonus_home_tile_claim_flow.md` documents the manual claim-only home tile behavior plus the RPC-based grant rules and localized copy requirements.
- [x] Checked `app/lib/src/screens/home_screen.dart` and the rewards RPC/domain files to confirm there was no existing auto-claim hook before adding the new UI.

## P2 – Implementation
- [x] Added `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart` with the declared state, `isClaimedNow` helper, and a `claim()` that calls `dailyBonusRpcCallerProvider` without auto-running.
- [x] Implemented `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart` that renders localized copy, handles running/claimed/blocked states, enables the CTA only when available, and shows a snackbar on success.
- [x] Updated `app/lib/src/screens/home_screen.dart` so authenticated users now see a column with `DailyBonusTile` plus the existing placeholder text.
- [x] Added the `daily_bonus_*` keys to `app/lib/l10n/app_en.arb` and `app/lib/l10n/app_hu.arb` and wired them into the generated localization classes.
- [x] Created `app/test/widget/daily_bonus_tile_test.dart` covering the default, claimed, and disabled states via provider overrides.

## P3 – QA gate
- [x] `./scripts/check.sh`
