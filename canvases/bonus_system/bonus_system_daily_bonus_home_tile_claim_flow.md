# Daily bonus – Home tile + claim flow (no auto-grant)

## 🎯 Funkció

Daily bonus megjelenítése a Home képernyőn egy tile-ban, ami:
- csak gombnyomásra hívja az RPC-t (NINCS automatikus hívás build/load közben)
- a RPC válasz alapján megjeleníti az állapotot (disabled / not_verified / profile_incomplete / claimed / granted / error)
- a `nextEligibleAt` értéket memóriában cache-eli, hogy “claimed” állapotot tudjon mutatni ugyanabban az app futásban

Nem cél ebben a taskban:
- inbox integráció (user_events feed-en megjelenítés)
- perzisztens cache (app restart után is megmaradó nextEligibleAt)
- külön “eligibility check” RPC (nincs ilyen; a grant RPC-t csak user action-re hívjuk)

## 🧠 Fejlesztési részletek

### Érintett valós fájlok / minták
- Home: `app/lib/src/screens/home_screen.dart`
- Daily RPC wrapper: `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- Domain: `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- Minta StateNotifier: `app/lib/src/features/rewards/application/post_auth_init_provider.dart`
- L10n: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb` + `app/lib/l10n/app_localizations*.dart`

### Új fájlok

1) Application state + notifier
- `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`

State:
- `isRunning` bool
- `lastResult` DailyBonusGrantResult?
- `cachedNextEligibleAt` DateTime?
- `lastError` Object?

Logika:
- `isClaimedNow = cachedNextEligibleAt != null && cachedNextEligibleAt!.toUtc().isAfter(DateTime.now().toUtc())`
- `claim()`:
  - state.isRunning=true
  - call `DailyBonusRpcCaller`
  - state.lastResult = result
  - ha `result.nextEligibleAt != null` → state.cachedNextEligibleAt = result.nextEligibleAt
  - state.isRunning=false
  - return result
- fontos: NINCS automatikus claim/refresh initkor

Provider:
- `dailyBonusClaimProvider = StateNotifierProvider<DailyBonusClaimNotifier, DailyBonusClaimState>`

2) Presentation widget
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`

UI elv:
- Card/ListTile jelleg
- cím: `loc.daily_bonus_title`
- leírás és CTA a state alapján:
  - ha `isRunning`: spinner + CTA disabled
  - ha `isClaimedNow`: claimed szöveg + CTA disabled (mutathatja “Claimed”)
  - ha `lastResult.reason == disabled`: disabled szöveg + CTA disabled
  - ha `lastResult.reason == notVerified`: not_verified szöveg + CTA disabled
  - ha `lastResult.reason == profileIncomplete`: profile_incomplete szöveg + CTA disabled
  - default (nincs result / error után): available szöveg + CTA enabled
- gombnyomás:
  - hívja `claim()`
  - ha `result.granted==true` → SnackBar: `loc.daily_bonus_snackbar_granted(amount)`
  - ha `result.reason==alreadyClaimedToday` → state-ben cache-elt nextEligibleAt alapján claimed

### Home integráció
- `app/lib/src/screens/home_screen.dart` authenticated ágában:
  - placeholder helyett Column:
    - `DailyBonusTile()`
    - meglévő placeholder szöveg maradhat alatta (amíg a home tartalom készül)

### L10n kulcsok (minimál, 2 nyelven)
Adj hozzá új kulcsokat:

EN (`app_en.arb`)
- `daily_bonus_title`: "Daily bonus"
- `daily_bonus_body_available`: "Claim your daily TippCoins."
- `daily_bonus_body_claimed`: "Already claimed today. Come back tomorrow."
- `daily_bonus_body_disabled`: "Daily bonus is not active."
- `daily_bonus_body_not_verified`: "Verify your email to claim the daily bonus."
- `daily_bonus_body_profile_incomplete`: "Complete your profile to claim the daily bonus."
- `daily_bonus_cta_claim`: "Claim"
- `daily_bonus_cta_claimed`: "Claimed"
- `daily_bonus_snackbar_granted`: "Daily bonus claimed: +{amount} TippCoins!"

HU (`app_hu.arb`)
- `daily_bonus_title`: "Napi bónusz"
- `daily_bonus_body_available`: "Igényeld a napi TippCoin jutalmad."
- `daily_bonus_body_claimed`: "Ma már igényelted. Gyere vissza holnap."
- `daily_bonus_body_disabled`: "A napi bónusz jelenleg nem aktív."
- `daily_bonus_body_not_verified`: "Email megerősítése szükséges a napi bónusz igényléséhez."
- `daily_bonus_body_profile_incomplete`: "Profil kitöltése szükséges a napi bónusz igényléséhez."
- `daily_bonus_cta_claim`: "Igénylés"
- `daily_bonus_cta_claimed`: "Igényelve"
- `daily_bonus_snackbar_granted`: "Napi bónusz jóváírva: +{amount} TippCoin!"

Mivel a repo-ban a generated `app_localizations*.dart` file-ok commitolva vannak, frissítsd:
- `app/lib/l10n/app_localizations.dart` (új getterek + paraméteres snackbar)
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`

## 🧪 Tesztállapot

Új widget teszt:
- `app/test/widget/daily_bonus_tile_test.dart`

Minimum esetek:
- default state: “Claim” CTA látszik
- claimed state (cachedNextEligibleAt a jövőben): “Claimed” CTA disabled
- disabled result: disabled szöveg + CTA disabled

Repo gate:
- `./scripts/check.sh`

## 🌍 Lokalizáció

- Új kulcsok 2 nyelven + generated dart frissítés.

## 📎 Kapcsolódások

- DB RPC: `public.grant_daily_bonus_if_eligible()` (20260210000000)
- Flutter RPC wrapper: `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- Domain: `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- Home: `app/lib/src/screens/home_screen.dart`
- L10n: `app/lib/l10n/*`
