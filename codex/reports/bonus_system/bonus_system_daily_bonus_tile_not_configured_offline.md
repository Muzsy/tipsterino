## Mit találtunk?
- A `DailyBonusTile` nem kérdezte meg a `supabaseConfigProvider.isConfigured` értéket, így fallback nélkül a UI “Claim” CTA-t mutatta az offline/notConfigured állapotokban is.
- A hiba vagy offline visszajelzés (`lastError`) csak általános `authGenericError` szöveget mutatott, nem volt dedikált “Retry” szöveg vagy újraolvasási lehetőség.

## Mit módosítottunk?
- A tile most először ellenőrzi, hogy Supabase felkonfigurálva van-e; ha nem, `daily_bonus_body_not_configured` szöveget mutat és a CTA tiltva marad.
- Ha `lastError` van és Supabase be van állítva, akkor `daily_bonus_body_offline` jelenik meg, a gomb “Retry” feliratot kap, és ugyanazt a `claim()`-et hívja meg ismét, így a felhasználó újrapróbálkozhat.
- Bővítettük az ARB-fájlokat és a generált `AppLocalizations`-okat az új kulcsokkal, és kibővítettük a widget tesztet az offline/not-configured forgatókönyvekkel.

## Módosított/létrehozott fájlok
- `app/lib/src/features/rewards/presentation/daily_bonus_tile.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`
- `app/test/widget/daily_bonus_tile_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_tile_not_configured_offline.md`
- `codex/reports/bonus_system/bonus_system_daily_bonus_tile_not_configured_offline.md`

## Tesztek
- `./scripts/check.sh` – PASS (analyze + widget/unit suite, beleértve a napi bónusz tile tesztet)

## Következő javasolt lépések
1. Ha hamarosan többszörös offline reason-ok jelennek meg, fontold meg, hogy a tile külön logolást kapjon a `lastError` mezőre.
2. Ha a Supabase konfigurációs állapot változik dinamikusan (például runtime config), biztosítsd, hogy a tile újracsinálja a `body`/CTA logikát egy konfigurációváltás után.
