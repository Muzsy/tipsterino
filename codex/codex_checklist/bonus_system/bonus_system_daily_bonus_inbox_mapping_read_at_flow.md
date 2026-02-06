# Bonus system daily bonus inbox mapping + read_at flow checklist

## P1 – Preflight observations
- [x] `EventsInboxScreen` (`app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`) is the inbox surface, it already handles offline/loading/error/empty states and delegates `markRead` for unread `UserEvent`s.
- [x] `UserEventsNotifier.markRead` currently only updates `read_at` and the in-memory items list, while `UserEventsRepository.markRead` sends a single `update({'read_at': now})` call, so the privilege contract (read_at-only) was already respected.

## P2 – Implementation
- [x] Extended `_mapTitle`/`_mapBody` inside `EventsInboxScreen` to route `type='tippcoin_credit'` + `code='daily_bonus'` events to the new localized `event_daily_bonus_*` strings.
- [x] Added the `event_daily_bonus_title`/`event_daily_bonus_body` keys to both ARB files and wired them into the generated localization helpers (AppLocalizations and the EN/HU subclasses).
- [x] Added `events_inbox_daily_bonus_test.dart` to assert the daily bonus copy renders, tapping the tile triggers `markRead`, and the tile moves into the read state.

## P3 – QA gate
- [x] `./scripts/check.sh`
