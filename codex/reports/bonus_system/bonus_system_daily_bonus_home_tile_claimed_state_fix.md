## Mit találtunk?
- A `grant_daily_bonus_if_eligible` RPC mindig ad `next_eligible_at`-ot, ezért a kliensnél kell eldönteni, mikor számít valódi “claimed”-nek a tile.
- A jelenlegi `DailyBonusClaimNotifier` cache logikája minden `reason` esetén frissítette a `cachedNextEligibleAt`-ot, így disabled/not_verified/profile_incomplete válasz után is “Claimed” állapotba került a widget.

## Mit módosítottunk?
- `DailyBonusClaimNotifier.claim()` most csak akkor írja felül a `cachedNextEligibleAt`-ot, ha a visszatérési érték `granted` vagy `reason == DailyBonusReason.alreadyClaimedToday`, különben megtartja a korábbi cache-t.
- `DailyBonusClaimState.isClaimedNow` csak akkor tér vissza true-val, ha van jövőbeli `cachedNextEligibleAt`, és a `lastResult.reason` is `granted` vagy `alreadyClaimedToday`.
- Frissítettük `daily_bonus_tile_test.dart`-t: a claimed-state teszt az `alreadyClaimedToday` reason-t használja, a regressziós teszt pedig ellenőrzi, hogy egy disabled response mellett is a “Daily bonus is not active.” szöveg marad, nincs “Claimed” címke, és a CTA tiltott marad.

## Módosított/létrehozott fájlok
- `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_home_tile_claimed_state_fix.md`
- `codex/reports/bonus_system/bonus_system_daily_bonus_home_tile_claimed_state_fix.md`

## Tesztek
- `./scripts/check.sh` – PASS (analyze + unit/widget tesztek)

## Következő javasolt lépések
1. Ha a future cache logikában további reason-ok is befolyásolják a user experience-t, mérlegeljük a `lastResult.reason` explicit loggingját a UI rétegben.
2. Ha a Supabase RPC elkezd változtatni a `next_eligible_at` viselkedésén, érdemes lehet egy client-side guardot (például a grant success flag-et) összekötni egy analytics eseménnyel a regressziók gyors diagnózisához.
