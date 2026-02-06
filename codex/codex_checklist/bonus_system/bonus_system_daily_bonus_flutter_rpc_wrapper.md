# Bonus system daily bonus Flutter RPC wrapper checklist

## P1 – Canvas + terv
- [x] A daily bonus Flutter RPC wrapper canvas felsorolja a domain modell, az RPC wrapper és a kapcsolódó unit teszt igényét; a mintákat a signup bónusz domain és RPC fájlokból vettük.

## P2 – Implementációs blokkok
- [x] `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart` tartalmazza a `DailyBonusReason` enumot, a `DailyBonusGrantResult` osztályt, az `fromJson` logikát és a `notConfigured` konstruktorát.
- [x] `app/lib/src/features/rewards/data/daily_bonus_rpc.dart` elérhetővé teszi a `dailyBonusRpcCallerProvider`-t, amely guardolja a `supabaseConfigProvider`-t és a `grant_daily_bonus_if_eligible()` RPC-t hívja mappolva a JSON-t.
- [x] `app/test/unit/daily_bonus_grant_result_test.dart` ellenőrzi a JSON parsingot (null/mapping/next_eligible_at) és a provider guardot (konfig nélküli esetben notConfigured eredmény).

## P3 – QA kapu
- [x] `./scripts/check.sh` – PASS (analyze + widget/unit tesztek).
