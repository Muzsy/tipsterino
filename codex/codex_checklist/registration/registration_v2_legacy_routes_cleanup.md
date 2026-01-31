# Registration v2 legacy routes cleanup checklist

## C1 – Legacy guest routing
- [x] Guest allowlist now lists `/tickets` and `/leaderboard`, and new top-level `GoRoute`s redirect them to `/bets` and `/home` without touching the shell.
- [x] The ShellRoute no longer declares those routes and the unused `TicketsScreen`/`LeaderboardScreen` imports were removed from `app_router.dart`.

## C2 – Stub screens
- [x] `app/lib/src/screens/tickets_screen.dart` and `app/lib/src/screens/leaderboard_screen.dart` deleted because no code references them anymore.

## C3 – Localization
- [x] EN/HU ARB files drop `ticketsTab`/`leaderboardTab`, and `./scripts/flutter.sh gen-l10n` regenerated `app_localizations*.dart` without those getters.

## C4 – Documentation
- [x] `documents/registration/registration_flow_V2-md` documents that `/tickets` → `/bets` and `/leaderboard` → `/home` legacy redirects exist to keep guest-first shell stable.

## C5 – Tests
- [x] `app/test/widget/guest_routing_shells_test.dart` now asserts guest and auth states redirect legacy routes into the Bets and Home tabs.

## C6 – Gate
- [x] `cd app && dart format .`
- [x] `./scripts/check.sh`
