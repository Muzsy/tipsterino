# Registration v2 – Legacy route cleanup (/tickets, /leaderboard) + redirect stabilizálás

## 🎯 Funkció

A guest-first routing bevezetése után a régi, már nem használt útvonalak (`/tickets`, `/leaderboard`) jelenleg “auth-only” útvonalnak számítanak (guest esetén loginra dobhatnak), miközben ezek **csak legacy maradványok**.

Cél:
- A legacy linkek **ne 404-ozzanak** és **ne kényszerítsék** guestet loginra.
- A régi útvonalak legyenek **átirányítva** az új guest-first shell struktúrához illeszkedő helyekre.
- A felesleges stub screenek és lokalizációs kulcsok kikerüljenek, ha már semmi nem használja őket.
- Dokumentáció és widget teszt lefedje a redirect viselkedést.

## 🧠 Fejlesztési részletek

### A) Router: legacy route redirect + allowlist
**Érintett fájl:** `app/lib/src/app/router/app_router.dart`

Teendők:
1. A guest allowlist egészítse ki a legacy útvonalakat:
   - `/tickets`
   - `/leaderboard`
   (Ezek legacy route-ok, amik redirectelnek, ezért guestnek is át kell engedni őket.)

2. Hozz létre két top-level GoRoute-ot **redirect**-tel (ne ShellRoute-on belül legyenek):
   - `/tickets` → redirect: `/bets`
   - `/leaderboard` → redirect: `/home`

3. A ShellRoute-on belül **távolítsd el** a régi route-okat:
   - `/tickets` builder (TicketsScreen)
   - `/leaderboard` builder (LeaderboardScreen)

4. Takarítsd ki a router importokat (ha már nem kell):
   - `tickets_screen.dart`
   - `leaderboard_screen.dart`

Elvárt eredmény:
- Guest esetén a `/tickets` és `/leaderboard` nem dob loginra és nem 404, hanem átvisz `/bets` illetve `/home` oldalra.
- Auth esetén ugyanez működik (legacy alias jelleggel).

### B) Felesleges stub screenek eltávolítása
**Érintett fájlok törlése:**
- `app/lib/src/screens/tickets_screen.dart`
- `app/lib/src/screens/leaderboard_screen.dart`

Feltétel:
- Csak akkor töröld, ha nincs már rájuk hivatkozás (routerből kivettük).

### C) Lokalizáció: nem használt kulcsok takarítása
**Érintett fájlok:**
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`

Teendők:
- Távolítsd el a már nem használt kulcsokat:
  - `ticketsTab`
  - `leaderboardTab`

Majd futtasd:
- `./scripts/flutter.sh gen-l10n`

Elvárt eredmény:
- A generált `app_localizations*.dart` fájlok frissülnek, és nem hivatkoznak a törölt kulcsokra.

### D) Dokumentáció szinkron
**Érintett fájl:** `documents/registration/registration_flow_V2-md`

Teendő:
- Adj hozzá egy rövid “Legacy routes” részt (vagy megfelelő helyre 2-4 bullet):
  - `/tickets` → `/bets` redirect (legacy)
  - `/leaderboard` → `/home` redirect (legacy)
  - Indok: guest-first shell váltás + régi linkek stabil kezelése

### E) Teszt lefedés: legacy redirect
**Érintett fájl (preferált):**
- `app/test/widget/guest_routing_shells_test.dart`

Teendő:
- Adj hozzá új teszte(ke)t:
  - guest állapotban (`AuthStatus.unauthenticated` vagy `offline`):
    - `router.go('/tickets')` után `/bets` UI jelenik meg (pl. `loc.betsTab` látszik)
    - `router.go('/leaderboard')` után home UI jelenik meg (pl. `loc.homeTab` látszik)
  - auth állapotban (`AuthStatus.authenticated`):
    - ugyanaz a két redirect elvárás

Megjegyzés:
- A tesztekben a `GoRouter.of(...)` mintát a meglévő `guest_routing_shells_test.dart` alapján kövesd.

## 🧪 Tesztállapot

Futtatandó parancsok:
- `./scripts/flutter.sh gen-l10n`
- `cd app && dart format .`
- `./scripts/check.sh`

Elvárt:
- `check.sh` zöld (analyze + widget test suite).

## 🌍 Lokalizáció

- EN + HU: `ticketsTab`, `leaderboardTab` törlése (csak ha tényleg nem marad hivatkozás).
- `gen-l10n` kötelező a változtatás után.

## 📎 Kapcsolódások

- Routing: `app/lib/src/app/router/app_router.dart`, `app/lib/src/app/router/app_shell.dart`
- Guest-first shell: Home/Bets/Forum + GuestInfo
- Dokumentáció: `documents/registration/registration_flow_V2-md`
- Tesztek: `app/test/widget/guest_routing_shells_test.dart`
