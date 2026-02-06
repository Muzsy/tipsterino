# Daily bonus – Home tile claimed-state hotfix (nextEligibleAt cache gate)

## 🎯 Funkció

Javítani a daily bonus Home tile “claimed” állapotának feltételét, hogy:
- `nextEligibleAt` cache **csak** valódi claim esetén történjen:
  - `reason == granted` vagy `reason == alreadyClaimedToday`
- ne fordulhasson elő, hogy `disabled/not_verified/profile_incomplete` válasz után a tile “Claimed” állapotot mutat és blokkolja a későbbi claimet ugyanazon a napon.

## 🧠 Fejlesztési részletek

### Kontextus (miért bug)
A DB oldali `public.grant_daily_bonus_if_eligible()` minden ágban ad `next_eligible_at` mezőt.
A kliens oldali `DailyBonusClaimNotifier.claim()` jelenleg bármilyen válasznál cache-eli a `nextEligibleAt`-ot,
így egy disabled/blocked válasz után is “claimed”-nek látszik a tile.

### Érintett fájlok
- `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- (opcionális) `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart` csak ha szükséges

### Változtatás #1 – Cache gate
`DailyBonusClaimNotifier.claim()`:
- cache csak akkor frissüljön, ha:
  - `result.granted == true` **vagy**
  - `result.reason == DailyBonusReason.alreadyClaimedToday`
- minden más reason esetén a `cachedNextEligibleAt` maradjon változatlan

### Változtatás #2 – isClaimedNow pontosítása
`DailyBonusClaimState.isClaimedNow`:
- csak akkor legyen true, ha:
  - van `cachedNextEligibleAt` a jövőben **és**
  - a legutóbbi reason `granted` vagy `alreadyClaimedToday`
(Ezzel ha valahogy mégis beállna cache blocked reason mellett, nem vált “claimed”-re.)

### Teszt frissítés
`app/test/widget/daily_bonus_tile_test.dart`:
- A “claimed state” tesztet igazítsd:
  - állíts be `lastResult.reason = alreadyClaimedToday` + `cachedNextEligibleAt` a jövőben
- Adj hozzá új regressziós tesztet:
  - `lastResult.reason = disabled` + `cachedNextEligibleAt` a jövőben
  - elvárt: **disabled** szöveg látszik, CTA disabled, és **nem** “Claimed” label

## 🧪 Tesztállapot
- `./scripts/check.sh` – kötelező (analyze + unit/widget)

## 🌍 Lokalizáció
- Nincs módosítás.

## 📎 Kapcsolódások
- DB RPC: `supabase/migrations/20260210000000_bonus_system_rpc_daily_bonus.sql`
- Tile: `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- Provider: `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
