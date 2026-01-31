# Registration v2 guest routing shells checklist

## C1 – Guest-first routing
- [x] `goRouterProvider` initial location `/home` és a guest allowlist (`/home`, `/bets`, `/forum`, `/guest-info`, `/auth/*`) érvényes a redirectben.
- [x] Auth státuszú felhasználónál `/guest-info`, `/auth/login` és `/auth/register` automatikusan `/home`-ra fut, az `/auth/callback` + `/auth/verify-pending` marad.

## C2 – Shell + stub screenek
- [x] `AppShell` ConsumerWidgetként él, auth/guest tabokat (guest: Home, Bets, Forum; auth: Home, Profile, Settings) jelenít meg AppLocalizations kulcsokkal.
- [x] Meglévők a stub képernyők: `BetsScreen`, `ForumScreen`, `GuestInfoScreen` (CTA gombokkal) és `ProfileScreen`.

## C3 – Home CTA + lokalizáció
- [x] HomeScreen guest módban megjeleníti a `homeGuestLoginCta` / `homeGuestRegisterCta` gombokat; auth módban `homeAuthPlaceholder`.
- [x] EN+HU ARB-ok és generált `app_localizations*.dart` fájlok tartalmazzák az új kulcsokat (`betsTab`, `forumTab`, `profileTab`, `guestInfo*`, `homeGuest*`, `homeAuthPlaceholder`).

## C4 – Teszt + gate
- [x] `app/test/widget/app_smoke_test.dart` ellenőrzi a guest-first home bootot és CTA működést.
- [x] `app/test/widget/guest_routing_shells_test.dart` lefedi `/settings` redirectet és guest/auth tab listát.
- [x] `./scripts/check.sh` (pub get + analyze + test) zöldült.
