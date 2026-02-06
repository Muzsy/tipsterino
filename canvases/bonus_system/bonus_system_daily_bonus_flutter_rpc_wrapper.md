# Daily bonus – Flutter RPC wrapper + domain modell

## 🎯 Funkció

A kliensoldalon bevezetjük a daily bonus RPC hívás minimális, tesztelt csomagját:

- domain modell: `DailyBonusGrantResult` + `DailyBonusReason`
- RPC wrapper (Riverpod provider): `dailyBonusRpcCallerProvider`
- JSON parse a DB RPC contract szerint: `granted`, `amount`, `reason`, `next_eligible_at`

Nem cél ebben a taskban:
- Home tile UI
- inbox mapping / l10n kulcsok
- cache/state machine

## 🧠 Fejlesztési részletek

### Kiinduló minták (valós repo)
- Signup bonus domain: `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
- Signup bonus RPC wrapper: `app/lib/src/features/rewards/data/signup_bonus_rpc.dart`
- Supabase config guard: `app/lib/src/core/clients/supabase_provider.dart`

### Új fájlok

1) Domain modell
- Új fájl: `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`

Követelmények:
- enum `DailyBonusReason`:
  - `granted`
  - `notConfigured`
  - `disabled`
  - `alreadyClaimedToday`
  - `notVerified`
  - `notAuthenticated`
  - `profileIncomplete`
- class `DailyBonusGrantResult`:
  - `bool granted`
  - `int amount`
  - `DailyBonusReason reason`
  - `DateTime? nextEligibleAt`
- `fromJson(Map<String, dynamic>? map)`:
  - null map → `notConfigured`
  - `amount` parse: int/double/string → int
  - `next_eligible_at` parse:
    - ha string ISO → `DateTime.tryParse(...)` (UTC-t megtartva)
  - `reason` string mapping:
    - `granted` → granted
    - `disabled` → disabled
    - `already_claimed_today` → alreadyClaimedToday
    - `not_verified` → notVerified
    - `not_authenticated` → notAuthenticated
    - `profile_incomplete` → profileIncomplete
    - default → notConfigured
- legyen `const DailyBonusGrantResult.notConfigured()` konstruktor is

2) RPC wrapper
- Új fájl: `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`

Követelmények:
- `typedef DailyBonusRpcCaller = Future<DailyBonusGrantResult> Function();`
- `dailyBonusRpcCallerProvider`:
  - ha `supabaseConfigProvider.isConfigured` false vagy `client == null` → notConfigured result
  - különben:
    - `client.rpc<Map<String, dynamic>>('grant_daily_bonus_if_eligible').maybeSingle()`
    - response null esetén: `DailyBonusGrantResult.fromJson(null)` (ne “disabled”-re kényszerítsük)
    - különben: `DailyBonusGrantResult.fromJson(response)`

### Unit tesztek (minimál)
- Új teszt: `app/test/unit/daily_bonus_grant_result_test.dart`

Teszt esetek:
- `fromJson(null)` → notConfigured
- reason mapping:
  - `already_claimed_today` → alreadyClaimedToday
  - `profile_incomplete` → profileIncomplete
- `next_eligible_at` parse:
  - ISO string → DateTime értelmezhető és nem null
- provider guard:
  - default supabaseConfigProvider mellett a `dailyBonusRpcCallerProvider()` meghívása notConfigured-et ad vissza (nem dob).

## 🧪 Tesztállapot

Kötelező:
- `./scripts/check.sh` (analyze + test)

## 🌍 Lokalizáció

- Nincs ARB módosítás.

## 📎 Kapcsolódások

- DB RPC: `public.grant_daily_bonus_if_eligible()` (már kész, 20260210000000 migráció)
- Spec: `documents/bonus_system/daily_bonus.md`
- Minták:
  - `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart`
  - `app/lib/src/features/rewards/data/signup_bonus_rpc.dart`
  - `app/lib/src/core/clients/supabase_provider.dart`
