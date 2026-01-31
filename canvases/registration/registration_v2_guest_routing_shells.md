# Registration v2 – Guest mód routing + shell-ek (guest-first)

## 🎯 Funkció
A Tipsterino app mostantól **guest-first** élményként indul: a kezdő útvonal `/home`, a guest-engedélyezett útvonalak (/home, /bets, /forum, /guest-info, /auth/*) minden guest számára nyitva kell, míg minden más guest út `/auth/login`-re redirectel. Authentikált állapotban a guest útvonalak továbbra is elérhetők, de `/guest-info`, `/auth/login` és `/auth/register` automatikusan `/home` felé futnak, míg `/auth/callback` és `/auth/verify-pending` a callback UX miatt marad.

## 🧠 Fejlesztési részletek

### 1) GoRouter guest allowlist
- `app/lib/src/app/router/app_router.dart`-ban az `initialLocation` `/home`, a `redirect` pedig:
  - `AuthStatus.unknown` → null (ne redirectelj).
  - Guest (`unauthenticated` vagy `offline`): a guest allowlist (/home, /bets, /forum, /guest-info, `/auth/*`) engedélyezett, minden más `/auth/login`.
  - Authenticated: `/guest-info`, `/auth/login`, `/auth/register` → `/home`, az `/auth/callback` és `/auth/verify-pending` maradnak (nincs automatikus kiredirect).
  - A meglévő auth flow route-ok (login/register/verify-pending/callback) maradjanak működők.

### 2) Dinamikus shell tabok
- `app/lib/src/app/router/app_shell.dart` a `authNotifierProvider` alapján guest nav tabok (Home/Bets/Forum) vagy auth tabok (Home/Profile/Settings) listáját jeleníti meg, AppLocalizations kulcsokkal. Ha az aktuális út nem található a tabok között (pl. `/guest-info`), a `selectedIndex` 0 marad.

### 3) Új stub képernyők
- Bets/Forum/GustInfo/Profile screenek `app/lib/src/screens/` alatt, `Scaffold` + `AppBar` és placeholder tartalom, a GuestInfo képernyőn CTA gombok (`guestInfoLoginCta`, `guestInfoRegisterCta`) navigálással.

### 4) HomeScreen guest CTA
- A `HomeScreen` `ConsumerWidget`-ként figyeli az `authNotifierProvider` állapotát: guest módban két CTA (`homeGuestLoginCta`, `homeGuestRegisterCta`) jelenik meg, authként az `homeAuthPlaceholder` szöveg.

### 5) Router útvonalkészlet
- A ShellRoute alá felkerülnek az új `/bets`, `/forum`, `/guest-info`, `/profile` útvonalak (BetsScreen, ForumScreen, GuestInfoScreen, ProfileScreen). Az `/settings` marad, a korábbi `/tickets` és `/leaderboard` útvonalak opcionálisak; guestként a redirect logika miatt `/auth/login` jön létre.

## 🧪 Tesztállapot

### Kötelező módosítás
- `app/test/widget/app_smoke_test.dart`: guest boot Home-ra, a CTA gombok megjelennek és működnek (login/register).

### Új widget teszt
- `app/test/widget/guest_routing_shells_test.dart`:
  1. Guestként `/settings` → `/auth/login` redirect.
  2. Guest bottom nav: Home, Bets, Forum.
  3. Auth bottom nav: Home, Profile, Settings.
  4. Riverpod override-okkal, hálózat nélkül fut.

## 🌍 Lokalizáció
- `app/lib/l10n/app_{en,hu}.arb` új kulcsokkal (`betsTab`, `forumTab`, `profileTab`, `guestInfoTitle`, `guestInfoBody`, `guestInfoLoginCta`, `guestInfoRegisterCta`, `homeGuestLoginCta`, `homeGuestRegisterCta`, `homeAuthPlaceholder`), minden UI string innen jön.
- Futtasd: `./scripts/flutter.sh gen-l10n`, majd commitold a generált `app_localizations*.dart` fájlokat.

## 📎 Kapcsolódások
- `app/lib/src/app/router/app_router.dart`
- `app/lib/src/app/router/app_shell.dart`
- `app/lib/src/screens/home_screen.dart`
- `app/lib/src/screens/settings_screen.dart`
- `documents/registration/registration_flow_V2-md` (7) Router + GUEST mód + minimál shell-ek)
- `codex/codex_checklist/registration/registration_v2_guest_routing_shells.md`
- `codex/reports/registration/registration_v2_guest_routing_shells.md`
