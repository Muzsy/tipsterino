# Bonus system daily bonus amount activation checklist

## P1 – Preflight
- [x] A canvas rögzítette, hogy a `reward_definitions` jelenleg amount=0 mellett van seedelve, ezért a `daily_bonus` RPC “disabled” ágra esik.

## P2 – Implementation
- [x] Új migráció létrejött (`20260211000000_bonus_system_daily_bonus_amount_activation.sql`), amely `daily_bonus` esetén amount=50 és enabled=true értékeket ír INSERT ... ON CONFLICT UPDATE mintával.
- [x] A `documents/bonus_system/daily_bonus.md` Reward definition szakasza rögzíti, hogy az induló amount 50 TippCoin és a 20260211000000-as migráció tartja karban.

## P3 – QA gate
- [x] `./scripts/check.sh`
