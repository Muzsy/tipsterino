## Mit találtunk?
- A canvas rögzíti, hogy a home tile manual claim-re épül, tehát nincs automatikus `grant_daily_bonus_if_eligible` hívás a widget lifecycle során.
- A meglévő HomeScreen authenticated ágában csak egy placeholder szöveg jelent meg, így ez az új tile integráció zökkenőmentesen illeszthető be.
- Az RPC/wrapper (`DailyBonusRpcCaller`) és a domain (`DailyBonusGrantResult`) már áll, ezért csak a kliens oldali állapot- és UI réteg hiányzott.

## Mit módosítottunk?
- Megvalósítottuk a `DailyBonusClaimProvider`-t (`isRunning`, `lastResult`, `cachedNextEligibleAt`, `lastError`, `isClaimedNow`) és a `claim()`-et, amely kizárólag a napi RPC-t hívja meg, és tárolja a `nextEligibleAt` értéket.
- Létrehoztuk a `DailyBonusTile`-t, ami lokalizált szövegeket, futó/loading indikátorokat és a CTA státuszait kezeli, illetve `ScaffoldMessenger` SnackBar-t jelenít meg sikeres grant után.
- A HomeScreen authenticated ágában a placeholder most egy `Column`, amely tartalmazza a tile-ot és az eredeti `homeAuthPlaceholder` szöveget.
- Bővítettük az EN/HU ARB fájlokat a `daily_bonus_*` kulcsokkal és frissítettük a `app_localizations.dart`, `app_localizations_en.dart` és `app_localizations_hu.dart` generált osztályokat.
- Hozzáadtunk egy widget tesztet (`daily_bonus_tile_test.dart`), ami default, claimed és disabled állapotokat fed le provider override-dal.

## Módosított/létrehozott fájlok
- `app/lib/src/features/rewards/application/daily_bonus_claim_provider.dart`
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- `app/lib/src/screens/home_screen.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_home_tile_claim_flow.md`
- `codex/reports/bonus_system/bonus_system_daily_bonus_home_tile_claim_flow.md`

## Tesztek
- `./scripts/check.sh` – PASS (repo gate: analyze + unit/widget tesztek, beleértve az új daily bonus tile tesztet)

## Következő javasolt lépések
1. Ha később a home screen többi tartalmát is feltöltjük, érdemes lehet a tile-t scroll/scrollable containerbe helyezni és UI teszteket hozzáadni.
2. Monitorozni, hogy a Supabase RPC-n belül a `nextEligibleAt` milyen gyakorisággal érkezik, és szükség esetén perzisztens cache/timer logikát építeni a tile-on.
