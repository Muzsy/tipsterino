## Mit találtunk?
- A kliens oldalon még nem létezett daily bonus RPC wrapper, így a `grant_daily_bonus_if_eligible()` hívása nem volt egységesen tesztelve a domain+provider rétegen.
- A JSON-válasz parsolása sem volt dokumentálva, különösen a `next_eligible_at` mező és a reason stringek, ami megnehezítette a frontend logikát.

## Mit módosítottunk?
- `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart` létrehozza a `DailyBonusReason` enumot, a `DailyBonusGrantResult` osztályt, az `fromJson` logikát (amount, reason, next_eligible_at parsing) és a `notConfigured` konstruktor módot.
- `app/lib/src/features/rewards/data/daily_bonus_rpc.dart` a `dailyBonusRpcCallerProvider`-ral guardolja a supabase konfigurációt és a `grant_daily_bonus_if_eligible()` RPC hívását, az eredményből `DailyBonusGrantResult` jön létre.
- `app/test/unit/daily_bonus_grant_result_test.dart` lefedi a null/ reason mapping/ nextEligibleAt parsing eseteket és azt, hogy a provider nem konfigurált Supabase esetén notConfigured eredményt ad.

## Tesztek
- `./scripts/check.sh` – PASS (az analyze és az összes widget/unit teszt, köztük a napi bonus unit teszt, hibátlanul futott).

## Következő lépések javasolt
1. A napi bónusz UI/Tile logika hivatkozzon a `DailyBonusGrantResult`-ra, különösen a `next_eligible_at` logikájára.
2. Ha új reason stringek érkeznek a back-endről, frissítsük a `DailyBonusReason`-t és a unit teszteket.
