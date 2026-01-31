## Mit találtunk?
- A vendégbarát shell bevezetése után a `/tickets` és `/leaderboard` útvonalak továbbra is auth-only route-ként éltek a routerben, így guestjeket loginra küldtek vagy 404-et eredményeztek, holott ezek már csak legacy aliasok.
- A router a ShellRoute-on belül tartotta a stub képernyőket, és az ARB-okban (és generált kódban) még mindig szerepeltek a `ticketsTab`/`leaderboardTab` kulcsok, amelyek most már semmiben nem használatosak.

## Mit módosítottunk?
- A `goRouterProvider` guest allowlistje kiterjesztésre került `/tickets` és `/leaderboard` útvonalakkal, majd a route-ok külön, top-level `GoRoute`-ként `redirect`-elnek `/bets` illetve `/home` felé; a ShellRoute-on belül így eltűntek a régi definíciók és az importok is kitisztultak.
- A `TicketsScreen` és `LeaderboardScreen` fájlokat töröltük, mert a router már nem hivatkozik rájuk.
- Az angol és magyar ARB-okból eltávolítottuk a `ticketsTab`/`leaderboardTab` kulcsokat, majd `./scripts/flutter.sh gen-l10n` lefutott, így a generált `app_localizations*.dart` fájlokban sem szerepelnek többé.
- A `documents/registration/registration_flow_V2-md` most röviden dokumentálja, hogy a legacy linkek `/bets` és `/home` felé redirectelnek, így a guest-first shell váltás stabil marad.
- A `guest_routing_shells_test.dart` két új esetet kapott, amelyek guest illetve auth állapotban is ellenőrzik, hogy `/tickets` → Bets, `/leaderboard` → Home redirect történik.

## Tesztek
- `./scripts/flutter.sh gen-l10n` – PASS (frissítette az ARB és generált lokalizációs fájlokat).
- `cd app && dart format .` – PASS.
- `./scripts/check.sh` – PASS (a parancs pub get + analyze + a widget tesztek futtatása, beleértve az új `guest_routing_shells_test` eseteket is).

## Ismert korlátok / TODO
- A legacy útvonalak már csak redirectként élnek; ha később egyedi UI-t szeretnénk, újra kell helyeznünk vagy kibővítenünk a routert.

## Következő javasolt lépések
1. Ellenőrizzük a marketing anyagokat vagy külső linkeket, hogy további `/tickets` vagy `/leaderboard` hivatkozások nincsenek-e a wildban, és ha igen, frissítsük őket az új célokra.
2. Ha a redirect viselkedés stabil marad, szedjük ki a `documents` más részeiből is az említett kulcsokat vagy utalásokat.
