# Bonus system daily bonus home tile claimed-state fix checklist

## P1 – Preflight
- [x] Confirmed the RPC (`grant_daily_bonus_if_eligible`) populates `next_eligible_at` on every branch, so the client must gate caching by reason.
- [x] Reviewed the existing `DailyBonusClaimNotifier` logic and saw `cachedNextEligibleAt` was refreshed regardless of `reason`, which allows disabled/blocked responses to show “Claimed.”

## P2 – Implementation
- [x] Updated `DailyBonusClaimNotifier.claim()` to cache `nextEligibleAt` only when `granted == true` or `reason == DailyBonusReason.alreadyClaimedToday`.
- [x] Tightened `DailyBonusClaimState.isClaimedNow` so it requires a future `cachedNextEligibleAt` while the last `reason` is `granted` or `alreadyClaimedToday`.
- [x] Adjusted `daily_bonus_tile_test.dart`: the claimed-state test now sets `reason = alreadyClaimedToday`, and a new regression case ensures a disabled response with a future `nextEligibleAt` renders the disabled copy (no “Claimed”) and keeps the CTA disabled.

## P3 – QA gate
- [x] `./scripts/check.sh`
