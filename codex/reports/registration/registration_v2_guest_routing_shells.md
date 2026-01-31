## Mit találtunk?
- A jelenlegi routing mindig `/auth/login`-re bootolt, így a guest élmény elveszett, és a shell taboló többszörös route-okat tartalmazott.
- Hiányoztak a guest-specifikus stub képernyők + guest CTA-k a home-on, illetve a localization ARB nem fedte le az új tabokat.

## Mit módosítottunk?
- `goRouterProvider` most `/home`-on indul, a redirect logika guest/auth allowlistet és a callback/verify-pending megőrzését kezeli.
- Az `AppShell` ConsumerWidget-ként dinamikusan vált guest vs auth tablistára, az új Bets/Forum/GuestInfo/Profile screenek stub UI-val és lokalizációs stringekkel jöttek létre.
- `HomeScreen` guest módban két CTA gombot mutat, auth módban placeholder szöveget; az ARB-ok (HU/EN) + generált `app_localizations*.dart` fájlok új kulcsokat tartalmaznak.
- Widget tesztek frissültek (smoke test a guest home-hoz, `guest_routing_shells_test` a redirect/tab logikához), a `auth_provider` konstruktorától kezdve a `GoRouter`-en át az autentikációs státusz override-okig.

## Tesztek
- `./scripts/flutter.sh gen-l10n` – PASS (frissítette az ARB + generált fájlokat).
- `cd app && dart format .` – PASS.
- `./scripts/check.sh` – PASS (pub get + analyze + test; tartalmazza az új widget teszteket).

## Ismert korlátok / TODO
- A /tickets és /leaderboard útvonalak továbbra is léteznek, de guestként a redirect logika miatt `/auth/login` fogja azokat kezelni; későbbi sprintben érdemes dönteni, hogy teljesen eltávolítjuk vagy új útvonalra redirecteljük őket.

## Következő javasolt lépések
1. A guest flow-hoz kapcsolódó dokumentációkban (pl. `documents/registration/registration_flow_V2-md`) érdemes riffré tenni a tab listát és a CTA-kat.
2. Bővíteni az integration teszteket, hogy a guest redirect + auth callback flow minden platformon stabil maradjon.
