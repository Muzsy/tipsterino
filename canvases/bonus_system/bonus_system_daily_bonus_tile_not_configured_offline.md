# Daily bonus – Tile notConfigured + offline/error UX

**TASK_SLUG:** `bonus_system_daily_bonus_tile_not_configured_offline`

## 🎯 Funkció

A Home-on lévő DailyBonusTile ne legyen félrevezető akkor sem, ha:
- a Supabase nincs konfigurálva (`supabaseConfigProvider.isConfigured == false`), vagy
- az RPC hívás hálózati/egyéb hibára fut (exception)

Elvárt viselkedés:
- **notConfigured**: érthető szöveg + CTA tiltva
- **offline/error**: érthető szöveg + CTA “Próbáld újra” (retry) engedélyezve (ha Supabase konfigurált)

Nem cél:
- perzisztens cache
- daily bonus amount beállítása (>0) (külön task)
- Inbox módosítás

## 🧠 Fejlesztési részletek

### Érintett valós fájlok
- Tile: `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- Claim provider: `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
- Supabase config: `app/lib/src/core/clients/supabase_provider.dart` (supabaseConfigProvider)
- L10n:
  - `app/lib/l10n/app_en.arb`
  - `app/lib/l10n/app_hu.arb`
  - `app/lib/l10n/app_localizations.dart`
  - `app/lib/l10n/app_localizations_en.dart`
  - `app/lib/l10n/app_localizations_hu.dart`
- Widget teszt: `app/test/widget/daily_bonus_tile_test.dart`

### 1) notConfigured state kezelése a Tile-ban (preflight + runtime)

Probléma:
- a `dailyBonusRpcCallerProvider` notConfigured-et ad vissza, de a tile default állapotban mégis “available + Claim” UX-et mutathat.

Megoldás:
- A tile olvassa a `supabaseConfigProvider`-t és számoljon egy `isSupabaseConfigured` flaget.
- CTA legyen **tiltva**, ha `!isSupabaseConfigured`.

Szöveg:
- body: új l10n kulcs `daily_bonus_body_not_configured`

### 2) offline/error state kezelése (claim után)

A `DailyBonusClaimState` már tartalmaz `lastError` mezőt.
Megoldás:
- Ha `lastError != null`:
  - body: `daily_bonus_body_offline`
  - CTA: legyen engedélyezett **csak akkor**, ha `isSupabaseConfigured == true` és nem fut épp (`!isRunning`) és nem claimed és nem blocked reason
  - CTA szöveg: új kulcs `daily_bonus_cta_retry`
- Tap:
  - ugyanazt a `claim()`-et hívja újra
  - (opcionális) hiba esetén SnackBar `daily_bonus_snackbar_error` (új kulcs) – csak ha már van ScaffoldMessenger a tile kontextusban

Fontos:
- offline/error ne írja felül a “claimed/disabled/not_verified/profile_incomplete” állapotokat.
  Ajánlott prioritás:
  1) isRunning
  2) isClaimedNow
  3) lastResult.reason: disabled / notVerified / profileIncomplete
  4) notConfigured (supabase not configured)
  5) lastError != null (offline)
  6) default available

### 3) L10n kulcsok (HU/EN)

EN (`app_en.arb`)
- `daily_bonus_body_not_configured`: "Daily bonus is unavailable (not configured)."
- `daily_bonus_body_offline`: "You appear to be offline. Try again."
- `daily_bonus_cta_retry`: "Retry"
- (opcionális) `daily_bonus_snackbar_error`: "Could not claim daily bonus. Try again."

HU (`app_hu.arb`)
- `daily_bonus_body_not_configured`: "A napi bónusz nem elérhető (nincs beállítva)."
- `daily_bonus_body_offline`: "Úgy tűnik, nincs internetkapcsolat. Próbáld újra."
- `daily_bonus_cta_retry`: "Újrapróbálás"
- (opcionális) `daily_bonus_snackbar_error`: "Nem sikerült igényelni a napi bónuszt. Próbáld újra."

Frissítsd a commitolt generated fájlokat is a repo mintája szerint.

### 4) Widget teszt bővítés (stabil)

`app/test/widget/daily_bonus_tile_test.dart` bővítése:

Új esetek:
1) **notConfigured**:
   - supabaseConfigProvider override: isConfigured=false
   - elvárt: `daily_bonus_body_not_configured` látszik, CTA disabled (ne legyen “Claim” aktív)
2) **offline/error**:
   - supabaseConfigProvider override: isConfigured=true
   - dailyBonusClaimProvider state: lastError != null
   - elvárt: `daily_bonus_body_offline` látszik, CTA “Retry” aktív

Megjegyzés: ha a repo-ban nem könnyű a supabaseConfigProvider override (pl. sealed impl),
akkor a tile logikát úgy szervezd, hogy a konfiguráltság providerből mockolható legyen (Riverpod override).

## 🧪 Tesztállapot

Kötelező:
- `./scripts/check.sh`

## 🌍 Lokalizáció

- Új kulcsok HU/EN + generated dart frissítés.

## 📎 Kapcsolódások

- Daily RPC wrapper: `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- Claim provider: `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
- Tile: `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- Supabase config: `app/lib/src/core/clients/supabase_provider.dart`
