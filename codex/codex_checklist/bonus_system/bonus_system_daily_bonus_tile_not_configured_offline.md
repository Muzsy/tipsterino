# Bonus system daily bonus tile not configured/offline checklist

## P1 – Preflight
- [x] Confirmed `DailyBonusTile` only looked at claim state/states previously and did not guard the CTA when Supabase was unconfigured or an RPC error happened.
- [x] Checked `supabaseConfigProvider` to understand the `isConfigured` flag so we can prevent claims when it is `false`.

## P2 – Implementation
- [x] `DailyBonusTile` now reads `supabaseConfigProvider`, disables CTA when not configured, surfaces `daily_bonus_body_not_configured`, and still honours running/claimed/blocked reason priorities.
- [x] When `lastError != null` and Supabase is configured, the tile shows `daily_bonus_body_offline`, the CTA label switches to `daily_bonus_cta_retry`, and the retry button reuses the existing `claim()` call.
- [x] Added the `daily_bonus_body_not_configured`, `daily_bonus_body_offline`, and `daily_bonus_cta_retry` localization keys plus the generated getters in `app_localizations*.dart`.
- [x] Extended `daily_bonus_tile_test.dart` with not-configured/online overrides to assert the new copy, disabled CTA, and retry button.

## P3 – QA gate
- [x] `./scripts/check.sh`
